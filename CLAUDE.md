# Driftwake — notes for Claude

Read `docs/BUILD_PLAN.md` (the source of truth) and `CHANGELOG.md` at the start of every session. Tick plan boxes as things land.

## Environment (Windows)

- Godot console build: `C:\Godot\Godot_v4.7.2-stable_win64_console.exe` (the windowed one is next to it).
- Git: `C:\Program Files\Git\cmd\git.exe`. GitHub CLI: `C:\Program Files\GitHub CLI\gh.exe`. They may be missing from the session PATH, so call them by full path.
- Remote: https://github.com/danieljoshualopato-jpg/driftwake. Commit as `danieljoshualopato-jpg <305389092+danieljoshualopato-jpg@users.noreply.github.com>` (set in the repo's local git config).

## Before every push

Run `powershell -ExecutionPolicy Bypass -File tools/check.ps1` and make sure it ends with `ALL CHECKS PASSED`. When a feature can be exercised without a window, add a check to `tests/smoke_test.gd`. The user plays every build. Their notes are the real feel test.

## Conventions

- One feature per branch (`phase-0`, `phase-1-doors`, …). Every push leaves the game playable.
- Systems talk through EventBus signals, not direct references. GameState is the only thing SaveManager serialises. Bump `GameState.SAVE_VERSION` and add a migration step when its shape changes.
- Tunable numbers are `@export` vars or resources, never literals buried in logic.
- Areas extend `WorldArea` (`scenes/world/world_area.gd`): `Floor` and `Walls` TileMapLayers, `Spawns/<name>` markers, `Doors`, and a y-sorted `Entities` node. Camera limits come from the painted Floor.
- Rooms are painted by hand in the editor from now on. `tools/build_hangar.gd` refuses to overwrite them without `-- --force`.
- Godot rewrites `.tscn`/`.tres` files and adds `uid`s when the editor saves. That is expected, so commit those changes.
