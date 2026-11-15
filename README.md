<div align="center">

<img src="https://img.shields.io/badge/Revit-2025%20%7C%202026%20%7C%202027-0070AD?style=for-the-badge&logo=autodesk&logoColor=white"/>
<img src="https://img.shields.io/badge/Claude-MCP-D97757?style=for-the-badge&logo=anthropic&logoColor=white"/>
<img src="https://img.shields.io/badge/Codex-GPT--6_Astra-000000?style=for-the-badge&logo=openai&logoColor=white"/>
<img src="https://img.shields.io/badge/Tools-242-7B2D8B?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Version-1.2.2-2EA043?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Windows-10%2F11-0078D4?style=for-the-badge&logo=windows&logoColor=white"/>

<br/><br/>

# Revit MCP for 2025, 2026 and 2027

**MCP integration for Autodesk Revit 2025, 2026 and 2027.**  
Exposes 242 Revit API tools over the Model Context Protocol — query, create, modify, export, clash detect, and automate your BIM model using natural language. Built and documented against Claude Desktop and Claude Code, and confirmed working inside Codex running GPT-6 Astra, since MCP is a client-agnostic stdio standard, not a Claude-only feature.

> *"Think of MCP like a USB-C port for AI — one standard that connects to anything, Claude or Codex included."*

</div>

---

## 📋 What's Inside

| # | Section | Description |
|---|---------|-------------|
| 🏗️ | **Architecture** | How Claude connects to Revit via MCP |
| ⚙️ | **Requirements & Install** | Prerequisites and one-command setup |
| 🔧 | **242 Tools** | Full capability reference by category |
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
rvt-mcp.exe  (MCP server, self-contained)
      ↕  named pipe + auth token
RvtMcp.Plugin.dll  (Revit addin, one build per Revit year)
      ↕  Revit API
