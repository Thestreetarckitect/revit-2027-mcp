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

Write-Host ""
Write-Host "Done. Add this to your Claude MCP config (~/.claude.json mcpServers):"
Write-Host ""
Write-Host '  "rvt-mcp": {'
Write-Host '    "command": "' + $serverTarget.Replace("\","\\") + '\\rvt-mcp.exe",'
Write-Host '    "args": []'
Write-Host '  }'
Write-Host ""
Write-Host "Then open Revit 2027 and verify the RvtMcp addin loads."
