# Revit 2027 MCP

Claude MCP integration for Autodesk Revit 2027. Exposes 150+ Revit API tools directly to Claude — elements, views, sheets, schedules, families, MEP, structural, clash detection, export, and more.

## Architecture

```
Claude (MCP client)
      ↕  stdio
rvt-mcp.exe  (MCP server — .NET 8 self-contained)
      ↕  HTTP / named pipe
RvtMcp.Plugin.dll  (Revit addin)
      ↕  Revit API
.rvt model
```

## Requirements

- Autodesk Revit **2027**
- Windows 10/11 x64
- Claude Desktop or Claude Code with MCP support

## Install

```powershell
.\install.ps1
```

Deploys:
- `addin\` → `%APPDATA%\Autodesk\Revit\Addins\2027\RvtMcp\`
- `server\rvt-mcp.exe` → `%LOCALAPPDATA%\RvtMcp\rvt\server\0.5.0\`

No admin required — installs to user profile.

## Claude MCP Config

Add to `~/.claude.json` under `mcpServers`:

```json
"rvt-mcp": {
  "command": "C:\\Users\\<user>\\AppData\\Local\\RvtMcp\\rvt\\server\\0.5.0\\rvt-mcp.exe",
  "args": []
}
```

## Verify

1. Open Revit 2027 — addin loads automatically on startup
2. In Claude, run: `get current view info` — should return Revit model state
3. Check `%LOCALAPPDATA%\RvtMcp\revit-mcp.log` if something fails

## Files

| Path | Purpose |
|---|---|
| `addin/RvtMcp.R27.addin` | Revit addin manifest |
| `addin/RvtMcp.Plugin.dll` | Main addin assembly |
| `addin/*.dll` | Dependencies (SQLite, Newtonsoft.Json, etc.) |
| `server/rvt-mcp.exe` | MCP server exe (self-contained .NET 8, 98 MB) |
| `server/RvtMcp.Server.pdb` | Debug symbols |
| `revit-2027.json` | Revit 2027 model metadata snapshot |
| `install.ps1` | One-command install script |

## Key Capabilities

- **Query**: elements by category/parameter, rooms, sheets, views, families
- **Create**: walls, floors, rooms, views, sheets, schedules, dimensions, tags, grids, levels
- **Modify**: parameters, materials, visibility, phases, view templates
- **MEP**: ducts, pipes, cable trays, conduits, system analysis
- **Structural**: columns, beams, foundations, rebar
- **Export**: PDF, DWG, IFC, NWC, DWF, images
- **Clash detection**: element overlap, clearance checks
- **Baked tools**: custom saved operations via `bake.db`
- **Multi-model**: switch between open Revit documents

## Version

Server: `0.5.0`  
Addin: `RvtMcp.R27` (Revit 2027 API)