.rvt model
```

**Flow:** ① User writes natural language → ② the MCP client picks the right tool → ③ the server translates it to a Revit API call → ④ the plugin runs it inside Revit → ⑤ the result streams back to the client

> The AI client never touches Revit directly — it sends structured commands over MCP that the plugin interprets and runs inside Revit's API. That's true whether the client is Claude or Codex.

---

## ⚙️ Requirements

| Requirement | Details |
|-------------|---------|
| **Revit** | Autodesk Revit 2025, 2026 or 2027 (the installer detects each installed year) |
| **OS** | Windows 10 / 11 x64 |
| **MCP client** | Claude Desktop or Claude Code with MCP support, **or** Codex with an `mcp_servers` entry (tested running GPT-6 Astra) |

---

## 🚀 Quick Start

Close Revit, then run:

```powershell
.\install.ps1
```

Deploys automatically. No admin rights needed:

| Destination | Contents |
|-------------|----------|
| `%APPDATA%\Autodesk\Revit\Addins\<year>\` | Add-in manifest and `RvtMcp\` folder, one per detected Revit year (2025, 2026, 2027) |
| `%LOCALAPPDATA%\Bimwright\rvt-mcp\server\current\` | MCP server |
| `%LOCALAPPDATA%\Bimwright\rvt-mcp\rvtmcp.config.json` | Settings. A fresh install seeds `"toolsets": ["all"]` |
| `%USERPROFILE%\Documents\Codex\rvt-mcp\` | Server copy for the Codex app |

Useful options:

```powershell
.\install.ps1 -WhatIf                  # preview, change nothing
.\install.ps1 -Years 2025,2026         # install for specific Revit years
.\install.ps1 -Client claude           # wire one MCP client
.\install.ps1 -Client none             # leave client configs alone
.\install.ps1 -Uninstall               # remove the add-ins
```

**Upgrading from v0.5.0 (Revit 2027 only):** run `.\install.ps1` again. The upstream installer moves `%LOCALAPPDATA%\RvtMcp\` to `%LOCALAPPDATA%\Bimwright\rvt-mcp\` and replaces the old add-in. The server path changed, so check your client config. Add `-PruneOldServers` to delete the old `0.5.0` folder.

---

## 🔌 MCP Client Config

The installer wires every detected client for you and backs up each config to `<config>.bak` first. Restart the client afterwards. To wire by hand:

### Claude Desktop / Claude Code

Add to `~/.claude.json` under `mcpServers`:

```json
"rvt-mcp": {
  "command": "C:\\Users\\<user>\\AppData\\Local\\Bimwright\\rvt-mcp\\server\\current\\rvt-mcp.exe",
  "args": []
}
```

**Verify connection:**
1. Open Revit 2025, 2026 or 2027. The addin loads automatically on startup
2. In Claude, run: `get current view info`. It should return Revit model state
3. Check `%LOCALAPPDATA%\Bimwright\rvt-mcp\rvt-mcp.log` if something fails

### Codex (GPT-6 Astra)

✅ **Verified working in the Codex app (2026-09-18)** — connected to a live Revit 2027
model (v0.5.0 build) through `Documents\Codex\rvt-mcp\rvt-mcp.exe`. Two steps:

1. **Download and install.** Clone or download this repo and run `.\install.ps1`. It
   drops a Codex copy of the server at `%USERPROFILE%\Documents\Codex\rvt-mcp\rvt-mcp.exe`. If the upstream installer already wired Codex to the `%LOCALAPPDATA%` path, replace that `command` value.
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
1. Open Revit. The addin loads automatically on startup
2. Inside Codex, run `/mcp` — it should report `rvt-mcp: connected` with the tool count
3. Run `Get the current Revit view information.` — a response with the active view confirms the server is actually talking to Revit, not just that the tool list loaded
4. If Codex reports a connected tool server but calls fail, check for a named-pipe access error from a sandboxed session before assuming the addin is broken

---

## 🔧 242 Available Tools

Extracted from the v1.2.2 server source. Every tool name carries the `revit_` prefix.

| Setting | Tools exposed |
|---------|---------------|
| Fresh install (`toolsets: ["all"]`) | 242 |
| Bare `rvt-mcp.exe` with no config | 55 (`query`, `create`, `view`, `meta`) |
| `all` plus adaptive bake | 245 |

Your own `toolsets` choice in `rvtmcp.config.json` survives upgrades. Counts exclude personal baked tools.

<details>
<summary><strong>AdaptiveBake</strong> · 3</summary>

`revit_accept_bake_suggestion` · `revit_dismiss_bake_suggestion` · `revit_list_bake_suggestions`

</details>

<details>
<summary><strong>Annotation</strong> · 14</summary>

`revit_apply_keynote_to_element` · `revit_create_callout_view` · `revit_create_detail_line` · `revit_create_dimensions` · `revit_create_filled_region` · `revit_create_text_note` · `revit_find_undimensioned_elements` · `revit_find_untagged_elements` · `revit_list_keynotes` · `revit_tag_all_by_category` · `revit_tag_all_rooms` · `revit_tag_all_walls` · `revit_tag_elements` · `revit_wipe_empty_tags`

</details>

<details>
<summary><strong>ChangeHistory</strong> · 3</summary>

`revit_get_change_records` · `revit_record_change` · `revit_resolve_history_identity`

</details>

<details>
<summary><strong>Create</strong> · 7</summary>

`revit_create_grid` · `revit_create_group_from_elements` · `revit_create_level` · `revit_create_line_based_element` · `revit_create_point_based_element` · `revit_create_room` · `revit_create_surface_based_element`

</details>

<details>
<summary><strong>Delete</strong> · 1</summary>

`revit_delete_element`

</details>

<details>
<summary><strong>Export</strong> · 16</summary>

`revit_batch_export_sheets` · `revit_create_view_sheet_set` · `revit_export_dgn` · `revit_export_dwf` · `revit_export_dwg` · `revit_export_elements_data` · `revit_export_fbx` · `revit_export_gbxml` · `revit_export_ifc` · `revit_export_image` · `revit_export_nwc` · `revit_export_pdf` · `revit_export_room_data` · `revit_export_schedule_csv` · `revit_get_print_settings` · `revit_list_export_settings`

</details>

<details>
<summary><strong>Failure</strong> · 3</summary>

`revit_get_failure_records` · `revit_get_operation_status` · `revit_lookup_message`

</details>

<details>
<summary><strong>Families</strong> · 10</summary>

`revit_audit_families` · `revit_duplicate_family_type` · `revit_export_family_to_path` · `revit_get_family_instances` · `revit_list_family_types_in_family` · `revit_list_loaded_families` · `revit_load_family_from_path` · `revit_rename_family_type` · `revit_replace_family_type` · `revit_unload_family`

</details>

<details>
<summary><strong>Geometry</strong> · 12</summary>

`revit_analyze_geometry_complexity` · `revit_clash_detection` · `revit_compute_element_area` · `revit_compute_element_volume` · `revit_find_elements_in_volume` · `revit_find_overlapping_elements` · `revit_get_element_bounding_box` · `revit_get_element_centroid` · `revit_get_element_geometry` · `revit_measure_distance_between_elements` · `revit_project_point_onto_face` · `revit_raycast_from_point`

</details>

<details>
<summary><strong>Graphics</strong> · 12</summary>

`revit_apply_filter_to_view` · `revit_clear_element_overrides` · `revit_create_view_filter` · `revit_get_view_visibility` · `revit_list_phases` · `revit_list_view_filters` · `revit_override_element_graphics` · `revit_remove_filter_from_view` · `revit_set_category_visibility` · `revit_set_element_phase` · `revit_set_filter_overrides` · `revit_set_view_phase`

</details>

<details>
<summary><strong>Health</strong> · 1</summary>

`revit_health`

</details>

<details>
<summary><strong>Links</strong> · 12</summary>

`revit_acquire_coordinates_from_link` · `revit_get_link_coordinate_system` · `revit_get_link_elements` · `revit_get_project_coordinate_system` · `revit_import_cad_to_view` · `revit_link_revit_model` · `revit_list_linked_cad` · `revit_list_linked_models` · `revit_publish_coordinates_to_link` · `revit_reload_link` · `revit_set_project_base_point` · `revit_unload_link`

</details>

<details>
<summary><strong>Lint</strong> · 4</summary>

`revit_analyze_view_naming_patterns` · `revit_detect_firm_profile` · `revit_get_model_warnings_summary` · `revit_suggest_view_name_corrections`

</details>

<details>
<summary><strong>Materials</strong> · 10</summary>

`revit_assign_material_to_element` · `revit_create_material` · `revit_duplicate_material` · `revit_get_material_properties` · `revit_get_material_takeoff` · `revit_list_materials` · `revit_set_material_appearance` · `revit_set_material_identity` · `revit_set_material_structural_asset` · `revit_set_material_thermal_asset`

</details>

<details>
<summary><strong>Mep</strong> · 16</summary>

`revit_analyze_mep_network` · `revit_connect_mep_elements` · `revit_create_air_terminal` · `revit_create_cable_tray` · `revit_create_conduit` · `revit_create_duct` · `revit_create_lighting_fixture` · `revit_create_mep_fitting` · `revit_create_pipe` · `revit_detect_system_elements` · `revit_find_mep_disconnects` · `revit_get_mep_element_connectors` · `revit_get_panel_schedule` · `revit_get_system_inventory` · `revit_list_mep_systems` · `revit_set_system_classification`

</details>

<details>
<summary><strong>Meta</strong> · 10</summary>

`revit_analyze_usage_patterns` · `revit_batch_execute` · `revit_get_current_target` · `revit_list_available_targets` · `revit_list_recent_models` · `revit_open_model` · `revit_purge_unused` · `revit_set_project_info` · `revit_show_message` · `revit_switch_target`

</details>

<details>
<summary><strong>Modify</strong> · 6</summary>

`revit_assign_elements_to_workset` · `revit_change_element_type` · `revit_color_elements` · `revit_operate_element` · `revit_set_element_parameter_values` · `revit_set_type_parameter_values`

</details>

<details>
<summary><strong>Organization</strong> · 10</summary>

`revit_apply_view_template` · `revit_create_view_template_from_view` · `revit_delete_saved_selection` · `revit_delete_view_template` · `revit_duplicate_view_template` · `revit_list_saved_selections` · `revit_list_view_templates` · `revit_load_selection` · `revit_save_selection` · `revit_select_elements`

</details>

<details>
<summary><strong>Parameters</strong> · 8</summary>

`revit_bind_shared_parameter` · `revit_create_project_parameter` · `revit_create_shared_parameter` · `revit_export_shared_parameter_file` · `revit_list_project_parameter_bindings` · `revit_list_shared_parameters` · `revit_remove_parameter_binding` · `revit_set_parameter_value_by_guid`

</details>

<details>
<summary><strong>Query</strong> · 17</summary>

`revit_ai_element_filter` · `revit_analyze_model_statistics` · `revit_get_assembly_members` · `revit_get_available_family_types` · `revit_get_current_view_info` · `revit_get_element_details` · `revit_get_element_parameters` · `revit_get_element_relationships` · `revit_get_group_members` · `revit_get_material_quantities` · `revit_get_selected_elements` · `revit_get_type_parameters` · `revit_list_assemblies` · `revit_list_groups` · `revit_list_project_parameters` · `revit_list_worksets` · `revit_survey_change_impact`

</details>

<details>
<summary><strong>Report</strong> · 2</summary>

`revit_get_report_history` · `revit_report_task_result`

</details>

<details>
<summary><strong>Rooms</strong> · 10</summary>

`revit_auto_create_rooms_from_walls` · `revit_compute_room_finishes` · `revit_create_area` · `revit_create_room_separator` · `revit_create_space` · `revit_get_room_boundaries` · `revit_get_room_openings` · `revit_list_areas` · `revit_list_rooms` · `revit_tag_all_areas`

</details>

<details>
<summary><strong>Schedule</strong> · 10</summary>

`revit_add_schedule_field` · `revit_apply_schedule_filter_sort` · `revit_create_schedule` · `revit_find_schedule_elements` · `revit_get_schedulable_fields` · `revit_get_schedule_data` · `revit_get_schedule_definition` · `revit_get_schedule_formulas` · `revit_list_schedules` · `revit_update_schedule_field`

</details>

<details>
<summary><strong>SendCode</strong> · 1</summary>

`revit_send_code_to_revit`

</details>

<details>
<summary><strong>Sheets</strong> · 14</summary>

`revit_align_viewports` · `revit_assign_revision_to_sheet` · `revit_create_placeholder_sheet` · `revit_create_revision` · `revit_create_sheet` · `revit_duplicate_sheet` · `revit_get_titleblock_parameters` · `revit_get_viewport_geometry` · `revit_list_revisions` · `revit_list_sheets` · `revit_list_titleblocks` · `revit_place_schedule_on_sheet` · `revit_renumber_sheets` · `revit_set_titleblock_parameters`

</details>

<details>
<summary><strong>Structural</strong> · 12</summary>

`revit_analyze_structural_connections` · `revit_create_foundation_isolated` · `revit_create_foundation_wall` · `revit_create_rebar_set` · `revit_create_rebar_stirrup` · `revit_create_structural_beam` · `revit_create_structural_column` · `revit_create_structural_wall` · `revit_get_structural_loads` · `revit_list_rebar` · `revit_set_structural_load` · `revit_tag_structural_framing`

</details>

<details>
<summary><strong>Toolbaker</strong> · 2</summary>

`revit_list_baked_tools` · `revit_run_baked_tool`

</details>

<details>
<summary><strong>View</strong> · 8</summary>

`revit_activate_view` · `revit_analyze_sheet_layout` · `revit_capture_view_image` · `revit_create_view` · `revit_place_view_on_sheet` · `revit_set_view_crop` · `revit_set_view_scale` · `revit_show_element_in_view`

</details>

<details>
<summary><strong>Workflows</strong> · 8</summary>

`revit_workflow_clash_review` · `revit_workflow_data_roundtrip` · `revit_workflow_model_audit` · `revit_workflow_naming_normalization` · `revit_workflow_room_documentation` · `revit_workflow_sheet_set` · `revit_workflow_takeoff_report` · `revit_workflow_view_cleanup`

</details>

Full documentation for each tool lives upstream: [bimwright/rvt-mcp](https://github.com/bimwright/rvt-mcp). Read-only mode exposes a smaller set. Keep `revit_send_code_to_revit` out of automatic permissions.

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
| **Tool count drift** | The tool count a client reports follows your `toolsets` setting. A bare server shows 55, a full install shows 242 |

---

## 💬 Prompt Strategies

### 1️⃣ Set a BIM Expert Role First

Start every session with this system prompt:

```
You are a BIM expert working in Revit [2025, 2026 or 2027].
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
| `install.ps1` | Wrapper. Runs the upstream installer, then adds the Codex server copy |
| `setup/` | Upstream RvtMcp Setup v1.2.2, unmodified. `manifest.json` holds SHA-256 checksums for every file |
| `setup/plugins/RvtMcp.Plugin.R25.zip` | Revit 2025 add-in |
| `setup/plugins/RvtMcp.Plugin.R26.zip` | Revit 2026 add-in |
| `setup/plugins/RvtMcp.Plugin.R27.zip` | Revit 2027 add-in |
| `setup/plugins/RvtMcp.Plugin.R22-R24.zip` | Revit 2022 to 2024 add-ins. Shipped by upstream and kept so checksums verify. Not documented or tested here |
| `setup/server/` | Self-contained MCP server |
| `setup/SETUP-ZIP.sha256` | Checksum of the original upstream Setup ZIP |
| `docs/mcp-config-codex.md` | Codex app configuration |

Do not edit files inside `setup/`. The upstream installer refuses to run when a checksum fails.

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
This repository packages v1.2.2 for Revit 2025, 2026 and 2027 with a Codex-aware wrapper installer and client
documentation. See [NOTICE](NOTICE) for full attribution and the list of changes.

Workshop material and prompt strategies adapted from the **"Revit × Claude MCP Workshop"** slide deck by **Abdelrhman Hosny**, BIM/VDC Engineer.

Licensed under the Apache License 2.0 — see [LICENSE](LICENSE).

Autodesk and Revit are trademarks of Autodesk, Inc. Claude is a trademark of Anthropic, PBC.
Codex is a trademark of OpenAI. This project is not affiliated with any of them.

---

<div align="center">

**Server:** `1.2.2` &nbsp;|&nbsp; **Addins:** `R25`, `R26`, `R27` &nbsp;|&nbsp; **Tools:** 242 &nbsp;|&nbsp; **Clients:** Claude, Codex (GPT-6 Astra)

*MCP integration for Autodesk Revit 2025, 2026 and 2027. Claude and Codex*

</div>
