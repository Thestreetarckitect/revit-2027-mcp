#!/usr/bin/env python3
"""Verify setup/ against setup/manifest.json and scan for committed secrets."""
import hashlib, json, os, re, sys

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
setup = os.path.join(root, "setup")
manifest = json.load(open(os.path.join(setup, "manifest.json"), encoding="utf-8"))
failed = 0

for f in manifest["files"]:
    path = os.path.join(setup, *f["path"].split("/"))
    if not os.path.isfile(path):
        print("MISSING", f["path"]); failed += 1; continue
    h = hashlib.sha256(open(path, "rb").read()).hexdigest()
    if h.lower() != f["sha256"].lower():
        print("CHECKSUM MISMATCH", f["path"]); failed += 1
print("checked", len(manifest["files"]), "manifest files, failures:", failed)

# Secret scan on small text files outside setup/
pat = re.compile(r'(auth_token|api[_-]?key|secret|password)\s*["\']?\s*[:=]\s*["\']?[A-Za-z0-9+/=_-]{16,}', re.I)
leaks = 0
for d, dirs, files in os.walk(root):
    dirs[:] = [x for x in dirs if x not in (".git", "setup")]
    for n in files:
        if os.path.splitext(n)[1].lower() not in (".md", ".json", ".ps1", ".toml", ".yml", ".txt", ""):
            continue
        p = os.path.join(d, n)
        try: t = open(p, encoding="utf-8", errors="ignore").read()
        except OSError: continue
        if pat.search(t):
            print("POSSIBLE SECRET", os.path.relpath(p, root)); leaks += 1
print("secret scan hits:", leaks)

# GitHub rejects files over 100 MiB
for d, dirs, files in os.walk(root):
    dirs[:] = [x for x in dirs if x != ".git"]
    for n in files:
        p = os.path.join(d, n)
        if os.path.getsize(p) >= 100 * 1024 * 1024:
            print("TOO LARGE", os.path.relpath(p, root)); failed += 1

sys.exit(1 if (failed or leaks) else 0)
