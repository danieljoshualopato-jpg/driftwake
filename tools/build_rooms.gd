extends SceneTree
## Builder for the placeholder tileset and the first rooms. Rooms are meant to
## be painted by hand in the editor, so it never overwrites an existing file
## unless run with `-- --force` (which discards painted changes).
## Run: godot --headless --path . --script res://tools/build_rooms.gd

const TILE := 16
const ATLAS_PATH := "res://assets/tiles/placeholder_tiles.png"
const TILESET_PATH := "res://assets/tiles/placeholder_tileset.tres"
const HANGAR := "res://scenes/world/Area_Hangar.tscn"
const CORRIDOR := "res://scenes/world/Area_Corridor.tscn"
const MEDBAY := "res://scenes/world/Area_Medbay.tscn"
const DOOR_SCENE := "res://scenes/world/Door.tscn"
const TERMINAL_SCENE := "res://scenes/world/props/Terminal.tscn"

# Atlas columns, matching tools/gen_placeholder_art.gd.
enum { FLOOR, GRATE, HAZARD, WALL, CRATE, PIT, DOOR, MED_FLOOR, BED, COUNT }
# Tileset physics layers: 0 blocks everything ("world"), 1 is pits ("pits"),
# which flying enemies will be able to ignore.
const SOLID := [WALL, CRATE, BED]
const PITS := [PIT]
const WORLD_LAYER := 1
const PITS_LAYER := 1 << 6

var _tileset: TileSet


func _initialize() -> void:
	var force := "--force" in OS.get_cmdline_user_args()
	if FileAccess.file_exists(TILESET_PATH) and not force:
		_tileset = load(TILESET_PATH)
		print("kept %s" % TILESET_PATH)
	else:
		_tileset = _build_tileset()
	_build(HANGAR, "Area_Hangar", &"hangar", _hangar, force)
	_build(CORRIDOR, "Area_Corridor", &"corridor", _corridor, force)
	_build(MEDBAY, "Area_Medbay", &"medbay", _medbay, force)
	quit()


# --- Rooms -------------------------------------------------------------------

func _hangar(room: Node2D) -> void:
	var floor_layer := _layer(room, "Floor")
	var walls := _layer(room, "Walls")
	_fill(floor_layer, Rect2i(0, 0, 56, 34), FLOOR)
	# Landing pad: hazard-striped border around a grate, where the player wakes.
	_fill(floor_layer, Rect2i(8, 9, 18, 14), HAZARD)
	_fill(floor_layer, Rect2i(9, 10, 16, 12), GRATE)
	_outline(walls, Rect2i(0, 0, 56, 34), WALL)
	# Partition between the main hangar and the storage bay, with a doorway.
	_fill(walls, Rect2i(40, 1, 1, 14), WALL)
	_fill(walls, Rect2i(40, 19, 1, 14), WALL)
	for r in [
		Rect2i(30, 5, 2, 2), Rect2i(4, 27, 2, 3), Rect2i(33, 26, 2, 1), Rect2i(33, 27, 1, 1),
		Rect2i(28, 18, 1, 1), Rect2i(43, 3, 3, 3), Rect2i(49, 4, 4, 2), Rect2i(44, 24, 3, 4),
		Rect2i(50, 28, 2, 3), Rect2i(52, 12, 2, 1), Rect2i(52, 13, 1, 1),
	]:
		_fill(walls, r, CRATE)

	_spawn(room, &"start", Vector2(17, 16) * TILE)
	_spawn(room, &"from_corridor", Vector2(53, 17.5) * TILE)
	_door_east_west(room, Vector2i(55, 16), CORRIDOR, &"from_hangar")
	_terminal(room, Vector2(17.5, 7.9) * TILE, [
		"SHUTTLE BAY 2, AUTO-LOG: Colony power at 4%. Non-essential systems offline.",
		"Docking clamps locked by medical order. No departures until quarantine lifts.",
		"Stasis pod 3 released on low-power protocol. Occupant: unregistered.",
	])


func _corridor(room: Node2D) -> void:
	var floor_layer := _layer(room, "Floor")
	var walls := _layer(room, "Walls")
	_fill(floor_layer, Rect2i(0, 0, 48, 12), FLOOR)
	_fill(floor_layer, Rect2i(1, 5, 46, 2), GRATE)
	_outline(walls, Rect2i(0, 0, 48, 12), WALL)
	# Support pillars along both walls.
	for x in [8, 16, 32, 40]:
		_fill(walls, Rect2i(x, 1, 1, 1), WALL)
		_fill(walls, Rect2i(x, 10, 1, 1), WALL)
	_fill(walls, Rect2i(29, 9, 2, 2), CRATE)

	_spawn(room, &"from_hangar", Vector2(2.5, 6.5) * TILE)
	_spawn(room, &"from_medbay", Vector2(45.5, 6.5) * TILE)
	_door_east_west(room, Vector2i(0, 5), HANGAR, &"from_corridor")
	_door_east_west(room, Vector2i(47, 5), MEDBAY, &"from_corridor")
	_terminal(room, Vector2(24.5, 2.9) * TILE, [
		"MAINTENANCE TICKET 3318: Drone unit 7 reports movement in the ventilation ducts.",
		"Ticket closed. Resolution: rats. Note: this colony has never had rats.",
	])


