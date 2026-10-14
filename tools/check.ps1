# Headless checks for Driftwake. Parses every GDScript file, then boots the game
# without a window and runs tests/smoke_test.gd. Exit code 0 means it is safe
# to open in the editor.
#
# Usage:  powershell -ExecutionPolicy Bypass -File tools/check.ps1
# Set GODOT_BIN to use a Godot console executable somewhere other than C:\Godot.

$godot = if ($env:GODOT_BIN) { $env:GODOT_BIN } else { "C:\Godot\Godot_v4.7.2-stable_win64_console.exe" }
$root = Split-Path -Parent $PSScriptRoot
$failed = 0

function Test-Output($lines) {
    # Godot keeps exit code 0 for many script errors, so read the log as well.
    return -not ($lines | Where-Object { "$_" -match 'SCRIPT ERROR|Parse Error|^ERROR:' })
}

Write-Host "== Importing assets"
$out = & $godot --headless --path $root --import 2>&1
if (-not (Test-Output $out)) { $out | ForEach-Object { Write-Host "  $_" }; $failed++ }

Write-Host "== Compiling scripts"
$out = & $godot --headless --path $root --script res://tools/parse_all.gd 2>&1
$out | Select-Object -Skip 1 | ForEach-Object { Write-Host "$_" }
if ($LASTEXITCODE -ne 0 -or -not (Test-Output $out)) { $failed++ }

Write-Host "== Smoke test"
$out = & $godot --headless --path $root --fixed-fps 60 -- --smoke-test 2>&1
$out | ForEach-Object { Write-Host "$_" }
if ($LASTEXITCODE -ne 0 -or -not (Test-Output $out)) { $failed++ }

if ($failed -gt 0) { Write-Host "CHECKS FAILED ($failed)"; exit 1 }
Write-Host "ALL CHECKS PASSED"
exit 0
