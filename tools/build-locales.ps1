<#
build-locales.ps1 - render the hub's locale pages and AI-discovery files from one source.

Source (edit these, never the outputs):
  tools/hub/template.html   the page, with {{key}} text slots and {{@name}} build slots
  tools/hub/strings.json    the en / ru / uk text; every key in every locale
  tools/hub/products.json   the cards: landing, icon, text keys, verified channels

Outputs (render targets - regenerate, never hand-edit):
  index.html, embed.html    English, x-default (embed.html is the byte copy Google Sites embeds)
  uk/index.html             Ukrainian
  ru/index.html             Russian
  llms.txt, llms-full.txt   the AI-discovery summary and the full product list, in English

Usage:
  pwsh -NoProfile -File tools/build-locales.ps1          write every output
  pwsh -NoProfile -File tools/build-locales.ps1 -Check   write nothing; fail when an output is stale

Exit codes: 0 = written, or -Check found every output current; 1 = -Check found a stale or missing output;
2 = the source is invalid (missing key, unknown slot, bad JSON).
#>
[CmdletBinding()]
param([switch]$Check)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$src = Join-Path $PSScriptRoot 'hub'

function Fail([string]$msg) { Write-Host "build-locales: ERROR - $msg"; exit 2 }

function Esc([string]$s) {
  return $s.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;')
}

try {
  $template = [IO.File]::ReadAllText((Join-Path $src 'template.html'))
  $strings = [IO.File]::ReadAllText((Join-Path $src 'strings.json')) | ConvertFrom-Json -AsHashtable
  $products = ([IO.File]::ReadAllText((Join-Path $src 'products.json')) | ConvertFrom-Json -AsHashtable).products
} catch { Fail "cannot read the source: $($_.Exception.Message)" }

$locales = @(
  @{ code = 'en'; key = 'en'; url = 'https://sza.od.ua/'; root = ''; forward = 'true'; files = @('index.html', 'embed.html') },
  @{ code = 'uk'; key = 'ua'; url = 'https://sza.od.ua/uk/'; root = '../'; forward = 'false'; files = @('uk/index.html') },
  @{ code = 'ru'; key = 'ru'; url = 'https://sza.od.ua/ru/'; root = '../'; forward = 'false'; files = @('ru/index.html') }
)

# Every locale carries exactly the keys of English.
$enKeys = @($strings['en'].Keys | Where-Object { $_ -ne '$comment' })
foreach ($l in 'ru', 'uk') {
  if (-not $strings.ContainsKey($l)) { Fail "strings.json has no '$l' block" }
  $missing = @($enKeys | Where-Object { -not $strings[$l].ContainsKey($_) })
  $extra = @($strings[$l].Keys | Where-Object { $_ -notin $enKeys })
  if ($missing.Count) { Fail "strings.json '$l' lacks: $($missing -join ', ')" }
  if ($extra.Count) { Fail "strings.json '$l' has keys English lacks: $($extra -join ', ')" }
}

function T([hashtable]$s, [string]$k) {
  if (-not $s.ContainsKey($k)) { Fail "no string '$k'" }
  return [string]$s[$k]
}

function Name-Of($p, [hashtable]$s) { if ($p.nameKey) { return (T $s $p.nameKey) } else { return [string]$p.name } }

function Winget-Command([string]$id) { return "winget install --id $id -e" }

