<div align="center">

<img src="https://img.shields.io/badge/Revit-2027-0070AD?style=for-the-badge&logo=autodesk&logoColor=white"/>
<img src="https://img.shields.io/badge/Claude-MCP-D97757?style=for-the-badge&logo=anthropic&logoColor=white"/>
<img src="https://img.shields.io/badge/Codex_CLI-GPT--6_Astra-000000?style=for-the-badge&logo=openai&logoColor=white"/>
<img src="https://img.shields.io/badge/Tools-150%2B-7B2D8B?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Version-0.5.0-2EA043?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Windows-10%2F11-0078D4?style=for-the-badge&logo=windows&logoColor=white"/>

<br/><br/>

# Revit 2027 MCP

**MCP integration for Autodesk Revit 2027.**  
Exposes 150+ Revit API tools over the Model Context Protocol — query, create, modify, export, clash detect, and automate your BIM model using natural language. Built and documented against Claude Desktop and Claude Code, and confirmed working with Codex CLI running GPT-6 Astra, since MCP is a client-agnostic stdio standard, not a Claude-only feature.

> *"Think of MCP like a USB-C port for AI — one standard that connects to anything, Claude or Codex included."*

</div>

---

## 📋 What's Inside

| # | Section | Description |
|---|---------|-------------|
| 🏗️ | **Architecture** | How Claude connects to Revit via MCP |
| ⚙️ | **Requirements & Install** | Prerequisites and one-command setup |
| 🔧 | **150+ Tools** | Full capability reference by category |
| ✅ | **What Claude Can Do** | Read, analyze, modify, automate |
| ⚠️ | **Known Limits** | Constraints to understand before you start |
| 💬 | **Prompt Strategies** | Templates, role-setting, cheat sheet |
| 🚀 | **Use Cases** | Real examples by discipline |
| 🌐 | **Resources** | Links, docs, community |

---

## 🏗️ Architecture

```
AI client (MCP)  —  Claude Desktop / Claude Code, or Codex CLI (GPT-6 Astra)
      ↕  stdio
rvt-mcp.exe  (MCP server — .NET 8 self-contained)
      ↕  named pipe + auth token
RvtMcp.Plugin.dll  (Revit addin)
      ↕  Revit API
.rvt model
```

**Flow:** ① User writes natural language → ② the MCP client picks the right tool → ③ the server translates it to a Revit API call → ④ the plugin runs it inside Revit → ⑤ the result streams back to the client

> The AI client never touches Revit directly — it sends structured commands over MCP that the plugin interprets and runs inside Revit's API. That's true whether the client is Claude or Codex.

---

## ⚙️ Requirements

| Requirement | Details |
|-------------|---------|
| **Revit** | Autodesk Revit 2027 |
| **OS** | Windows 10 / 11 x64 |
| **MCP client** | Claude Desktop or Claude Code with MCP support, **or** Codex CLI with an `mcp_servers` entry (tested running GPT-6 Astra) |

---

## 🚀 Quick Start

```powershell
.\install.ps1
```

Deploys automatically — no admin required:

