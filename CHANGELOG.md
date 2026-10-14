# Changelog

## 0.2.0-dev — Phase 1

- Three connected areas: Hangar → Corridor → Medbay. Each doorway is a `Door` node that fades to a named spawn point in the next room.
- Corridor: a long hall with pillars and a terminal. Medbay: pale floor, beds, and a collapsed-floor pit you cannot walk into.
- `Interactable` component and wall terminals. Walk up to one and an "[E] Read terminal" hint appears. Each press shows the next log line in a banner.
- F3 debug overlay: FPS, area, position (pixels and tile) and velocity.
- Rooms smaller than the screen are centred, with a near-black background around them.
- Controls are released during area transitions, so the player coasts to a stop under the fade.
- New placeholder art: pit, door, medbay floor and bed tiles, and a terminal sprite. Pits sit on their own physics layer.
- `tools/build_rooms.gd` replaces `build_hangar.gd` and builds all three rooms. Smoke test now walks through every door, reads a terminal, tests the pit and toggles the overlay.

## 0.1.0-dev — Phase 0

- Godot 4.7 project: 640 × 360 pixel-art viewport scaled to a 1280 × 720 window, nearest filtering, Compatibility renderer, physics interpolation.
- Input map for move, attack, interact, inventory, pause and debug overlay, with keyboard and gamepad bindings.
- Autoloads: EventBus (signals only), GameState (flags, versioned for saves), SaveManager (JSON slots with a migration hook), SceneRouter (area loading with a fade).
- Player: 8-direction movement with acceleration and friction through a reusable MovementComponent; four-way facing marker; smoothed camera clamped to the area.
- Area_Hangar: first room, 56 × 34 tiles, with a landing pad, crate stacks and a storage bay behind a partition wall.
- Placeholder 16 px tileset (floor, grate, hazard stripes, wall, crate) with collision on walls and crates.
- `tools/check.ps1`: compiles every script and runs a headless smoke test of spawn, movement, friction and wall collision.
