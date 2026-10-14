extends Node
## Writes GameState to user://save_<slot>.json and reads it back.
## Phase 4 adds the slot screen, autosave on area change and Continue.

const SLOT_COUNT := 3


func slot_path(slot: int) -> String:
	return "user://save_%d.json" % slot


func has_save(slot: int) -> bool:
	return FileAccess.file_exists(slot_path(slot))


func save_game(slot: int) -> Error:
	var file := FileAccess.open(slot_path(slot), FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(GameState.to_dict(), "\t"))
	return OK


func load_game(slot: int) -> Error:
	if not has_save(slot):
		return ERR_FILE_NOT_FOUND
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(slot_path(slot)))
	if not data is Dictionary:
		return ERR_PARSE_ERROR
	GameState.from_dict(migrate(data))
	return OK


## Upgrades save data written by older builds, one version at a time.
## When GameState.SAVE_VERSION goes to 2, add `if version == 1: ...` here.
func migrate(data: Dictionary) -> Dictionary:
	data["version"] = GameState.SAVE_VERSION
	return data
