# Security

## What this repository contains
- `setup/` is the unmodified upstream RvtMcp Setup package (https://github.com/bimwright/rvt-mcp). `setup/manifest.json` lists a SHA-256 checksum for every file in it.
- `install.ps1` wraps the upstream installer. It installs per user and needs no admin rights.

## Verify before you run
From the repository root:

    pwsh ./tools/verify.ps1

or on any system with Python 3:

    python3 tools/verify.py

Both compare every file in `setup/` with `setup/manifest.json`. CI runs the same check on every push and pull request.

## Using the server safely
- `revit_send_code_to_revit` and `revit_batch_execute` run arbitrary code in your model. Keep them out of automatic permissions and approve each call.
- Use a copy of the model for first tests.
- Run one MCP client at a time.
- Never commit `revit-*.json` runtime files. They hold a local pipe auth token. `.gitignore` blocks them.

## Report a problem
Open a private security advisory on this repository, or email the owner through the GitHub profile. For flaws in the server or add-in itself, report upstream: https://github.com/bimwright/rvt-mcp/security
