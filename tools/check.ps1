<#
check.ps1 - run the SZA canon compliance gate against this repo.

The gate itself ships with the `sza` plugin (sza-unified-rules); this wrapper only finds it. Resolving the
plugin root here rather than in prose is the point: CLAUDE_PLUGIN_ROOT is expanded for the plugin's own hook
registrations and is NOT exported into a tool shell, so a hand-typed
`pwsh -File "$env:CLAUDE_PLUGIN_ROOT/tools/check-compliance.ps1"` expands to `/tools/check-compliance.ps1`
and dies with exit 64.

Exit codes: 0 = clean (or gate unavailable, see below); 1 = the repo violates the canon.

The gate is a developer-machine convenience, not a dependency of the site. When the plugin is not installed
the wrapper prints SKIPPED and exits 0, so a publish from a machine without it still works.
#>
[CmdletBinding()]
param([switch]$Strict)

$ErrorActionPreference = 'Stop'

function Resolve-CanonRoot {
    if ($env:CLAUDE_PLUGIN_ROOT -and (Test-Path -LiteralPath (Join-Path $env:CLAUDE_PLUGIN_ROOT 'tools/check-compliance.ps1'))) {
        return $env:CLAUDE_PLUGIN_ROOT
    }
    $installed = Join-Path $HOME '.claude/plugins/installed_plugins.json'
    if (Test-Path -LiteralPath $installed) {
        $entry = (Get-Content $installed -Raw | ConvertFrom-Json).plugins.'sza@sza-unified-rules' |
                 Sort-Object lastUpdated -Descending | Select-Object -First 1
        if ($entry -and $entry.installPath -and (Test-Path -LiteralPath (Join-Path $entry.installPath 'tools/check-compliance.ps1'))) {
            return $entry.installPath
        }
    }
    return $null
}

$canonRoot = Resolve-CanonRoot
if (-not $canonRoot) {
    Write-Host "check-compliance: SKIPPED - the sza plugin is not installed on this machine."
    Write-Host "  install it with: /plugin marketplace add SerZhyAle/sza-unified-rules"
    Write-Host "                   /plugin install sza@sza-unified-rules"
    exit 0
}

$repoRoot = Split-Path -Parent $PSScriptRoot
Write-Host "check-compliance: canon at $canonRoot"
$gateArgs = @('-NoProfile', '-File', (Join-Path $canonRoot 'tools/check-compliance.ps1'), '-RepoRoot', $repoRoot)
if ($Strict) { $gateArgs += '-Strict' }
& pwsh @gateArgs
exit $LASTEXITCODE
