# Driftwake

A top-down 2D sci-fi action RPG built in Godot 4.7. You wake on a derelict frontier colony and explore it room by room.

The full roadmap is in [docs/BUILD_PLAN.md](docs/BUILD_PLAN.md) and progress is in [CHANGELOG.md](CHANGELOG.md).

## Play it

1. Install [Godot 4.7.2](https://godotengine.org/download/) (the standard build, not .NET).
2. Open Godot, click **Import**, and select this folder's `project.godot`.
3. Press **F5**.

## Controls

| Action | Keyboard | Gamepad |
| --- | --- | --- |
| Move | WASD or arrow keys | Left stick or D-pad |
| Attack | Space or J | X / Square |
| Interact | E or Enter | A / Cross |
| Inventory | I or Tab | Y / Triangle |
| Pause | Esc or P | Start |
| Debug overlay | F3 | Back / Select |

Movement, interact and the debug overlay work so far. The other actions are bound now so later phases can use them.

## Checks

```powershell
powershell -ExecutionPolicy Bypass -File tools/check.ps1
```

This imports assets, compiles every script, and boots the game headless to run `tests/smoke_test.gd`. Set `GODOT_BIN` if Godot's console executable is not at `C:\Godot\Godot_v4.7.2-stable_win64_console.exe`.

## Layout

```
autoload/      EventBus, GameState, SaveManager, SceneRouter
scenes/        Main.tscn, player/, world/ (one scene per area), components/
assets/        tiles/, sprites/ (placeholder art for now)
data/          items, enemies, quests, dialogue (from Phase 2)
tests/         headless smoke test
tools/         check script and one-off generators for placeholder art and rooms
docs/          build plan
```
