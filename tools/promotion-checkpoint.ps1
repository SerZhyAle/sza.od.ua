<#
.SYNOPSIS
  Promotion checkpoint collector for sza.od.ua portfolio and serzhyale.github.io host root.
.DESCRIPTION
  Read-only portfolio metrics checkpoint script per canon PROMOTION.md section 7 and
  PLAN-2026-10-09-free-promotion-campaign.md (P6).
  Gathers status of host-root robots.txt, sitemaps, hub repository metadata, traffic,
  and dependent product tickets' reported metrics.
  Outputs docs/promotion-checkpoints/<YYYY-MM-DD>.md without making any git pushes or commits.
.PARAMETER Date
  Checkpoint date string in YYYY-MM-DD format. Defaults to today's date (local).
.PARAMETER OutputPath
  Optional path to the markdown file. Defaults to docs/promotion-checkpoints/<Date>.md.
#>
[CmdletBinding()]
param(
  [string]$Date = (Get-Date -Format "yyyy-MM-dd"),
  [string]$OutputPath = ""
)

$ErrorActionPreference = "Continue"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
if (-not $OutputPath) {
  $checkpointDir = Join-Path $repoRoot "docs/promotion-checkpoints"
  if (-not (Test-Path $checkpointDir)) {
    New-Item -ItemType Directory -Path $checkpointDir -Force | Out-Null
  }
  $OutputPath = Join-Path $checkpointDir "$Date.md"
}

Write-Host "Running promotion checkpoint for date: $Date"
Write-Host "Output path: $OutputPath"

# 1. Host root robots.txt & project sitemaps
Write-Host "Checking host root and project sitemaps..."
$robotsUrl = "https://serzhyale.github.io/robots.txt"
$robotsCode = "unknown"
$robotsBody = ""
try {
  $robotsCode = (curl.exe -s -o /dev/null -w "%{http_code}" $robotsUrl).Trim()
  if ($robotsCode -eq "200") {
    $robotsBody = curl.exe -s $robotsUrl
  }
} catch {
  $robotsCode = "error"
}

# Sitemaps to check (from live robots.txt if 200, or from source github-root-redirect/robots.txt)
$sitemapList = @()
$sourceRobotsPath = Join-Path $repoRoot "github-root-redirect/robots.txt"
if ($robotsCode -eq "200" -and $robotsBody) {
  $lines = $robotsBody -split "\r?\n"
  foreach ($l in $lines) {
    if ($l -match '^\s*Sitemap:\s*(https?://\S+)') {
      $sitemapList += $Matches[1]
    }
  }
} elseif (Test-Path $sourceRobotsPath) {
  $lines = Get-Content $sourceRobotsPath
  foreach ($l in $lines) {
    if ($l -match '^\s*Sitemap:\s*(https?://\S+)') {
      $sitemapList += $Matches[1]
    }
  }
}

