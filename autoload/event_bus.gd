extends Node
## Global signal hub. It only declares signals: systems emit and listen here
## instead of holding references to each other, so the HUD never needs to know
## about an enemy and an enemy never needs to know about the HUD.

@warning_ignore_start("unused_signal")

## SceneRouter, after a new area is loaded and the player is placed in it.
signal area_entered(area_id: StringName)
## GameState, whenever a story flag is set.
signal flag_changed(flag: StringName, value: Variant)
## Anything with a line of text for the player (terminals, for now).
signal message_posted(text: String)
## Player, when the nearest usable thing changes. Empty prompt means none.
signal interaction_prompt_changed(prompt: String)

# Phase 2+
signal enemy_died(enemy_id: StringName, at: Vector2)

# Phase 3+
signal item_picked_up(item_id: StringName, amount: int)
signal quest_updated(quest_id: StringName)
