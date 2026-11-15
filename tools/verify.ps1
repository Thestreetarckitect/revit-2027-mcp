#Requires -Version 5.1
# Verify setup\ against setup\manifest.json using SHA-256.
$ErrorActionPreference = 'Stop'
$setup = Join-Path (Split-Path -Parent $PSScriptRoot) 'setup'
$manifest = Get-Content -Raw -LiteralPath (Join-Path $setup 'manifest.json') | ConvertFrom-Json
$failed = 0
foreach ($f in $manifest.files) {
    $p = Join-Path $setup ($f.path -replace '/', '\')
    if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { Write-Host "MISSING $($f.path)" -ForegroundColor Red; $failed++; continue }
    $h = (Get-FileHash -Algorithm SHA256 -LiteralPath $p).Hash
    if ($h -ne $f.sha256.ToUpperInvariant()) { Write-Host "CHECKSUM MISMATCH $($f.path)" -ForegroundColor Red; $failed++ }
}
Write-Host ("Checked {0} files, failures: {1}" -f @($manifest.files).Count, $failed)
if ($failed) { exit 1 }
