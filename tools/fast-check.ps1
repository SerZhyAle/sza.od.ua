<#
fast-check.ps1 - fast, read-only checks for work between publishes.
Exit 0 when the hub page and its embed are byte-identical and every page rendered by build-locales.ps1 is
current; otherwise exit 1.
#>
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
try {
  $page = [System.IO.File]::ReadAllBytes((Join-Path $root 'index.html'))
  $embed = [System.IO.File]::ReadAllBytes((Join-Path $root 'embed.html'))
  if (-not [System.Collections.StructuralComparisons]::StructuralEqualityComparer.Equals($page, $embed)) {
    Write-Host 'fast-check: FAIL - index.html and embed.html differ.'
    exit 1
  }
  Write-Host 'fast-check: PASS - index.html and embed.html are byte-identical.'
  & pwsh -NoProfile -File (Join-Path $PSScriptRoot 'build-locales.ps1') -Check
  if ($LASTEXITCODE -ne 0) { Write-Host 'fast-check: FAIL - the rendered pages are stale; run tools/build-locales.ps1.'; exit 1 }
  exit 0
} catch {
  Write-Host "fast-check: FAIL - $($_.Exception.Message)"
  exit 1
}
