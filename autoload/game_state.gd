extends Node
## Everything about a playthrough lives here: where the player is, story flags,
## and (from Phase 3) inventory and quests. SaveManager serialises only this.

## Bump when the shape of to_dict() changes, and add a step to
## SaveManager.migrate() so older saves keep loading.
const SAVE_VERSION := 1

var current_area := ""
var current_spawn := &""
var flags: Dictionary[StringName, Variant] = {}


func set_flag(flag: StringName, value: Variant = true) -> void:
	flags[flag] = value
	EventBus.flag_changed.emit(flag, value)


func get_flag(flag: StringName, default: Variant = false) -> Variant:
	return flags.get(flag, default)


func reset() -> void:
	current_area = ""
	current_spawn = &""
	flags.clear()


func to_dict() -> Dictionary:
	var flag_data := {}
	for flag in flags:
		flag_data[String(flag)] = flags[flag]
	return {
		"version": SAVE_VERSION,
		"current_area": current_area,
		"current_spawn": String(current_spawn),
		"flags": flag_data,
	}


func from_dict(data: Dictionary) -> void:
	reset()
	current_area = data.get("current_area", "")
	current_spawn = StringName(data.get("current_spawn", ""))
	var flag_data: Dictionary = data.get("flags", {})
	for flag in flag_data:
		flags[StringName(flag)] = flag_data[flag]