function Render-Card($p, [hashtable]$s, [string]$rootPrefix, [string]$lang) {
  $name = Name-Of $p $s
  # The landing in the page's language, where the product itself declares one by hreflang (S0007 F17).
  $landing = if ($p.localeUrls -and $p.localeUrls.ContainsKey($lang)) { [string]$p.localeUrls[$lang] } else { [string]$p.url }
  $alt = if ($p.iconAlt) { [string]$p.iconAlt } else { (T $s 'icon-alt').Replace('{name}', $name) }
  $ext = "<span class=""gi gi-external"" aria-hidden=""true""></span><span class=""sr"">, $(Esc (T $s 'ext-window'))</span>"
  $about = "<span class=""sr""> - $(Esc $name)</span>"
  $o = [Text.StringBuilder]::new()
  [void]$o.AppendLine('        <article class="card project-card">')
  [void]$o.AppendLine('          <div class="proj-head">')
  [void]$o.AppendLine("            <img src=""$($rootPrefix)assets/$($p.icon)"" alt=""$(Esc $alt)"" width=""46"" height=""46"" loading=""lazy"" decoding=""async"">")
  [void]$o.AppendLine("            <div><h3 class=""proj-title""><a href=""$(Esc $landing)"" target=""_blank"" rel=""noopener"">$(Esc $name)$ext</a></h3><span class=""pill"">$(Esc (T $s $p.typeKey))</span></div>")
  [void]$o.AppendLine('          </div>')
  [void]$o.AppendLine("          <p class=""proj-desc"">$(Esc (T $s $p.descKey))</p>")
  [void]$o.AppendLine('          <div class="proj-foot">')
  foreach ($c in @($p.channels | Where-Object { $_.kind -eq 'winget' })) {
    $cmd = Winget-Command $c.id
    $lid = "wg-$($p.id)"
    [void]$o.AppendLine("            <div class=""cbx""><span class=""cbx-label"" id=""$lid"">$(Esc (T $s 'winget-label'))</span><div class=""copybox""><span class=""cb-text"">$(Esc $cmd)</span><button type=""button"" class=""copy"" aria-describedby=""$lid"" data-copy=""$(Esc $cmd)""><span class=""gi gi-copy"" aria-hidden=""true""></span><span class=""cl""><span class=""cl-idle"">$(Esc (T $s 'copy'))</span><span class=""cl-done"">$(Esc (T $s 'copied'))</span></span></button></div></div>")
  }
  [void]$o.AppendLine('            <div class="btn-row">')
  [void]$o.AppendLine("              <a href=""$(Esc $landing)"" class=""btn"" target=""_blank"" rel=""noopener noreferrer""><span>$(Esc (T $s 'product-page'))</span>$about$ext</a>")
  foreach ($c in @($p.channels | Where-Object { $_.kind -eq 'link' })) {
    $label = if ($c.labelKey) { T $s $c.labelKey } else { [string]$c.label }
    $isExt = -not ($c.ContainsKey('external') -and $c.external -eq $false)
    $attrs = if ($isExt) { ' target="_blank" rel="noopener noreferrer"' } else { '' }
    $tail = if ($isExt) { $ext } else { '' }
    [void]$o.AppendLine("              <a href=""$(Esc $c.url)"" class=""btn btn-ghost""$attrs><span>$(Esc $label)</span>$about$tail</a>")
  }
  [void]$o.AppendLine('            </div>')
  [void]$o.AppendLine('          </div>')
  [void]$o.Append('        </article>')
  return $o.ToString()
}

function Render-JsonLd($loc, [hashtable]$s) {
  $items = @(); $i = 0
  foreach ($p in $products) { $i++; $items += [ordered]@{ '@type' = 'ListItem'; position = $i; name = (Name-Of $p $s); url = $p.url } }
  $graph = [ordered]@{
    '@context' = 'https://schema.org'
    '@graph'   = @(
      [ordered]@{ '@type' = 'WebSite'; '@id' = 'https://sza.od.ua/#website'; url = 'https://sza.od.ua/'; name = 'Serhii Zhyhunenko (SZA)'
        inLanguage = @('en', 'uk', 'ru'); publisher = @{ '@id' = 'https://sza.od.ua/#person' } },
      [ordered]@{ '@type' = 'WebPage'; '@id' = "$($loc.url)#webpage"; url = $loc.url; name = (T $s 'title'); description = (T $s 'meta-description')
        inLanguage = $loc.code; isPartOf = @{ '@id' = 'https://sza.od.ua/#website' }; about = @{ '@id' = 'https://sza.od.ua/#person' }
        mainEntity = @{ '@id' = "$($loc.url)#products" } },
      [ordered]@{ '@type' = 'Person'; '@id' = 'https://sza.od.ua/#person'; name = 'Serhii Zhyhunenko'; alternateName = 'SZA'; url = 'https://sza.od.ua/'
        image = 'https://sza.od.ua/android-chrome-512x512.png'; email = 'mailto:sza@ukr.net'
        sameAs = @('https://github.com/SerZhyAle', 'https://www.linkedin.com/in/serhii-zhyhunenko-a4600388/') },
      [ordered]@{ '@type' = 'ItemList'; '@id' = "$($loc.url)#products"; name = (T $s 'projects-title'); numberOfItems = $items.Count; itemListElement = $items }
    )
  }
  $json = $graph | ConvertTo-Json -Depth 10
  if ($json.Contains('</')) { Fail 'JSON-LD would close its script element' }
  return (($json -split "`r?`n") | ForEach-Object { "  $_" }) -join "`n"
}

