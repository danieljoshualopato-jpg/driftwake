# Changelog

## 0.1.0-dev — Phase 0

- Godot 4.7 project: 640 × 360 pixel-art viewport scaled to a 1280 × 720 window, nearest filtering, Compatibility renderer, physics interpolation.
- Input map for move, attack, interact, inventory, pause and debug overlay, with keyboard and gamepad bindings.
- Autoloads: EventBus (signals only), GameState (flags, versioned for saves), SaveManager (JSON slots with a migration hook), SceneRouter (area loading with a fade).
- Player: 8-direction movement with acceleration and friction through a reusable MovementComponent; four-way facing marker; smoothed camera clamped to the area.
- Area_Hangar: first room, 56 × 34 tiles, with a landing pad, crate stacks and a storage bay behind a partition wall.
- Placeholder 16 px tileset (floor, grate, hazard stripes, wall, crate) with collision on walls and crates.
- `tools/check.ps1`: compiles every script and runs a headless smoke test of spawn, movement, friction and wall collision.