| Destination | Contents |
|-------------|----------|
| `%APPDATA%\Autodesk\Revit\Addins\2027\RvtMcp\` | Addin manifest + DLL |
| `%LOCALAPPDATA%\RvtMcp\rvt\server\0.5.0\` | MCP server exe |

---

## 🔌 MCP Client Config

### Claude Desktop / Claude Code

Add to `~/.claude.json` under `mcpServers`:

```json
"rvt-mcp": {
  "command": "C:\\Users\\<user>\\AppData\\Local\\RvtMcp\\rvt\\server\\0.5.0\\rvt-mcp.exe",
  "args": []
}
```

**Verify connection:**
1. Open Revit 2027 — addin loads automatically on startup
2. In Claude, run: `get current view info` — should return Revit model state
3. Check `%LOCALAPPDATA%\RvtMcp\revit-mcp.log` if something fails

### Codex CLI (GPT-6 Astra)

> ⚠️ **Codex CLI works. Codex Desktop does not.** Desktop ships as a Microsoft Store
> MSIX package and runs inside a Windows AppContainer, which cannot see `rvt-mcp.exe`
> in `%LOCALAPPDATA%` regardless of file permissions. `codex doctor` reports the
> executable as "not found at its configured path" while the file is demonstrably
> there. Granting ACLs does not help — AppContainer access is capability-gated, not
> ACL-gated. Full write-up in
> [docs/mcp-config-codex.md §1a](docs/mcp-config-codex.md).
>
> The CLI is a plain executable outside the package and works normally. Find it at
> `%LOCALAPPDATA%\OpenAI\Codex\bin\<hash>\codex.exe`, and launch it from an already-open
> terminal — it is a console app, so the Win+R Run box will appear to do nothing.

Point Codex at the same server executable, either the installed copy above or a local build path, then launch a normal Codex session:

```powershell
codex -c 'mcp_servers.rvt-mcp.command="C:/Users/<user>/AppData/Local/RvtMcp/rvt/server/0.5.0/rvt-mcp.exe"'
```

That flag is per-session. To register it permanently, add to `%USERPROFILE%\.codex\config.toml`:

```toml
[mcp_servers.rvt-mcp]
command = 'C:\Users\<user>\AppData\Local\RvtMcp\rvt\server\0.5.0\rvt-mcp.exe'
args = []
startup_timeout_sec = 30
tool_timeout_sec = 120
```

Confirm with `codex mcp get rvt-mcp`. (`Auth: Unsupported` in `codex mcp list` is normal
for stdio servers, not an error.)

**Verify connection:**
1. Open Revit 2027 — addin loads automatically on startup
2. Inside Codex, run `/mcp` — it should report `rvt-mcp: connected` with the tool count
3. Run `Get the current Revit view information.` — a response with the active view confirms the server is actually talking to Revit, not just that the tool list loaded
4. If Codex reports a connected tool server but calls fail, check for a named-pipe access error from a sandboxed session before assuming the addin is broken

---

## 🔧 150+ Available Tools

<details>
<summary><strong>🔍 Query & Model Info</strong></summary>

`get_current_view_info` · `get_element_details` · `get_element_parameters` · `get_element_bounding_box` · `get_element_geometry` · `get_element_relationships` · `ai_element_filter` · `analyze_model_statistics` · `get_model_warnings_summary` · `get_selected_elements` · `get_family_instances` · `get_available_family_types` · `list_loaded_families` · `list_materials` · `list_rooms` · `list_sheets` · `list_schedules` · `list_views` · `list_phases` · `list_worksets` · `get_current_target`

</details>

<details>
<summary><strong>✏️ Create Elements</strong></summary>

`create_wall` · `create_floor` · `create_room` · `create_level` · `create_grid` · `create_view` · `create_sheet` · `create_schedule` · `create_dimensions` · `create_text_note` · `create_detail_line` · `create_structural_column` · `create_structural_beam` · `create_structural_wall` · `create_foundation_isolated` · `create_foundation_wall` · `create_rebar_set` · `create_rebar_stirrup` · `create_duct` · `create_pipe` · `create_cable_tray` · `create_conduit` · `create_air_terminal` · `create_lighting_fixture` · `create_material` · `create_revision`

</details>

<details>
<summary><strong>🔄 Modify & Automate</strong></summary>

`assign_material_to_element` · `apply_view_template` · `override_element_graphics` · `set_parameter_value_by_guid` · `set_view_scale` · `set_view_crop` · `set_view_phase` · `set_category_visibility` · `set_element_phase` · `rename_family_type` · `duplicate_family_type` · `replace_family_type` · `renumber_sheets` · `batch_execute` · `send_code_to_revit`

</details>

<details>
<summary><strong>📤 Export</strong></summary>

`export_pdf` · `export_dwg` · `export_ifc` · `export_nwc` · `export_dwf` · `export_fbx` · `export_gbxml` · `export_dgn` · `export_image` · `export_schedule_csv` · `export_elements_data` · `export_room_data` · `batch_export_sheets`

</details>

<details>
<summary><strong>🔎 Clash & QC</strong></summary>

`clash_detection` · `find_overlapping_elements` · `find_elements_in_volume` · `find_untagged_elements` · `find_undimensioned_elements` · `find_mep_disconnects` · `get_model_warnings_summary` · `audit_families` · `purge_unused`

</details>

<details>
<summary><strong>📐 MEP & Structural</strong></summary>

`analyze_mep_network` · `connect_mep_elements` · `get_mep_element_connectors` · `get_panel_schedule` · `list_mep_systems` · `get_system_inventory` · `get_structural_loads` · `set_structural_load` · `analyze_structural_connections`

</details>

<details>
<summary><strong>🧰 Workflows & Baked Tools</strong></summary>

`workflow_clash_review` · `workflow_model_audit` · `workflow_sheet_set` · `workflow_view_cleanup` · `workflow_room_documentation` · `workflow_naming_normalization` · `workflow_takeoff_report` · `workflow_data_roundtrip` · `list_baked_tools` · `run_baked_tool`

</details>

---

## ✅ What Claude or Codex Can Do in Revit

**Read & Query**
- Query any element by category, type, level, or parameter
- Get model metadata — file path, version, project info
- Navigate view / sheet / level hierarchy
- Access all built-in and shared parameters

**Analyze & Report**
- Count and aggregate elements by any filter
- Generate formatted HTML tables in chat
- Detect naming standard violations
- Compare element sets across phases

**Modify & Automate**
- Create, move, and delete elements via Revit API
- Batch update parameters across hundreds of elements
- Rename views, sheets, and families at scale
- Execute custom C# or Python code inside Revit

---

## ⚠️ Known Limits

| Limit | Details |
|-------|---------|
| **No visual access** | The AI client cannot see 3D views or screenshots — interaction is purely data-driven |
| **Complex geometry** | Free-form surfaces and intricate solid operations often fail |
| **Code review required** | AI-generated C# code must be reviewed before running on production models |
| **Local MCP client required** | Needs a client with MCP support — Claude Desktop, Claude Code, or Codex CLI. Claude's web version does not support MCP |
| **Revit API boundaries** | Some read-only contexts block writes; the client is bound by the same rules as any plugin |
| **Prompt precision** | Vague prompts lead to wrong tool calls — specific prompts dramatically improve accuracy |
| **Tool count drift** | The tool count a client reports can lag this README if you're running a newer local build than the tagged release |

---

## 💬 Prompt Strategies

### 1️⃣ Set a BIM Expert Role First

Start every session with this system prompt:

```
You are a BIM expert working in Revit 2027.
Use only available MCP tools and confirm before making large edits.
```

This dramatically improves tool selection accuracy and prevents unintended writes.

---

### 2️⃣ Recommended Session Workflow

```
1. Open Revit project (active model = what Claude reads)
2. Set role in Claude (BIM expert prompt above)
3. Orient the model → "What is this model? List levels, disciplines, major element counts."
4. Run targeted queries → specific, filtered reads first
5. Execute edits carefully → always ask for preview before batch writes
6. Export results → HTML or JSON report; neither Claude nor Codex retains memory between sessions
```

---

### 3️⃣ Prompt Cheat Sheet

| Task | Template |
|------|----------|
| **List by filter** | `List all [CATEGORY] on [LEVEL] where [PARAM] = [VALUE]` |
| **Count & aggregate** | `Count [CATEGORY] grouped by [PARAM] — output as a table` |
| **Compliance check** | `Find all [CATEGORY] where [PARAM] is empty or missing` |
| **Batch update** | `Set [PARAM] = [VALUE] for all [CATEGORY] of type [TYPE] — show me first` |
| **Rename systematically** | `Rename all [CATEGORY] views using pattern [FORMAT]` |
| **HTML report** | `Generate an HTML report of [CATEGORY] including columns: [PARAMS]` |
| **JSON / CSV export** | `Export all [CATEGORY] with [PARAMS] as comma-separated rows` |
| **Sheet setup** | `Create sheets for all [VIEW TYPE] views, number them [FORMAT]` |

> **Tip:** Always append "show me what you will change" before confirming any write. For batch edits, ask Claude to list element IDs first, then confirm before applying.

---

### 4️⃣ Real-World Prompt Examples by Use Case

<details>
<summary><strong>🏛️ Model Audit & Data Extraction</strong></summary>

```
List all walls on Level 1 — show type name, length, and fire rating parameter.
Flag any rows where fire rating is empty.
```

```
How many doors are in the model and which rooms do they serve?
Group by room name.
```

```
Show me all families where the Manufacturer parameter is blank.
```

</details>

<details>
<summary><strong>🔧 MEP QA/QC & Standards Checking</strong></summary>

```
Find all rooms with no area or a missing room number.
Return a non-compliance list with element IDs.
```

```
Check if all pipe systems have a System Abbreviation parameter filled in.
Return a pass/fail table sorted by system type.
```

```
List all unconnected pipe ends in the model.
```

</details>

<details>
<summary><strong>📄 Sheet Setup & Documentation</strong></summary>

```
Create a sheet for every floor plan view and number them A-101, A-102…
Confirm count of sheets before committing.
```

```
Generate an HTML report of all sheets: number, name, views placed, and revision date.
```

```
Rename all section views from "Sec X" format to "SEC-[number]-[level]".
```

</details>

<details>
<summary><strong>🔄 Batch Parameter Updates & Family Management</strong></summary>

```
Set Manufacturer = "ACME Corp" for all W-Shape structural columns.
Return updated count.
```

```
Find all doors where Mark is empty and auto-number them by room alphabetically.
Use format D-001, D-002...
```

```
List duplicate family names and suggest consolidation.
Group by naming similarity and present a plan for approval.
```

</details>

<details>
<summary><strong>🏗️ Structural Queries & Scheduling</strong></summary>

```
List all structural beams grouped by material with total length per group.
Output as a material takeoff summary.
```

```
Which columns have a Base Elevation that differs from their level elevation by more than 200mm?
```

```
Generate a JSON output of all foundations with their load bearing capacity parameter.
```

</details>

<details>
<summary><strong>🔍 Coordination Review & Model Health</strong></summary>

```
Find all elements placed on the wrong workset based on these rules:
- Walls → A-Shell workset
- MEP → M-Equipment workset
Flag non-conforming elements.
```

```
Show me all warning messages currently in the model, categorized by type.
Prioritize by frequency.
```

```
List all mechanical duct elements that cross Level 3 boundary without a proper offset.
```

</details>

<details>
<summary><strong>📊 Smart Reporting & Data Export</strong></summary>

```
Create a room data sheet as an HTML report.
Include: room name, number, area, finish, department.
Use zebra-row styling, sortable by department.
```

```
Build a door schedule grouped by floor level showing count, type, and fire rating.
Format as HTML table.
```

```
Export all element IDs and their parameters as comma-separated rows.
Include headers. Format for Excel import.
```

</details>

---

## 📁 Files

| Path | Purpose |
|------|---------|
| `addin/RvtMcp.R27.addin` | Revit addin manifest |
| `addin/RvtMcp.Plugin.dll` | Main addin assembly |
| `addin/*.dll` | Dependencies (SQLite, Newtonsoft.Json, etc.) |
| `server/rvt-mcp.exe` | MCP server exe (self-contained .NET 8, 98 MB) |
| `server/RvtMcp.Server.pdb` | Debug symbols |
| `revit-2027.json` | Revit 2027 model metadata snapshot |
| `install.ps1` | One-command install script |

---

## 🌐 Resources

| Resource | Link |
|----------|------|
| Anthropic MCP Docs | https://docs.anthropic.com/mcp |
| MCP Specification | https://modelcontextprotocol.io |
| Claude Desktop Download | https://claude.ai/download |
| Revit API Docs | https://revitapidocs.com |

---

## 👤 Credits & License

Built on **[RvtMcp](https://github.com/bimwright/rvt-mcp)** by bimwright — the MCP server
and Revit addin binaries redistributed here are their work, licensed **Apache-2.0**.
This repository packages v0.5.0 for Revit 2027 with a per-user installer and client
documentation. See [NOTICE](NOTICE) for full attribution and the list of changes.

Workshop material and prompt strategies adapted from the **"Revit × Claude MCP Workshop"** slide deck by **Abdelrhman Hosny**, BIM/VDC Engineer.

Licensed under the Apache License 2.0 — see [LICENSE](LICENSE).

Autodesk and Revit are trademarks of Autodesk, Inc. Claude is a trademark of Anthropic, PBC.
Codex is a trademark of OpenAI. This project is not affiliated with any of them.

---

<div align="center">

**Server:** `0.5.0` &nbsp;|&nbsp; **Addin:** `RvtMcp.R27` (Revit 2027 API) &nbsp;|&nbsp; **Tools:** 150+ &nbsp;|&nbsp; **Clients:** Claude, Codex CLI (GPT-6 Astra)

*MCP integration for Autodesk Revit 2027 — Claude and Codex CLI*

</div>