function Render-Page($loc) {
  $s = $strings[$loc.code]
  $build = @{
    'lang' = $loc.code; 'key' = $loc.key; 'url' = $loc.url; 'root' = $loc.root; 'forward' = $loc.forward
    'pressed-ru' = ($loc.key -eq 'ru').ToString().ToLower(); 'pressed-en' = ($loc.key -eq 'en').ToString().ToLower(); 'pressed-ua' = ($loc.key -eq 'ua').ToString().ToLower()
    'generated' = 'Generated by tools/build-locales.ps1 from tools/hub/ - edit the source there and rebuild; never edit this file.'
    'cards-main' = (@($products | Where-Object { $_.section -eq 'main' } | ForEach-Object { Render-Card $_ $s $loc.root $loc.code }) -join "`n")
    'cards-1c' = (@($products | Where-Object { $_.section -eq '1c' } | ForEach-Object { Render-Card $_ $s $loc.root $loc.code }) -join "`n")
    'jsonld' = (Render-JsonLd $loc $s)
  }
  $out = [regex]::Replace($template, '\{\{(@?)([a-z0-9-]+)\}\}', {
      param($m)
      $k = $m.Groups[2].Value
      if ($m.Groups[1].Value -eq '@') { if (-not $build.ContainsKey($k)) { Fail "unknown build slot {{@$k}}" }; return [string]$build[$k] }
      return (Esc (T $s $k))
    })
  if ($out -match '\{\{') { Fail 'an unresolved {{ slot remains in the output' }
  return $out
}

function Render-Llms([bool]$full) {
  $s = $strings['en']
  $o = [Text.StringBuilder]::new()
  [void]$o.AppendLine('# SZA - Serhii Zhyhunenko')
  [void]$o.AppendLine()
  [void]$o.AppendLine("> $(T $s 'meta-description')")
  [void]$o.AppendLine()
  [void]$o.AppendLine("$(T $s 'hero-desc') The hub at https://sza.od.ua/ is a static page in English, with Ukrainian at https://sza.od.ua/uk/ and Russian at https://sza.od.ua/ru/. Each product page is the authority for what it does and how to install it.")
  [void]$o.AppendLine()
  [void]$o.AppendLine('## Products')
  [void]$o.AppendLine()
  foreach ($p in $products) {
    $name = Name-Of $p $s
    if (-not $full) { [void]$o.AppendLine("- [$name]($($p.url)): $(T $s $p.descKey)"); continue }
    [void]$o.AppendLine("### $name")
    [void]$o.AppendLine()
    [void]$o.AppendLine("- Type: $(T $s $p.typeKey)")
    if ($p.os) { [void]$o.AppendLine("- Platform: $($p.os)") }
    [void]$o.AppendLine("- Product page: $($p.url)")
    foreach ($c in $p.channels) {
      if ($c.kind -eq 'winget') { [void]$o.AppendLine("- Install with winget: ``$(Winget-Command $c.id)``") }
      else { $label = if ($c.labelKey) { T $s $c.labelKey } else { [string]$c.label }; [void]$o.AppendLine("- ${label}: $($c.url)") }
    }
    [void]$o.AppendLine()
    [void]$o.AppendLine((T $s $p.descKey))
    [void]$o.AppendLine()
  }
  if (-not $full) { [void]$o.AppendLine() }
  [void]$o.AppendLine('## Contact')
  [void]$o.AppendLine()
  [void]$o.AppendLine('- Email: sza@ukr.net')
  [void]$o.AppendLine('- GitHub: https://github.com/SerZhyAle')
  [void]$o.AppendLine('- LinkedIn: https://www.linkedin.com/in/serhii-zhyhunenko-a4600388/')
  if (-not $full) {
    [void]$o.AppendLine()
    [void]$o.AppendLine('## Optional')
    [void]$o.AppendLine()
    [void]$o.AppendLine('- [Full product list with install channels](https://sza.od.ua/llms-full.txt)')
    [void]$o.AppendLine('- [Українська версія](https://sza.od.ua/uk/)')
    [void]$o.AppendLine('- [Русская версия](https://sza.od.ua/ru/)')
  }
  return $o.ToString().Replace("`r`n", "`n")
}

$outputs = [ordered]@{}
foreach ($loc in $locales) { $html = Render-Page $loc; foreach ($f in $loc.files) { $outputs[$f] = $html } }
$outputs['llms.txt'] = Render-Llms $false
$outputs['llms-full.txt'] = Render-Llms $true

$utf8 = [Text.UTF8Encoding]::new($false)
$stale = @()
foreach ($f in $outputs.Keys) {
  $path = Join-Path $root $f
  $want = $outputs[$f].Replace("`r`n", "`n")
  $have = if (Test-Path -LiteralPath $path) { [IO.File]::ReadAllText($path) } else { $null }
  if ($have -ceq $want) { continue }
  if ($Check) { $stale += $f; continue }
  $dir = Split-Path -Parent $path
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  [IO.File]::WriteAllText($path, $want, $utf8)
  Write-Host "build-locales: wrote $f"
}
if ($Check) {
  if ($stale.Count) { Write-Host "build-locales: FAIL - stale or missing: $($stale -join ', '). Run tools/build-locales.ps1."; exit 1 }
  Write-Host "build-locales: PASS - $($outputs.Count) outputs are current."
}
exit 0
