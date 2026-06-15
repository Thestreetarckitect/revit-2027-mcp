<div align="center">

<img src="https://img.shields.io/badge/Revit-2027-0070AD?style=for-the-badge&logo=autodesk&logoColor=white"/>
<img src="https://img.shields.io/badge/Claude-MCP-D97757?style=for-the-badge&logo=anthropic&logoColor=white"/>
<img src="https://img.shields.io/badge/Tools-150%2B-7B2D8B?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Version-0.5.0-2EA043?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Windows-10%2F11-0078D4?style=for-the-badge&logo=windows&logoColor=white"/>

<br/><br/>

# Revit 2027 MCP

**Claude MCP integration for Autodesk Revit 2027.**  
Exposes 150+ Revit API tools directly to Claude — query, create, modify, export, clash detect, and automate your BIM model using natural language.

> *"Think of MCP like a USB-C port for AI — one standard that connects to anything."*

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
Claude (MCP client)
      ↕  stdio
rvt-mcp.exe  (MCP server — .NET 8 self-contained)
      ↕  HTTP / named pipe
RvtMcp.Plugin.dll  (Revit addin)
      ↕  Revit API
.rvt model
```

**Flow:** ① User writes natural language → ② Claude picks the right MCP tool → ③ Server translates to Revit API call → ④ Plugin runs it inside Revit → ⑤ Result streams back to Claude

> Claude never touches Revit directly — it sends structured commands that the plugin interprets and runs inside Revit's API.

---

## ⚙️ Requirements

| Requirement | Details |
|-------------|---------|
| **Revit** | Autodesk Revit 2027 |
| **OS** | Windows 10 / 11 x64 |
| **Claude** | Claude Desktop or Claude Code with MCP support |

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

## 🔌 Claude MCP Config

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

## ✅ What Claude Can Do in Revit

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
| **No visual access** | Claude cannot see 3D views or screenshots — interaction is purely data-driven |
| **Complex geometry** | Free-form surfaces and intricate solid operations often fail |
| **Code review required** | AI-generated C# code must be reviewed before running on production models |
| **Claude Desktop only** | MCP requires Claude Desktop or Claude Code — the web version does not support MCP |
| **Revit API boundaries** | Some read-only contexts block writes; Claude is bound by the same rules as any plugin |
| **Prompt precision** | Vague prompts lead to wrong tool calls — specific prompts dramatically improve accuracy |

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
6. Export results → HTML or JSON report; Claude has no memory between sessions
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

## 👤 Credits

Workshop material and prompt strategies adapted from the **"Revit × Claude MCP Workshop"** slide deck by **Abdelrhman Hosny**, BIM/VDC Engineer.

---

<div align="center">

**Server:** `0.5.0` &nbsp;|&nbsp; **Addin:** `RvtMcp.R27` (Revit 2027 API) &nbsp;|&nbsp; **Tools:** 150+

*Claude MCP integration for Autodesk Revit 2027*

</div>