$sitemapResults = @()
foreach ($sm in $sitemapList) {
  $smCode = "unknown"
  $locCount = "unknown"
  $flagged = $false
  try {
    $smCode = (curl.exe -s -o /dev/null -w "%{http_code}" $sm).Trim()
    if ($smCode -eq "200") {
      $smBody = curl.exe -s $sm
      $locCount = ([regex]::Matches($smBody, '<loc>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).Count
    } else {
      $flagged = $true
    }
  } catch {
    $smCode = "error"
    $flagged = $true
  }
  $sitemapResults += [PSCustomObject]@{
    Url = $sm
    Status = $smCode
    LocCount = $locCount
    Flagged = $flagged
  }
}

# 2. Hub checks
Write-Host "Checking hub sza.od.ua..."
$hubHttpCode = "unknown"
$hubRedirectUrl = ""
try {
  $resp = (curl.exe -s -o /dev/null -w "%{http_code} %{redirect_url}" http://sza.od.ua/).Trim()
  $parts = $resp -split '\s+'
  $hubHttpCode = $parts[0]
  if ($parts.Length -gt 1) { $hubRedirectUrl = $parts[1] }
} catch {
  $hubHttpCode = "error"
}

# Hub git & sitemap lastmod
$gitLastMod = ""
try {
  $gitLastMod = (git log -1 --format=%as index.html).Trim()
} catch {
  $gitLastMod = "unknown"
}

$sitemapLastMod = "unknown"
$sitemapXmlPath = Join-Path $repoRoot "sitemap.xml"
if (Test-Path $sitemapXmlPath) {
  $smContent = Get-Content $sitemapXmlPath -Raw
  if ($smContent -match '<lastmod>([^<]+)</lastmod>') {
    $sitemapLastMod = $Matches[1].Trim()
  }
}

# GitHub API checks for hub
$hubGhStars = "unknown"
$hubGhForks = "unknown"
$hubGhHomepage = "unknown"
$hubGhTopics = "unknown"
$hubGhCustomOg = "unknown"
$hubGhViews = "unknown"
$hubGhUniques = "unknown"

try {
  $repoJson = gh api repos/SerZhyAle/sza.od.ua --jq '{stargazers_count,forks_count,homepage,topics}' 2>$null | ConvertFrom-Json
  if ($repoJson) {
    $hubGhStars = $repoJson.stargazers_count
    $hubGhForks = $repoJson.forks_count
    $hubGhHomepage = if ($repoJson.homepage) { $repoJson.homepage } else { "null" }
    $hubGhTopics = ($repoJson.topics -join ", ")
    if (-not $hubGhTopics) { $hubGhTopics = "[]" }
  }
} catch {}

try {
  $ogRes = (gh api graphql -f query='query { repository(owner:"SerZhyAle", name:"sza.od.ua") { usesCustomOpenGraphImage } }' --jq '.data.repository.usesCustomOpenGraphImage' 2>$null).Trim()
  if ($ogRes) { $hubGhCustomOg = $ogRes }
} catch {}

try {
  $trafficJson = gh api repos/SerZhyAle/sza.od.ua/traffic/views --jq '{count,uniques}' 2>$null | ConvertFrom-Json
  if ($trafficJson) {
    $hubGhViews = $trafficJson.count
    $hubGhUniques = $trafficJson.uniques
  }
} catch {}

# 3. Dependent product tickets
Write-Host "Checking dependent product tickets..."
$dependentTickets = @(
  @{ Repo = "FileDo"; Path = "P:\WINDOWS\FileDo\PLAN\SP-0166 free-promotion-campaign.md"; BaseDir = "P:\WINDOWS\FileDo" },
  @{ Repo = "Streams_Player"; Path = "P:\WINDOWS\Streams_Player\PLAN\SP-0039_free_promotion_campaign.md"; BaseDir = "P:\WINDOWS\Streams_Player" },
  @{ Repo = "CyrFlip"; Path = "P:\WINDOWS\CyrFlip\PLAN\S0024_free-promotion-campaign.md"; BaseDir = "P:\WINDOWS\CyrFlip" },
  @{ Repo = "FastMediaSorter_mob_v2"; Path = "P:\ANDROID\FastMediaSorter_mob_v2\PLAN\S1268_search-engine-registration-and-free-promotion.md"; BaseDir = "P:\ANDROID\FastMediaSorter_mob_v2" },
  @{ Repo = "FastMediaSorter_Lite"; Path = "P:\WINDOWS\FastMediaSorter_Lite\docs\specifications\186_SPECIFICATION_FREE_PROMOTION_CAMPAIGN.md"; BaseDir = "P:\WINDOWS\FastMediaSorter_Lite" },
  @{ Repo = "EPUB_2_HTML"; Path = "P:\WINDOWS\EPUB_2_HTML\DEV\plan\111_2026-10-09_free-promotion-campaign.md"; BaseDir = "P:\WINDOWS\EPUB_2_HTML" },
  @{ Repo = "OneClickRunner"; Path = "P:\WINDOWS\OneClickRunner\PLAN\T0028_free-promotion-campaign.md"; BaseDir = "P:\WINDOWS\OneClickRunner" },
  @{ Repo = "universal-agent-kit"; Path = "P:\WEB\universal-agent-kit\docs\specifications\SPECIFICATION_FREE_PROMOTION_CAMPAIGN.md"; BaseDir = "P:\WEB\universal-agent-kit" },
  @{ Repo = "StreamsPlayer_mob"; Path = "P:\ANDROID\StreamsPlayer_mob\PLAN\S0014_free-promotion-campaign.md"; BaseDir = "P:\ANDROID\StreamsPlayer_mob" },
  @{ Repo = "Tourist_mob"; Path = "P:\ANDROID\Tourist_mob\PLAN\S0012_free-promotion-campaign.md"; BaseDir = "P:\ANDROID\Tourist_mob" }
)

$productReports = @()
foreach ($item in $dependentTickets) {
  $repoName = $item.Repo
  $ticketExists = Test-Path $item.Path
  $checkpointPath = "no checkpoint path"
  $checkpointDate = "unknown"
  $metricData = "unknown"

  if ($ticketExists) {
    $content = Get-Content $item.Path -Raw
    # Extract Metrics section
    if ($content -match '(?ms)##\s*(\d+\.\s*)?Metrics\s*\r?\n(.*?)(?=\r?\n##\s*|\Z)') {
      $metricsSec = $Matches[2].Trim()

      # Check if a separate checkpoint / baseline file path is explicitly named
      if ($metricsSec -match '(?i)(?:Baseline|Checkpoint):\s*[`"\'']?([a-zA-Z0-9_\-/\\]+\.md)[`"\'']?') {
        $namedRelPath = $Matches[1]
        $fullPath = Join-Path $item.BaseDir $namedRelPath
        if (Test-Path $fullPath) {
          $checkpointPath = $namedRelPath
          $checkpointDate = $Date
          $cpContent = Get-Content $fullPath -Raw
          $metricData = "From $($namedRelPath): " + ($cpContent.Trim() -replace '\r?\n', ' ')
        } else {
          $checkpointPath = "$namedRelPath (file not created yet)"
          $metricData = "Named in ticket but file absent"
        }
      } else {
        # Checkpoint is recorded inline in the Metrics section
        # Look for table row or checkpoint text matching Date or baseline
        $lines = $metricsSec -split '\r?\n'
        $matchedLine = ""
        foreach ($ln in $lines) {
          if ($ln -match $Date -or $ln -match 'baseline' -or $ln -match 'Checkpoint') {
            $matchedLine = $ln.Trim()
            break
          }
        }
        if ($matchedLine) {
          $checkpointPath = "inline in ticket"
          $checkpointDate = $Date
          $metricData = $matchedLine
        } else {
          $checkpointPath = "inline in ticket"
          $metricData = ($metricsSec -split '\r?\n')[0]
        }
      }
    } else {
      $metricData = "no metrics section found"
    }
  } else {
    $metricData = "ticket file not found"
  }

  $productReports += [PSCustomObject]@{
    Repo = $repoName
    TicketPath = $item.Path
    CheckpointPath = $checkpointPath
    Metrics = $metricData
  }
}

# 4. Assemble Markdown report
$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("# Portfolio Promotion Checkpoint - $Date")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')")
[void]$sb.AppendLine("**Contract:** canon `PROMOTION.md` section 7 and `PLAN-2026-10-09-free-promotion-campaign.md` (P6)")
[void]$sb.AppendLine("")
[void]$sb.AppendLine('## 1. Host Root (`serzhyale.github.io`)')
[void]$sb.AppendLine("")
[void]$sb.AppendLine("- ``https://serzhyale.github.io/robots.txt`` HTTP status: **$robotsCode**")
if ($robotsCode -ne "200") {
  [void]$sb.AppendLine("  > Note: Live host root returns $robotsCode (P1 step 4 pending outward deploy to SerZhyAle.github.io). Checked sitemaps against source ``github-root-redirect/robots.txt``.")
}
[void]$sb.AppendLine("")
[void]$sb.AppendLine('| Project Sitemap | Status | `<loc>` count | Flagged (needs P1 step 5) |')
[void]$sb.AppendLine("| --- | --- | --- | --- |")
foreach ($r in $sitemapResults) {
  $flagStr = if ($r.Flagged) { "**YES (status $($r.Status))**" } else { "no" }
  [void]$sb.AppendLine("| ``$($r.Url)`` | $($r.Status) | $($r.LocCount) | $flagStr |")
}
[void]$sb.AppendLine("")

[void]$sb.AppendLine('## 2. Hub (`sza.od.ua`)')
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| Metric / Indicator | Value |")
[void]$sb.AppendLine("| --- | --- |")
[void]$sb.AppendLine("| ``http://sza.od.ua/`` status | $hubHttpCode $(if ($hubRedirectUrl) { "-> $hubRedirectUrl" } else { "(no redirect)" }) |")
[void]$sb.AppendLine("| Sitemap ``lastmod`` | $sitemapLastMod |")
[void]$sb.AppendLine("| ``index.html`` git commit date | $gitLastMod |")
[void]$sb.AppendLine("| GitHub Stars / Forks | $hubGhStars / $hubGhForks |")
[void]$sb.AppendLine("| GitHub Homepage | $hubGhHomepage |")
[void]$sb.AppendLine("| GitHub Topics | $hubGhTopics |")
[void]$sb.AppendLine("| ``usesCustomOpenGraphImage`` (GraphQL) | $hubGhCustomOg |")
[void]$sb.AppendLine("| Traffic Views (14-day) | $hubGhViews (uniques: $hubGhUniques) |")
[void]$sb.AppendLine("")

[void]$sb.AppendLine("## 3. Dependent Products")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| Product Repo | Checkpoint Path | Recorded Metrics |")
[void]$sb.AppendLine("| --- | --- | --- |")
foreach ($p in $productReports) {
  [void]$sb.AppendLine("| $($p.Repo) | $($p.CheckpointPath) | $($p.Metrics) |")
}
[void]$sb.AppendLine("")

[void]$sb.AppendLine("## 4. Search Consoles & Webmaster Tools")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| Surface | Property | Status / Impressions / Clicks | Discovered / Indexed |")
[void]$sb.AppendLine("| --- | --- | --- | --- |")
[void]$sb.AppendLine('| Host Root GSC | `https://serzhyale.github.io/` | unknown (awaiting P2 verification) | unknown |')
[void]$sb.AppendLine('| Host Root Bing | `https://serzhyale.github.io/` | unknown (awaiting P2 import) | unknown |')
[void]$sb.AppendLine('| Hub GSC | `sza.od.ua` | unknown (awaiting P4 step 3 DNS verification) | unknown |')
[void]$sb.AppendLine('| Hub Bing | `sza.od.ua` | unknown (awaiting P4 step 3 Bing import) | unknown |')
[void]$sb.AppendLine("")

[System.IO.File]::WriteAllText($OutputPath, $sb.ToString(), [System.Text.Encoding]::UTF8)

Write-Host "Checkpoint successfully written to: $OutputPath"
