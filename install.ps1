# RvtMcp Install Script for Revit 2027
# Run as standard user (no admin required — deploys to %APPDATA%)

$ErrorActionPreference = "Stop"
$addinTarget = "$env:APPDATA\Autodesk\Revit\Addins\2027"
$serverTarget = "$env:LOCALAPPDATA\RvtMcp\rvt\server\0.5.0"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host "Installing RvtMcp addin..."
New-Item -ItemType Directory -Force $addinTarget | Out-Null
New-Item -ItemType Directory -Force "$addinTarget\RvtMcp" | Out-Null
Copy-Item "$scriptDir\addin\RvtMcp.R27.addin" "$addinTarget\RvtMcp.R27.addin" -Force
Copy-Item "$scriptDir\addin\*.dll" "$addinTarget\RvtMcp\" -Force
Write-Host "  Addin deployed to $addinTarget"

Write-Host "Installing MCP server..."
New-Item -ItemType Directory -Force $serverTarget | Out-Null
Copy-Item "$scriptDir\server\rvt-mcp.exe" "$serverTarget\rvt-mcp.exe" -Force
Copy-Item "$scriptDir\server\RvtMcp.Server.pdb" "$serverTarget\RvtMcp.Server.pdb" -Force
Write-Host "  Server deployed to $serverTarget"

# Codex Desktop runs in an AppContainer and cannot launch executables from
# %LOCALAPPDATA%. It can launch them from Documents\Codex, so drop a copy there.
$codexTarget = "$env:USERPROFILE\Documents\Codex\rvt-mcp"
Write-Host "Installing MCP server for Codex..."
New-Item -ItemType Directory -Force $codexTarget | Out-Null
Copy-Item "$scriptDir\server\rvt-mcp.exe" "$codexTarget\rvt-mcp.exe" -Force
Write-Host "  Codex server deployed to $codexTarget"

$exePath  = Join-Path $serverTarget 'rvt-mcp.exe'
$exeJson  = $exePath.Replace('\', '\\')
$codexExe = Join-Path $codexTarget 'rvt-mcp.exe'

Write-Host ""
Write-Host "Done. The server speaks stdio, so any MCP client can use it."
Write-Host "Pick the config for the client you run:"
Write-Host ""
Write-Host "--- Claude Code / Claude Desktop  ->  ~/.claude.json  (mcpServers) ---" -ForegroundColor Cyan
Write-Host ""
Write-Host '  "rvt-mcp": {'
Write-Host "    `"command`": `"$exeJson`","
Write-Host '    "args": []'
Write-Host '  }'
Write-Host ""
Write-Host "--- OpenAI Codex  ->  %USERPROFILE%\.codex\config.toml ---" -ForegroundColor Cyan
Write-Host ""
Write-Host '  [mcp_servers.rvt-mcp]'
Write-Host "  command = '$codexExe'"
Write-Host '  args = []'
Write-Host '  startup_timeout_sec = 30'
Write-Host '  tool_timeout_sec = 120'
Write-Host ""
Write-Host "  Then restart Codex."
Write-Host ""
Write-Host "Run one client at a time - two clients cannot drive the same Revit instance." -ForegroundColor Yellow
Write-Host "Then open Revit 2027 and verify the RvtMcp addin loads."
Write-Host "Codex details: docs/mcp-config-codex.md"
