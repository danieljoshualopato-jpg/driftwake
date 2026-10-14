extends SceneTree
## Compiles every GDScript file in the project with the autoloads registered
## (plain `--check-only` does not register them, so it rejects any script that
## uses EventBus or GameState). Exits 1 if any script fails to compile.
## Run: godot --headless --path . --script res://tools/parse_all.gd


func _initialize() -> void:
	var failed := 0
	for path in _scripts("res://"):
		var script := load(path) as Script
		var ok := script != null and script.can_instantiate()
		print(("  ok    " if ok else "  FAIL  ") + path)
		if not ok:
			failed += 1
	quit(1 if failed > 0 else 0)


func _scripts(dir: String) -> PackedStringArray:
	var found := PackedStringArray()
	for sub in DirAccess.get_directories_at(dir):
		if not sub.begins_with("."):
			found.append_array(_scripts(dir.path_join(sub)))
	for file in DirAccess.get_files_at(dir):
		if file.get_extension() == "gd":
			found.append(dir.path_join(file))
	return found
