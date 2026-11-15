#Requires -Version 5.1
<#
.SYNOPSIS
  Install RvtMcp v1.2.2 for Revit 2025, 2026 and 2027 (per user, no admin).

.DESCRIPTION
  Wraps the unmodified upstream installer in setup\install.ps1, which:
    - detects every installed Revit year (a year counts when Revit.exe exists)
    - installs the matching add-in for each year
    - installs the MCP server at
      %LOCALAPPDATA%\Bimwright\rvt-mcp\server\current\rvt-mcp.exe
    - wires detected MCP clients (Claude, Cursor, VS Code and others)

  After the upstream install this wrapper adds one thing: a copy of the server
  in %USERPROFILE%\Documents\Codex\rvt-mcp\. The Codex desktop app runs in a
  Windows AppContainer and cannot launch executables from %LOCALAPPDATA%.

  setup\ holds the upstream Setup package byte for byte. Its manifest.json
  carries SHA-256 checksums that the upstream installer verifies, so do not edit
  files inside setup\.

.PARAMETER Years
  Limit the install to specific Revit years, for example -Years 2026.

.PARAMETER Client
  MCP clients to wire. Omitted: every detected client. Use none to skip wiring.

.PARAMETER Uninstall
  Remove the add-ins and the Codex copy of the server.

.PARAMETER PruneOldServers
  Remove old version-named server folders such as 0.5.0 after a good install.

.EXAMPLE
  .\install.ps1 -WhatIf
  .\install.ps1
  .\install.ps1 -Years 2025,2026 -Client claude
  .\install.ps1 -Client none
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateRange(2022, 2027)][int[]]$Years,
    [string[]]$Client,
    [switch]$Uninstall,
    [switch]$PruneOldServers
)

$ErrorActionPreference = 'Stop'

$upstream = Join-Path $PSScriptRoot 'setup\install.ps1'
if (-not (Test-Path -LiteralPath $upstream)) {
    throw "Missing setup\install.ps1. Re-clone the repository or download it again."
}

$forward = @{}
if ($Years)           { $forward['Years'] = $Years }
if ($Client)          { $forward['Client'] = $Client }
if ($Uninstall)       { $forward['Uninstall'] = $true }
if ($PruneOldServers) { $forward['PruneOldServers'] = $true }
if ($WhatIfPreference) { $forward['WhatIf'] = $true }

& $upstream @forward
if (-not $?) { throw 'The upstream installer reported an error. The Codex copy was not touched.' }

$serverCurrent = Join-Path $env:LOCALAPPDATA 'Bimwright\rvt-mcp\server\current'
$codexTarget   = Join-Path $env:USERPROFILE 'Documents\Codex\rvt-mcp'

if ($WhatIfPreference) {
    Write-Host "What if: would copy the server to $codexTarget"
    return
}

if ($Uninstall) {
    if (Test-Path -LiteralPath $codexTarget) {
        Remove-Item -LiteralPath $codexTarget -Recurse -Force
        Write-Host "Removed Codex server copy: $codexTarget"
    }
    return
}

if (-not (Test-Path -LiteralPath (Join-Path $serverCurrent 'rvt-mcp.exe'))) {
    Write-Warning "Server not found at $serverCurrent. Skipping the Codex copy."
    return
}

Write-Host ''
Write-Host 'Installing server copy for Codex...'
New-Item -ItemType Directory -Force $codexTarget | Out-Null
# The server needs its native SQLite library next to the exe, so copy the folder.
Copy-Item -Path (Join-Path $serverCurrent '*') -Destination $codexTarget -Recurse -Force
Write-Host "  Codex server deployed to $codexTarget"

$codexExe = Join-Path $codexTarget 'rvt-mcp.exe'
Write-Host ''
Write-Host '--- OpenAI Codex  ->  %USERPROFILE%\.codex\config.toml ---' -ForegroundColor Cyan
Write-Host ''
Write-Host '  [mcp_servers.rvt-mcp]'
Write-Host "  command = '$codexExe'"
Write-Host '  args = []'
Write-Host '  startup_timeout_sec = 30'
Write-Host '  tool_timeout_sec = 120'
Write-Host ''
Write-Host 'If the installer already wired Codex to the %LOCALAPPDATA% path, replace that command with the path above and restart Codex.'
Write-Host 'Run one client at a time. Two clients cannot drive the same Revit instance.' -ForegroundColor Yellow
Write-Host 'Then open Revit 2025, 2026 or 2027 and confirm the RvtMcp add-in loads.'