func _medbay(room: Node2D) -> void:
	var floor_layer := _layer(room, "Floor")
	var walls := _layer(room, "Walls")
	_fill(floor_layer, Rect2i(0, 0, 36, 24), MED_FLOOR)
	# Collapsed floor: a pit with a hazard border.
	_fill(floor_layer, Rect2i(21, 13, 8, 7), HAZARD)
	_fill(floor_layer, Rect2i(22, 14, 6, 5), PIT)
	_outline(walls, Rect2i(0, 0, 36, 24), WALL)
	for x in [6, 10, 14, 18]:
		_fill(walls, Rect2i(x, 1, 1, 2), BED)
	_fill(walls, Rect2i(5, 18, 2, 3), CRATE)

	_spawn(room, &"from_corridor", Vector2(2.5, 12.5) * TILE)
	_door_east_west(room, Vector2i(0, 11), CORRIDOR, &"from_medbay")
	_terminal(room, Vector2(30.5, 2.9) * TILE, [
		"DR. OKAFOR, PERSONAL LOG: Patient zero's fever broke at 03:00.",
		"By 04:00 the scanners had stopped reading her as human.",
		"QUARANTINE WARDEN: ACTIVE. All staff remain in designated zones.",
	])


# --- Building blocks -----------------------------------------------------------

func _build(path: String, room_name: String, area_id: StringName, fill: Callable, force: bool) -> void:
	if FileAccess.file_exists(path) and not force:
		print("kept %s (pass -- --force to rebuild)" % path)
		return
	var room := Node2D.new()
	room.name = room_name
	room.set_script(load("res://scenes/world/world_area.gd"))
	room.set("area_id", area_id)
	room.y_sort_enabled = true
	_add_layer(room, "Floor", -10)
	_add_layer(room, "Walls", -5)
	_add(room, Node2D.new(), "Spawns")
	_add(room, Node2D.new(), "Doors")
	var entities := _add(room, Node2D.new(), "Entities") as Node2D
	entities.y_sort_enabled = true
	fill.call(room)

	var scene := PackedScene.new()
	scene.pack(room)
	var err := ResourceSaver.save(scene, path)
	print("%s %s" % ["wrote" if err == OK else "FAILED", path])
	room.free()


func _build_tileset() -> TileSet:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(TILE, TILE)
	for layer in [WORLD_LAYER, PITS_LAYER]:
		tileset.add_physics_layer()
		tileset.set_physics_layer_collision_layer(tileset.get_physics_layers_count() - 1, layer)
		tileset.set_physics_layer_collision_mask(tileset.get_physics_layers_count() - 1, 0)

	var source := TileSetAtlasSource.new()
	source.texture = load(ATLAS_PATH)
	source.texture_region_size = Vector2i(TILE, TILE)
	tileset.add_source(source, 0)
	var half := TILE / 2.0
	var square := PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half)])
	for column in COUNT:
		var coords := Vector2i(column, 0)
		source.create_tile(coords)
		var physics_layer := 0 if column in SOLID else 1 if column in PITS else -1
		if physics_layer >= 0:
			var data := source.get_tile_data(coords, 0)
			data.add_collision_polygon(physics_layer)
			data.set_collision_polygon_points(physics_layer, 0, square)

	var err := ResourceSaver.save(tileset, TILESET_PATH)
	print("%s %s" % ["wrote" if err == OK else "FAILED", TILESET_PATH])
	tileset.take_over_path(TILESET_PATH)
	return tileset


## A two-tile-tall doorway in an east or west wall, top tile at `cell`.
func _door_east_west(room: Node2D, cell: Vector2i, target_area: String, target_spawn: StringName) -> void:
	var walls := _layer(room, "Walls")
	for dy in 2:
		walls.erase_cell(cell + Vector2i(0, dy))
		_paint(_layer(room, "Floor"), cell + Vector2i(0, dy), DOOR)
	var door := (load(DOOR_SCENE) as PackedScene).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	door.position = Vector2(cell.x + 0.5, cell.y + 1) * TILE
	door.set("size", Vector2(TILE, TILE * 2))
	door.set("target_area", target_area)
	door.set("target_spawn", target_spawn)
	var doors := room.get_node("Doors")
	_add(doors, door, "To%s" % target_area.get_file().get_basename().trim_prefix("Area_"))


func _terminal(room: Node2D, at: Vector2, lines: PackedStringArray) -> void:
	var terminal := (load(TERMINAL_SCENE) as PackedScene).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE) as Node2D
	terminal.position = at
	terminal.set("lines", lines)
	var entities := room.get_node("Entities")
	_add(entities, terminal, "Terminal%d" % (entities.get_child_count() + 1))


func _spawn(room: Node2D, spawn_name: StringName, at: Vector2) -> void:
	var marker := Marker2D.new()
	marker.position = at
	_add(room.get_node("Spawns"), marker, spawn_name)


func _add_layer(room: Node2D, layer_name: String, z: int) -> void:
	var layer := TileMapLayer.new()
	layer.tile_set = _tileset
	layer.z_index = z
	_add(room, layer, layer_name)


func _layer(room: Node2D, layer_name: String) -> TileMapLayer:
	return room.get_node(layer_name) as TileMapLayer


func _add(parent: Node, node: Node, node_name: String) -> Node:
	node.name = node_name
	parent.add_child(node)
	node.owner = parent if parent.owner == null else parent.owner
	return node


func _fill(layer: TileMapLayer, rect: Rect2i, column: int) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			_paint(layer, Vector2i(x, y), column)


func _outline(layer: TileMapLayer, rect: Rect2i, column: int) -> void:
	_fill(layer, Rect2i(rect.position.x, rect.position.y, rect.size.x, 1), column)
	_fill(layer, Rect2i(rect.position.x, rect.end.y - 1, rect.size.x, 1), column)
	_fill(layer, Rect2i(rect.position.x, rect.position.y, 1, rect.size.y), column)
	_fill(layer, Rect2i(rect.end.x - 1, rect.position.y, 1, rect.size.y), column)


func _paint(layer: TileMapLayer, cell: Vector2i, column: int) -> void:
	layer.set_cell(cell, 0, Vector2i(column, 0))
