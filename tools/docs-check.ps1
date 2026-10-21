<#
docs-check.ps1 - read-only check of the hub's local docs/ corpus against DOC-INTERNAL-QUALITY rules 1, 2, 3, 5 and 6.

  rule 1  docs/DOCUMENT_REGISTRY.jsonl: every line parses, has no duplicate key and carries the required fields
  rule 2  both ways: every declared path exists, every .md/.html/.jsonl under docs/ is declared
  rule 3  every relative link in docs/**/*.md resolves to a file (anchors are not checked)
  rule 5  no em/en dash and no three-dot ellipsis in docs prose (code fences skipped)
  rule 6  every image cited in docs/**/*.md exists

Rule 4 (generated documentation drift) and rule 7 (offline safety beyond the cited images) are not scripted: nothing
in docs/ is derived from source, and the corpus loads no remote font, script or pixel.

Usage:  pwsh -NoProfile -File tools/docs-check.ps1
Exit:   0 no finding, 1 at least one finding. Writes nothing.
#>
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root
$findings = 0
function Find([string]$msg) { $script:findings++; Write-Host "FINDING $msg" }
function Rel([string]$full) { $full.Substring($root.Length + 1).Replace([string][char]92, '/') }

$regFile = 'docs/DOCUMENT_REGISTRY.jsonl'
$entries = @(); $n = 0
$required = 'id', 'title', 'category', 'audience', 'paths', 'product_areas', 'update_triggers'
foreach ($l in (Get-Content -LiteralPath $regFile -Encoding utf8)) {
  $n++
  if ([string]::IsNullOrWhiteSpace($l)) { Find "rule 1: $regFile line ${n} is blank"; continue }
  try { $e = $l | ConvertFrom-Json } catch { Find "rule 1: $regFile line ${n} does not parse"; continue }
  foreach ($k in $required) { if (-not $e.PSObject.Properties[$k]) { Find "rule 1: entry '$($e.id)' lacks '$k'" } }
  $keys = [regex]::Matches($l, '"([A-Za-z_]+)":(?=["\[{0-9tfn])') | ForEach-Object { $_.Groups[1].Value }
  # top-level keys only: a key repeated at depth 1 shows up twice; nested keys (sitemap_exclude items) are filtered by name
  $dup = $keys | Where-Object { $_ -in $required + 'published', 'indexable', 'generated', 'notes', 'url', 'languages' } | Group-Object | Where-Object Count -gt 1
  foreach ($d in $dup) { Find "rule 1: entry '$($e.id)' repeats key '$($d.Name)'" }
  $entries += $e
}

$declared = New-Object System.Collections.Generic.HashSet[string]
foreach ($e in $entries) {
  foreach ($p in $e.paths) {
    $hits = @(Get-ChildItem -Path $p -ErrorAction SilentlyContinue)
    if ($hits.Count -eq 0) { Find "rule 2: '$($e.id)' declares '$p', which does not exist" }
    foreach ($h in $hits) { [void]$declared.Add((Rel $h.FullName)) }
  }
}
Get-ChildItem docs -Recurse -File | Where-Object { $_.Extension -in '.md', '.html', '.jsonl' -and $_.Name -ne 'DOCUMENT_REGISTRY.jsonl' } | ForEach-Object {
  $r = Rel $_.FullName; if (-not $declared.Contains($r)) { Find "rule 2: $r is not declared in the registry" }
}

foreach ($f in Get-ChildItem docs -Recurse -File -Filter *.md) {
  $txt = Get-Content -LiteralPath $f.FullName -Raw -Encoding utf8
  foreach ($m in [regex]::Matches($txt, '(?<!!)\[[^\]]*\]\((?!https?:|mailto:|#)([^)\s#]+)')) {
    if (-not (Test-Path -LiteralPath (Join-Path $f.DirectoryName ([uri]::UnescapeDataString($m.Groups[1].Value))))) { Find "rule 3: $(Rel $f.FullName) links to missing '$($m.Groups[1].Value)'" }
  }
  foreach ($m in [regex]::Matches($txt, '!\[[^\]]*\]\(([^)\s]+)')) {
    if (-not (Test-Path -LiteralPath (Join-Path $f.DirectoryName $m.Groups[1].Value))) { Find "rule 6: $(Rel $f.FullName) cites missing image '$($m.Groups[1].Value)'" }
  }
  $in = $false; $i = 0
  foreach ($l in (Get-Content -LiteralPath $f.FullName -Encoding utf8)) {
    $i++
    if ($l -match '^\s*```') { $in = -not $in; continue }
    if (-not $in -and ($l -match '[–—]' -or $l -match '(?<!\.)\.\.\.(?!\.)')) { Find "rule 5: $(Rel $f.FullName):$i has an em/en dash or '...'" }
  }
}
Write-Host "docs-check: $($entries.Count) registry entries, $findings finding(s)"
exit $(if ($findings) { 1 } else { 0 })
