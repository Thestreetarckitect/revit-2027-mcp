# MCP Configuration for OpenAI Codex

Wiring `rvt-mcp.exe` into the OpenAI Codex app.

For Anthropic clients see [`mcp-config-claude.md`](./mcp-config-claude.md).

> **This works because the server speaks stdio.** MCP's stdio transport is client-agnostic,
> so the same `rvt-mcp.exe` that serves Claude serves Codex with no rebuild and no
> separate binary. The named pipe in `revit-2027.json` is the *second* hop — server to
> Revit addin — and no client ever sees it.

---

## 1. One config file

The Codex app reads **only** the user-scope `~/.codex/config.toml`.
[openai/codex#13025](https://github.com/openai/codex/issues/13025) reports that it
silently ignores any `.codex/config.toml` inside a project root, so register RvtMcp in
**user scope**.

---

## 1a. Codex Desktop: the server lives under `Documents\Codex\` (working 2026-09-18)

**Codex Desktop works out of the box once `rvt-mcp.exe` lives inside
`%USERPROFILE%\Documents\Codex\`.** It cannot launch the server from the default
`%LOCALAPPDATA%\RvtMcp\...` install path. No config or permission change fixes that —
the file's location does.

### Setup

Run `install.ps1`. Along with the normal install it drops a copy of the server — same
binary, no rebuild — at `%USERPROFILE%\Documents\Codex\rvt-mcp\rvt-mcp.exe`.

Point `~/.codex/config.toml` at that copy and restart Codex Desktop:

```toml
[mcp_servers.rvt-mcp]
command = 'C:\Users\<user>\Documents\Codex\rvt-mcp\rvt-mcp.exe'
args = []
startup_timeout_sec = 30
tool_timeout_sec = 120
```

✅ **Verified 2026-09-18** on a live install: Codex Desktop connects to Revit 2027 through
`%USERPROFILE%\Documents\Codex\rvt-mcp\rvt-mcp.exe`, a byte-identical copy of the
`%LOCALAPPDATA%` one. Re-run `install.ps1`
after every server upgrade so the Codex copy stays current.

### Why the default path fails

Codex Desktop on Windows ships as a **Microsoft Store MSIX package**
(`OpenAI.Codex_..._x64`, installed under `C:\Program Files\WindowsApps\`). Windows runs
MSIX packages inside an **AppContainer**, always — it is not a Codex setting you can
turn off.

AppContainer access is **capability-gated, not ACL-gated**. A path outside the package's
capability set is invisible to the sandboxed process even when NTFS permissions allow
it. `rvt-mcp.exe` lives in `%LOCALAPPDATA%\RvtMcp\...`, outside that set.

### Symptom

`codex doctor` reports something like:

```
The configured Revit MCP executable, rvt-mcp.exe, wasn't found at its configured path.
```

…while the file is demonstrably present and the path in `config.toml` is correct.

### What does NOT fix it

Verified on a real install, all ineffective:

- Granting `CodexSandboxUsers` **ReadAndExecute** on the exe and every parent folder.
  It was already granted. Doctor still reported not found.
- Granting **Modify** on a redirect directory and setting
  `DOTNET_BUNDLE_EXTRACT_BASE_DIR`. `rvt-mcp.exe` is a .NET single-file bundle but
  loads managed assemblies in place — it never extracts, so there is nothing to
  redirect.
- Correcting the path. The path was already right.

A clue that confirms the mechanism: inspect the ACL on the RvtMcp folder and you will
find an AppContainer SID of the form `S-1-15-2-…`. That is the Codex package identity.

---

### Config file path

| OS | Path |
|---|---|
| Windows | `%USERPROFILE%\.codex\config.toml` |
| macOS / Linux | `~/.codex/config.toml` |

Codex creates the file on first run if it is missing. Revit is Windows-only, so in
practice this is the Windows path.

---

## 2. TOML, not JSON

Codex uses TOML. Servers live under `[mcp_servers.<name>]` — note the **underscore**,
where Claude uses `mcpServers` in camelCase.

### Minimal entry

```toml
[mcp_servers.rvt-mcp]
command = "C:\\Users\\<user>\\Documents\\Codex\\rvt-mcp\\rvt-mcp.exe"
args = []
```

Backslashes must be doubled in TOML basic strings. Alternatively use a literal string
with single quotes and single backslashes:

```toml
[mcp_servers.rvt-mcp]
command = 'C:\Users\<user>\Documents\Codex\rvt-mcp\rvt-mcp.exe'
args = []
```

### Recommended entry for Revit work

```toml
[mcp_servers.rvt-mcp]
command = 'C:\Users\<user>\Documents\Codex\rvt-mcp\rvt-mcp.exe'
args = []

startup_timeout_sec = 30    # Revit addin handshake is slower than a typical MCP server
tool_timeout_sec = 120      # large schedules, takeoffs and clash runs exceed the 60s default

# Ask before anything that executes arbitrary code in the model
[mcp_servers.rvt-mcp.tools.revit_send_code_to_revit]
approval_mode = "prompt"

[mcp_servers.rvt-mcp.tools.revit_batch_execute]
approval_mode = "prompt"
```

The two timeout bumps matter. Defaults are 10s startup and 60s per tool; a cold Revit
addin and a real schedule export both blow past those.

### Read-only profile

Useful when pointing an agent at a live production model:

```toml
[mcp_servers.rvt-mcp-readonly]
command = 'C:\Users\<user>\Documents\Codex\rvt-mcp\rvt-mcp.exe'
args = []
disabled_tools = [
  "revit_send_code_to_revit",
  "revit_batch_execute",
  "revit_delete_element",
  "revit_purge_unused",
]
default_tools_approval_mode = "approve"
```

---

## 3. Key reference

| Key | Type | Default | Notes |
|---|---|---|---|
| `command` | string | — | **Required** for stdio. Absolute path to `rvt-mcp.exe`. |
| `args` | array | `[]` | Arguments passed to the server. |
| `cwd` | string | Codex's cwd | Working directory for the child process. |
| `enabled` | bool | `true` | Toggle without deleting the entry. |
| `required` | bool | `false` | If true, Codex refuses to start when the server is unreachable. |
| `startup_timeout_sec` | number | `10` | Handshake wait. Raise for Revit. |
| `tool_timeout_sec` | number | `60` | Per-tool-call timeout. Raise for Revit. |
| `enabled_tools` | array | `[]` = all | Allow list of tool names. |
| `disabled_tools` | array | `[]` | Deny list, applied after the allow list. |
| `default_tools_approval_mode` | `auto` \| `prompt` \| `approve` | inherits global | Approval policy for this server. |
| `tools.<tool>.approval_mode` | same enum | — | Per-tool override. |
| `env` | map | `{}` | Environment variables forwarded to the server process. |

---


## 4. Verify

1. Open Revit 2027. The addin loads on startup and writes `revit-2027.json` with a
   fresh pipe name and auth token.
2. Restart Codex after editing `config.toml`.
3. Start Codex and run `/mcp` — the server should be connected with 216 tools.
4. Ask: `get current view info`. A real response means the whole chain is live —
   Codex to server over stdio, server to addin over the named pipe, addin to the
   Revit API.
5. On failure read `%LOCALAPPDATA%\RvtMcp\revit-mcp.log`.

---

## 5. Do not run two clients at once

Each MCP client spawns its **own** `rvt-mcp.exe` process, and both would connect to the
same named pipe on the same Revit instance. Revit's API is not built for concurrent
external drivers, and two agents opening transactions against one model will corrupt
work or deadlock.

Run Claude or Codex — not both. Close one before starting the other.

---

## 6. Claude vs Codex cheat sheet

| Aspect | Claude Code / Desktop | Codex |
|---|---|---|
| Config format | JSON | **TOML** |
| Top-level key | `mcpServers` | `mcp_servers` |
| User-scope path (Windows) | `%USERPROFILE%\.claude.json` | `%USERPROFILE%\.codex\config.toml` |
| Project-scope file | `.mcp.json` at repo root | `.codex/config.toml` — ignored by the Codex app; use user scope |
| Per-server timeout | Global `MCP_TIMEOUT` env | `startup_timeout_sec`, `tool_timeout_sec` |
| Tool filtering | Permission allowlist patterns | `enabled_tools`, `disabled_tools` |
| Per-tool approval | Permission rules in settings | `default_tools_approval_mode` + per-tool override |
| Hot reload after edit | Yes, `/mcp` reconnect | Yes, `/mcp` reconnect |

---

## 7. Sources

- [Model Context Protocol — Codex](https://developers.openai.com/codex/mcp)
- [Configuration Reference — Codex](https://developers.openai.com/codex/config-reference)
- [openai/codex#13025 — Desktop ignores project `.codex/config.toml`](https://github.com/openai/codex/issues/13025)

**Schema verified 2026-09-15** against a live Codex Desktop install (app version
26.908.70816) by reading its own `~/.codex/config.toml`. Codex's bundled `node_repl`
server uses exactly this shape — `[mcp_servers.<name>]`, a TOML literal-string
`command`, `args = []`, `startup_timeout_sec`, and an `[mcp_servers.<name>.env]`
sub-table — and `[projects.'<path>'] trust_level = "trusted"` appears as documented.
Notably Codex sets `startup_timeout_sec = 120` on its own server, so raising it off the
10-second default is normal practice, not a workaround.

OpenAI has changed this schema before. Re-check against current Codex docs if something
stops working.
