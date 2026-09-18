<div align="center">

<img src="https://img.shields.io/badge/Revit-2027-0070AD?style=for-the-badge&logo=autodesk&logoColor=white"/>
<img src="https://img.shields.io/badge/Claude-MCP-D97757?style=for-the-badge&logo=anthropic&logoColor=white"/>
<img src="https://img.shields.io/badge/Codex-GPT--6_Astra-000000?style=for-the-badge&logo=openai&logoColor=white"/>
<img src="https://img.shields.io/badge/Tools-216-7B2D8B?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Version-0.5.0-2EA043?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Windows-10%2F11-0078D4?style=for-the-badge&logo=windows&logoColor=white"/>

<br/><br/>

# Revit 2027 MCP

**MCP integration for Autodesk Revit 2027.**  
Exposes 216 Revit API tools over the Model Context Protocol — query, create, modify, export, clash detect, and automate your BIM model using natural language. Built and documented against Claude Desktop and Claude Code, and confirmed working inside Codex running GPT-6 Astra, since MCP is a client-agnostic stdio standard, not a Claude-only feature.

> *"Think of MCP like a USB-C port for AI — one standard that connects to anything, Claude or Codex included."*

</div>

---

## 📋 What's Inside

| # | Section | Description |
|---|---------|-------------|
| 🏗️ | **Architecture** | How Claude connects to Revit via MCP |
| ⚙️ | **Requirements & Install** | Prerequisites and one-command setup |
| 🔧 | **216 Tools** | Full capability reference by category |
| ✅ | **What Claude Can Do** | Read, analyze, modify, automate |
| ⚠️ | **Known Limits** | Constraints to understand before you start |
| 💬 | **Prompt Strategies** | Templates, role-setting, cheat sheet |
| 🚀 | **Use Cases** | Real examples by discipline |
| 🌐 | **Resources** | Links, docs, community |

---

## 🏗️ Architecture

```
AI client (MCP)  —  Claude Desktop / Claude Code, or Codex (GPT-6 Astra)
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
| **MCP client** | Claude Desktop or Claude Code with MCP support, **or** Codex with an `mcp_servers` entry (tested running GPT-6 Astra) |

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
| `%USERPROFILE%\Documents\Codex\rvt-mcp\` | MCP server exe (copy for Codex) |

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

### Codex (GPT-6 Astra)

Works in the Codex app — no CLI needed. Two steps:

1. **Download and install.** Clone or download this repo and run `.\install.ps1`. It
   drops a Codex copy of the server at `%USERPROFILE%\Documents\Codex\rvt-mcp\rvt-mcp.exe`.
2. **Register it.** Add to `%USERPROFILE%\.codex\config.toml`, then restart Codex:

```toml
[mcp_servers.rvt-mcp]
command = 'C:\Users\<user>\Documents\Codex\rvt-mcp\rvt-mcp.exe'
args = []
startup_timeout_sec = 30
tool_timeout_sec = 120

# Ask before anything that executes arbitrary code in the model
[mcp_servers.rvt-mcp.tools.revit_send_code_to_revit]
approval_mode = "prompt"

