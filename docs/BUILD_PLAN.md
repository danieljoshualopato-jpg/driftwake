# Sci-Fi Top-Down RPG — Build Plan

Oct 14, 2026 · @Bayan Raisi

## Vision

**Working title: Driftwake** (rename anytime). A top-down 2D sci-fi action RPG in the spirit of 16-bit classics: you wake on a derelict frontier colony, explore it room by room, fight hostile machines and creatures in real time, talk to survivors, take on quests, and grow through gear and skills. It ships as a real Windows, Mac and Linux game, and it is built to keep growing for months.

Four pillars decide every design argument that comes up later:

1. **Exploration pays.** Every map rewards poking into corners: a locked door, a log entry, a hidden vent. The world is the main character.
2. **Readable combat.** Real-time, Zelda-style, few enemy types with clear tells. Depth comes from gear and positioning, not from reflexes alone.
3. **Everything is data.** A new enemy, item, room or quest is a new file, not a code change. This is what makes "expand over time" cheap instead of painful.
4. **Always playable.** Every phase ends with a build you can play start to finish. Nothing sits half-done for weeks.

## Tech stack: Godot 4

The game is built in **Godot 4.7** (current stable is [4.7.2, released 18 Aug 2026](https://github.com/godotengine/godot/releases)) with **GDScript**. It is free and MIT-licensed with no royalties, its 2D tooling is first-class, and every project file (scenes, scripts, tilesets) is plain text, so Claude can write and edit them directly and you open the result in the editor.

| Option | Fit for a long-lived desktop 2D RPG | The catch |
| --- | --- | --- |
| **Godot 4 + GDScript** | Best. Built for 2D, text-based project, one-click export to Windows, Mac, Linux | You install the editor (one download, no setup) |
| Unity + C# | Strong, but heavier and built around 3D first | Licence terms have shifted; scene files are awkward to author outside the editor |
| Browser (HTML/JS) | Fastest to prototype, runs anywhere | Not a real desktop game; no tilemap editor, so content work is slower as the game grows |
| Python + Pygame | Simple to start | You build your own editor tooling; packaging an .exe is painful |

The rest of the stack:

- **Rendering:** 2D pixel art, base resolution 640 × 360 scaled up with nearest-neighbour filtering. Tiles are 16 px.
- **Maps:** Godot's built-in TileMapLayer and tileset editor. No external map tool to learn.
- **Art:** free CC0 sci-fi tilesets and sprites to start (Kenney and itch.io packs), swapped for custom art later without touching code. See Risks for the decision.
- **Audio:** Godot's AudioStreamPlayer, with free CC0 sound packs and a placeholder music loop.
- **Version control:** a git repo on GitHub. This is also how we pass work back and forth.
- **Checks:** Godot's headless mode parses every script so broken code is caught before you open the editor; play-testing is yours.

## Architecture

Content lives in data files, systems live in four global singletons, and scenes stay thin. That split is what lets the game grow for months without rewrites: adding an enemy touches `data/` and `scenes/enemies/`, never the player, the UI or the save system.

&#91;embedded content: architecture · 4 autoloads, 4 scene types, 4 data folders\]

Arrows are the only allowed dependencies: scenes read GameState and data, signal through the EventBus, and SceneRouter is the one thing that loads areas. Nothing in a row reaches sideways into a neighbour.

```
driftwake/
  project.godot
  autoload/        GameState, EventBus, SaveManager, SceneRouter
  scenes/
    player/        Player.tscn + player.gd
    enemies/       EnemyBase.tscn, one scene per enemy type
    world/         one scene per area: Area_Hangar.tscn, Area_Medbay.tscn …
    ui/            HUD, dialogue box, inventory, pause and main menus
    components/    Health, Hitbox, Hurtbox, Movement (reused by player and enemies)
  data/
    items/         one .tres Resource per item
    enemies/       stats and drops per enemy type
    quests/        one .tres per quest
    dialogue/      one JSON per conversation
  assets/          sprites/ tiles/ audio/ fonts/
  tests/           headless smoke tests
```

The patterns that hold it together:

- **EventBus.** A singleton that only declares signals (`enemy_died`, `item_picked_up`, `quest_updated`, `area_entered`). Systems talk through it instead of reaching into each other, so the HUD never needs a reference to an enemy.
- **GameState.** Player stats, inventory, story flags and quest progress in one place. It is the only thing SaveManager serialises.
- **Resources for content.** `ItemData`, `EnemyData` and `QuestData` are custom Resource classes with exported fields. A new sword is a new `.tres` file you can edit in the Inspector; no script changes.
- **Components, not inheritance.** `HealthComponent`, `HitboxComponent`, `HurtboxComponent` and `MovementComponent` are child nodes. The player and every enemy are assembled from the same parts.
- **Areas are scenes, doors are data.** Each room is its own scene. A `Door` node carries a target area and spawn point; `SceneRouter` handles the swap and the fade.
- **Dialogue is JSON.** Lines, choices, conditions on flags and effects on flags. Writing a conversation never means writing code.

## Phase 0 — Setup (one session)

Done when you can open the project in Godot, press Play, and see a window with the title and a coloured square you can move. Everything after this is adding to a working game.

- [x] Install Godot 4.7.2 (standard build, not .NET) from [godotengine.org](https://godotengine.org/download/)
- [x] Create a GitHub repo (`driftwake`) and connect it to this chat, so Claude can push code and you can pull it
- [x] Claude writes `project.godot`, the folder layout, the four autoloads as empty shells, and a `Main.tscn` that loads the first area
- [x] Pixel-art settings: 640 × 360 viewport, `canvas_items` stretch mode, nearest filtering, 16 px tiles
- [x] Input map: move (WASD and arrows), attack, interact, inventory, pause; keyboard and gamepad both bound
- [ ] Pick a starter tileset and player sprite (see Risks) and drop them in `assets/`. *Generated placeholder tiles and a player square are in place; a CC0 pack is still to pick.*
- [x] A headless check script (`godot --headless --check-only`) runs in the repo so broken scripts are caught before you open the editor. *`tools/check.ps1`: compiles every script with autoloads loaded, then runs a headless smoke test.*

**The handoff loop** is the same every session from here: Claude pushes a branch, you pull it, open Godot, press F5, play, and tell Claude what felt wrong. Claude cannot see the game run, so your five minutes of playing is the test suite.

## Phase 1 — Walking simulator (1–2 sessions)

Done when you can walk through three connected rooms of the colony with the camera following, bump into walls, and step through doors. No combat yet; this phase is about the world feeling solid.

- [ ] `Player.tscn`: CharacterBody2D, 8-direction movement with acceleration and friction, four-direction walk and idle animations via AnimatedSprite2D
- [x] `MovementComponent` so the same movement code serves enemies later
- [x] Camera2D with smoothing and per-area limits so it never shows the void past the map edge
- [ ] TileSet with physics layers (floor, wall, pit) and a navigation layer for enemy pathing later
- [ ] Three areas: `Area_Hangar` (start), `Area_Corridor`, `Area_Medbay`, each a scene with a TileMapLayer and a `Doors` node
- [ ] `Door` node and `SceneRouter`: walk into a door, screen fades, next area loads at the matching spawn point
- [ ] `Interactable` component: walk up, press interact, something happens (a terminal prints a line to the screen for now)
- [ ] A debug overlay (F3) showing FPS, position and current area; it saves hours later

What we learn here decides the feel of everything: movement speed, tile size, how far the camera leads. Expect to tune numbers twice.

## Phase 2 — Combat (2–3 sessions)

Done when you can clear the three rooms of enemies, die, respawn at the last door, and beat one boss in the medbay. This is the phase where the game becomes a game.

- [ ] `HealthComponent` (max, current, `died` signal), `HurtboxComponent` (takes hits), `HitboxComponent` (deals hits, with damage, knockback and an owner so you cannot hit yourself)
- [ ] Player attack: a melee swing (plasma cutter) with a short active window, then a ranged blaster with a cooldown. Two weapons is enough to make gear matter later
- [ ] Invincibility frames and a hit flash shader, so taking damage is readable
- [ ] `EnemyBase.tscn` with a small state machine: Idle, Patrol, Chase, Attack, Hurt, Dead. NavigationAgent2D for pathing
- [ ] Three enemy types, each a scene inheriting EnemyBase plus an `EnemyData` resource: a slow **maintenance drone** (melee), a **turret** (stationary, ranged), and a **scuttler** (fast, low health, swarms)
- [ ] Enemy spawners per area, so a room can be cleared and stay cleared via a flag in GameState
- [ ] Death and respawn: fade out, reload the area, restore health, keep flags and inventory
- [ ] First boss, the **Quarantine Warden**: two phases, a clear tell before each attack, a weak point. Bosses get their own scene and script; they are the one place inheritance is not enough
- [ ] HUD: health bar, current weapon, ammo count, hooked to EventBus so it never touches the player directly

Design rule for every enemy: one idea each. The drone tests spacing, the turret tests cover, the scuttler tests crowd control. If an enemy needs a paragraph to explain, split it into two.

## Phase 3 — World and story (3–4 sessions)

Done when the game has a first act: you wake, meet a survivor, take a quest to restore power, cross five areas to do it, and the ending of the act unlocks the next zone. Everything here is data-driven, so later acts are written, not coded.

- [ ] Inventory: `ItemData` resource (name, icon, type, stack size, effects), a GameState inventory with add, remove and count, and an inventory screen that lists and uses items
- [ ] Pickups in the world: a `Pickup` scene that takes an `ItemData` and adds it on touch; chests and lockers as interactables that drop items
- [ ] Dialogue system: a `DialogueBox` UI, a JSON schema (speaker, lines, choices, `requires` flags, `sets` flags), and a `DialogueRunner` that plays a file. Typewriter text, portraits optional
- [ ] NPCs: an `NPC` scene with a dialogue file and an idle animation. First three: the **engineer** who gives the power quest, a **medic** who sells and heals, and a **drifter** who hints at the bigger story
- [ ] Quest system: `QuestData` resource (id, title, steps, each step a condition on flags or item counts, a reward), a quest log screen, and EventBus updates when a step completes
- [ ] Story flags in GameState (`power_restored`, `warden_defeated`) drive doors, dialogue and spawns. One mechanism for all gating
- [ ] Two more areas, **Reactor** and **Observation Deck**, bringing the act to five, with one locked door that opens on the power flag
- [ ] A simple shop: the medic's dialogue opens a buy and sell screen against a credits count in GameState
- [ ] Terminals with lore logs, so Exploration pays off for readers as well as fighters

Story for act one, in one line: *a colony went dark, something in the medbay is why, and the survivors need the reactor back before the air runs out.* Enough to build on, loose enough to change.

## Phase 4 — Progression and polish (2–3 sessions)

Done when you can quit, come back tomorrow, and continue; when levelling up and a new weapon feel different; and when the game has a title screen you would show someone. This is the phase that turns a prototype into something you can send to a friend.

- [ ] Save and load: `SaveManager` writes GameState to `user://save_1.json`, three slots, autosave on area change, a Continue option on the title screen
- [ ] XP and levels: enemies grant XP from `EnemyData`, a level curve in one table, each level raises max health and unlocks a skill point
- [ ] Skills: a small tree of six to eight nodes (faster blaster cooldown, wider cutter arc, dash, extra inventory slots). Each skill is a `SkillData` resource and a flag
- [ ] Gear: weapon and armour slots on the player, stats from `ItemData` modifiers, an equipment screen. Two tiers of each weapon is enough to feel it
- [ ] Menus: title, pause, settings (volume, fullscreen, key rebinding), game over. One `UIManager` autoload so menus stack cleanly
- [ ] Audio: footsteps, hits, pickups, door, UI clicks, one ambient loop per area, a boss track. `AudioManager` with buses so settings work
- [ ] Juice: screen shake on hits, hit stop on kills, particles on death, a vignette when low on health. Small things that make combat feel physical
- [ ] Export presets for Windows, macOS and Linux; a first build you double-click to run
- [ ] A `CHANGELOG.md` and version number shown on the title screen, so bug reports from friends are useful

At the end of this phase the game is a real desktop RPG with a complete first act. Everything after is more game, not more engine.

## Phase 5 — Expansion loops (ongoing)

From here the game grows by recipe. Each row is a thing you will want to add many times, what it takes once the foundation exists, and which files it touches. If a recipe ever needs more than this, that is a sign the architecture needs a fix, not the content.

| Add a… | What it takes | Files touched |
| --- | --- | --- |
| New area | Paint a map, place doors, spawners and pickups, write any terminals | `scenes/world/Area_*.tscn` |
| New enemy | Copy an enemy scene, give it an `EnemyData`, pick a sprite, optionally one new state | `scenes/enemies/`, `data/enemies/` |
| New item or weapon | One `.tres` with stats and icon; a weapon also needs an attack scene if its behaviour is new | `data/items/` |
| New NPC | One NPC scene instance in an area, one dialogue JSON | `data/dialogue/` |
| New quest | One `QuestData` with steps, a dialogue that starts it, flags that complete it | `data/quests/`, `data/dialogue/` |
| New boss | A scene and script of its own, an arena area, a flag it sets on death | `scenes/enemies/bosses/`, `scenes/world/` |
| New skill | One `SkillData`, one check in the system it changes | `data/skills/` |
| New act | A batch of the above plus one new mechanic (a vehicle, a hacking minigame, a companion) | all of the above |

Bigger ideas that fit the foundation when you want them, roughly in order of cost:

1. **Crafting** from salvage (new item type, one UI screen)
2. **A hub ship** you upgrade between acts (one area plus flags)
3. **A companion** who follows and fights (an EnemyBase variant on your side)
4. **Procedural side-dungeons** for replay value (a room-stitching generator; the biggest lift here)
5. **Localisation** via Godot's built-in translation CSV, cheap if strings are kept out of code from Phase 3 on

## How we work

Claude writes the code and data; you play, paint maps and decide. Claude cannot run Godot with a window, so the split follows what each of us can actually see.

| Claude does | You do |
| --- | --- |
| All GDScript, scene files, resources, dialogue JSON | Pull, open Godot, press F5, play for five minutes |
| Headless script checks before every push | Report what felt wrong, in plain words ("the dash feels floaty") |
| Tuning numbers from your feedback | Paint tilemaps in the editor once the tileset exists (faster by hand than by code) |
| Writing lore, dialogue and quest text to your brief | Decide: art direction, story beats, what gets cut |
| Keeping this plan and the changelog current | Screenshots or a short screen recording when a bug is hard to describe |

A session looks like this: you say what phase or feature is next (or just "continue"), Claude reads this plan and the repo, builds the next checklist items on a branch, pushes, and tells you what to test. You play and reply. One feature per branch keeps it easy to throw away a bad idea.

A few rules that keep the project healthy:

- Every push leaves the game playable. A half-done feature hides behind a flag rather than breaking the build.
- Numbers live in resources or exported variables, never buried in code, so tuning is a slider in the Inspector.
- Each phase ends with a tagged build (`v0.1`, `v0.2`) you keep. If a later change breaks the feel, there is something to compare against.
- This doc is the source of truth. Tick boxes as things land; add rows to the Phase 5 table as ideas arrive.

## Risks and open decisions

Three decisions are cheap now and expensive after Phase 2. The rest are the usual ways a hobby game dies, each with its guard.

**Decide before Phase 2**

- [x] **Real-time or turn-based combat?** *Decided 2026-10-14: real-time.* This plan assumes real-time, Zelda-style. If you would rather have classic JRPG turn-based battles, say so now: Phases 2 and 4 change shape, Phases 1 and 3 do not.
- [x] **Art source.** *Decided 2026-10-14: (a) CC0 packs.* Free CC0 packs get a playable game fast but limit the look. Options: (a) Kenney or itch.io CC0 sci-fi packs for everything, (b) CC0 tiles plus a commissioned player sprite, (c) you draw it. Start with (a); the code never cares which.
- [x] **Tile size: 16 px or 32 px.** *Decided 2026-10-14: 16 px.* 16 px gives bigger rooms on screen and is the retro default; 32 px gives more detail per tile. The plan says 16. Changing it after maps are painted means repainting.

**Scope traps and their guards**

| Trap | Guard |
| --- | --- |
| Engine-building forever, no game | Every phase ends with something you can play start to finish |
| Content that needs code (each enemy a special case) | The Phase 5 table is the test: if a new thing is not a recipe, fix the architecture |
| Tuning by guesswork | Claude cannot feel the game; your play notes are the only ground truth, so each session ends with you playing |
| Art rabbit hole | Placeholder art until Phase 4; the game has to be fun as coloured squares |
| Save files breaking on every change | Save data carries a version number from day one and a small migration function |
| Losing the thread between sessions | This doc plus the repo's changelog; Claude reads both at the start of every session |

## First session

Next time, we do all of Phase 0 and the first half of Phase 1, and you end the session walking a square around one room. Here is what each side brings.

**Before the session, you:**

- [x] Install Godot 4.7.2 and open it once so the editor is set up
- [x] Create an empty GitHub repo called `driftwake` and tell Claude its address
- [x] Answer the three decisions above (or say "go with the defaults": real-time, CC0 art, 16 px)

**In the session, Claude:**

1. Writes the project skeleton, autoload shells, input map and pixel-art settings
2. Writes `Player.tscn` with 8-direction movement and a placeholder sprite
3. Writes `Area_Hangar.tscn` with a starter tileset, one room and camera limits
4. Pushes to a `phase-0` branch, runs the headless check, and tells you how to open and play it

**You then play and report:** does the square move at a speed that feels right? Does the camera feel glued or floaty? That feedback sets the numbers every later phase builds on.

To start, open a new chat with this doc and say: *"Start Phase 0 of the Driftwake plan."*