[mcp_servers.rvt-mcp.tools.revit_batch_execute]
approval_mode = "prompt"
```

> **Why the separate copy?** The Codex app runs inside a Windows AppContainer and cannot
> launch executables from `%LOCALAPPDATA%` — it reports `rvt-mcp.exe` "not found" even
> though the file is there. It can launch them from `Documents\Codex\`, so the installer
> puts the same binary there. Re-run `install.ps1` after upgrading. Details in
> [docs/mcp-config-codex.md §1a](docs/mcp-config-codex.md).

**Verify connection:**
1. Open Revit 2027 — addin loads automatically on startup
2. Inside Codex, run `/mcp` — it should report `rvt-mcp: connected` with the tool count
3. Run `Get the current Revit view information.` — a response with the active view confirms the server is actually talking to Revit, not just that the tool list loaded
4. If Codex reports a connected tool server but calls fail, check for a named-pipe access error from a sandboxed session before assuming the addin is broken

---

## 🔧 216 Available Tools

Enumerated live from `rvt-mcp.exe` v0.5.0 via an MCP `tools/list` handshake.

<details>
<summary><strong>🔍 Query & Model Info</strong> · 42</summary>

`ai_element_filter` · `analyze_geometry_complexity` · `analyze_model_statistics` · `analyze_usage_patterns` · `compute_element_area` · `compute_element_volume` · `compute_room_finishes` · `delete_saved_selection` · `detect_firm_profile` · `detect_system_elements` · `find_elements_in_volume` · `find_overlapping_elements` · `get_assembly_members` · `get_available_family_types` · `get_current_target` · `get_current_view_info` · `get_element_bounding_box` · `get_element_centroid` · `get_element_details` · `get_element_geometry` · `get_element_parameters` · `get_element_relationships` · `get_family_instances` · `get_group_members` · `get_model_warnings_summary` · `get_selected_elements` · `get_type_parameters` · `list_assemblies` · `list_available_targets` · `list_groups` · `list_phases` · `list_saved_selections` · `list_worksets` · `load_selection` · `measure_distance_between_elements` · `project_point_onto_face` · `raycast_from_point` · `save_selection` · `select_elements` · `show_element_in_view` · `show_message` · `switch_target`

</details>

<details>
<summary><strong>✏️ Create Elements</strong> · 39</summary>

`audit_families` · `auto_create_rooms_from_walls` · `create_air_terminal` · `create_area` · `create_cable_tray` · `create_conduit` · `create_detail_line` · `create_dimensions` · `create_duct` · `create_filled_region` · `create_foundation_isolated` · `create_foundation_wall` · `create_grid` · `create_level` · `create_lighting_fixture` · `create_line_based_element` · `create_mep_fitting` · `create_pipe` · `create_point_based_element` · `create_rebar_set` · `create_rebar_stirrup` · `create_room` · `create_room_separator` · `create_space` · `create_structural_beam` · `create_structural_column` · `create_structural_wall` · `create_surface_based_element` · `create_text_note` · `duplicate_family_type` · `export_family_to_path` · `import_cad_to_view` · `list_family_types_in_family` · `list_linked_cad` · `list_loaded_families` · `load_family_from_path` · `rename_family_type` · `replace_family_type` · `unload_family`

</details>

<details>
<summary><strong>🏷️ Tagging & Annotation</strong> · 11</summary>

`apply_keynote_to_element` · `find_undimensioned_elements` · `find_untagged_elements` · `list_keynotes` · `tag_all_areas` · `tag_all_by_category` · `tag_all_rooms` · `tag_all_walls` · `tag_elements` · `tag_structural_framing` · `wipe_empty_tags`

</details>

<details>
<summary><strong>📋 Schedules, Sheets & Views</strong> · 50</summary>

`activate_view` · `add_schedule_field` · `analyze_sheet_layout` · `analyze_view_naming_patterns` · `apply_filter_to_view` · `apply_schedule_filter_sort` · `apply_view_template` · `assign_revision_to_sheet` · `batch_export_sheets` · `capture_view_image` · `create_callout_view` · `create_placeholder_sheet` · `create_revision` · `create_schedule` · `create_sheet` · `create_view` · `create_view_filter` · `create_view_sheet_set` · `create_view_template_from_view` · `delete_view_template` · `duplicate_sheet` · `duplicate_view_template` · `export_schedule_csv` · `find_schedule_elements` · `get_panel_schedule` · `get_print_settings` · `get_schedule_data` · `get_schedule_definition` · `get_schedule_formulas` · `get_titleblock_parameters` · `get_view_visibility` · `list_revisions` · `list_schedules` · `list_sheets` · `list_titleblocks` · `list_view_filters` · `list_view_templates` · `place_schedule_on_sheet` · `place_view_on_sheet` · `remove_filter_from_view` · `renumber_sheets` · `set_titleblock_parameters` · `set_view_crop` · `set_view_phase` · `set_view_scale` · `suggest_view_name_corrections` · `update_schedule_field` · `workflow_clash_review` · `workflow_sheet_set` · `workflow_view_cleanup`

</details>

<details>
<summary><strong>🎛️ Parameters & Materials</strong> · 20</summary>

`assign_material_to_element` · `bind_shared_parameter` · `create_material` · `create_project_parameter` · `create_shared_parameter` · `duplicate_material` · `export_shared_parameter_file` · `get_material_properties` · `get_material_quantities` · `get_material_takeoff` · `list_materials` · `list_project_parameter_bindings` · `list_project_parameters` · `list_shared_parameters` · `remove_parameter_binding` · `set_material_appearance` · `set_material_identity` · `set_material_structural_asset` · `set_material_thermal_asset` · `set_parameter_value_by_guid`

</details>

<details>
<summary><strong>🔄 Modify & Automate</strong> · 12</summary>

`batch_execute` · `clear_element_overrides` · `override_element_graphics` · `purge_unused` · `send_code_to_revit` · `set_category_visibility` · `set_element_phase` · `set_filter_overrides` · `set_project_base_point` · `set_project_info` · `set_structural_load` · `set_system_classification`

</details>

<details>
<summary><strong>📤 Export & Capture</strong> · 11</summary>

`export_dgn` · `export_dwf` · `export_dwg` · `export_elements_data` · `export_fbx` · `export_gbxml` · `export_ifc` · `export_image` · `export_nwc` · `export_pdf` · `export_room_data`

</details>

<details>
<summary><strong>🔎 Clash & QC</strong> · 2</summary>

`clash_detection` · `find_mep_disconnects`

</details>

<details>
<summary><strong>📐 MEP & Structural</strong> · 8</summary>

`analyze_mep_network` · `analyze_structural_connections` · `connect_mep_elements` · `get_mep_element_connectors` · `get_structural_loads` · `get_system_inventory` · `list_mep_systems` · `list_rebar`

</details>

<details>
<summary><strong>🔗 Links & Coordination</strong> · 7</summary>

`acquire_coordinates_from_link` · `get_link_elements` · `link_revit_model` · `list_linked_models` · `publish_coordinates_to_link` · `reload_link` · `unload_link`

</details>

<details>
<summary><strong>🏠 Rooms, Areas & Spaces</strong> · 5</summary>

`get_room_boundaries` · `get_room_openings` · `list_areas` · `list_rooms` · `workflow_room_documentation`

</details>

<details>
<summary><strong>🧰 Workflows & Baked Tools</strong> · 6</summary>

`list_baked_tools` · `run_baked_tool` · `workflow_data_roundtrip` · `workflow_model_audit` · `workflow_naming_normalization` · `workflow_takeoff_report`

</details>

<details>
<summary><strong>🧩 Other</strong> · 3</summary>

`create_group_from_elements` · `get_schedulable_fields` · `list_export_settings`

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
| **Local MCP client required** | Needs a client with MCP support — Claude Desktop, Claude Code, or Codex. Claude's web version does not support MCP |
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

**Server:** `0.5.0` &nbsp;|&nbsp; **Addin:** `RvtMcp.R27` (Revit 2027 API) &nbsp;|&nbsp; **Tools:** 216 &nbsp;|&nbsp; **Clients:** Claude, Codex (GPT-6 Astra)

*MCP integration for Autodesk Revit 2027 — Claude and Codex*

</div>
