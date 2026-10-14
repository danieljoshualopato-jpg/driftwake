extends SceneTree
## One-off builder for the placeholder tileset and the first room. After this,
## rooms are painted by hand in the editor, so it refuses to overwrite existing
## files; pass `-- --force` to rebuild anyway (this discards painted changes).
## Run: godot --headless --path . --script res://tools/build_hangar.gd

const TILE := 16
const ATLAS_PATH := "res://assets/tiles/placeholder_tiles.png"
const TILESET_PATH := "res://assets/tiles/placeholder_tileset.tres"
const AREA_PATH := "res://scenes/world/Area_Hangar.tscn"

# Atlas columns, matching tools/gen_placeholder_art.gd.
enum { FLOOR, GRATE, HAZARD, WALL, CRATE, COUNT }
const SOLID := [WALL, CRATE]

# Hangar size in tiles.
const W := 56
const H := 34


func _initialize() -> void:
	var force := "--force" in OS.get_cmdline_user_args()
	var tileset: TileSet
	if FileAccess.file_exists(TILESET_PATH) and not force:
		tileset = load(TILESET_PATH)
		print("kept %s" % TILESET_PATH)
	else:
		tileset = _build_tileset()
	if FileAccess.file_exists(AREA_PATH) and not force:
		print("kept %s (pass -- --force to rebuild)" % AREA_PATH)
	else:
		_build_hangar(tileset)
	quit()


func _build_tileset() -> TileSet:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(TILE, TILE)
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 1)
	tileset.set_physics_layer_collision_mask(0, 0)

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
		if column in SOLID:
			var data := source.get_tile_data(coords, 0)
			data.add_collision_polygon(0)
			data.set_collision_polygon_points(0, 0, square)

	var err := ResourceSaver.save(tileset, TILESET_PATH)
	print("%s %s" % ["wrote" if err == OK else "FAILED", TILESET_PATH])
	tileset.take_over_path(TILESET_PATH)
	return tileset


func _build_hangar(tileset: TileSet) -> void:
	var root := Node2D.new()
	root.name = "Area_Hangar"
	root.set_script(load("res://scenes/world/world_area.gd"))
	root.set("area_id", &"hangar")
	root.y_sort_enabled = true

	var floor_layer := _add_layer(root, "Floor", tileset, -10)
	var walls := _add_layer(root, "Walls", tileset, -5)

	for y in H:
		for x in W:
			_paint(floor_layer, x, y, FLOOR)

	# Landing pad: hazard-striped border around a grate, where the player wakes.
	for y in range(9, 23):
		for x in range(8, 26):
			var edge := y == 9 or y == 22 or x == 8 or x == 25
			_paint(floor_layer, x, y, HAZARD if edge else GRATE)

	# Outer walls.
	for x in W:
		_paint(walls, x, 0, WALL)
		_paint(walls, x, H - 1, WALL)
	for y in H:
		_paint(walls, 0, y, WALL)
		_paint(walls, W - 1, y, WALL)

	# Partition between the main hangar and the storage bay, with a doorway.
	for y in range(1, H - 1):
		if y < 15 or y > 18:
			_paint(walls, 40, y, WALL)

	# Crate stacks. Rects are (x, y, width, height) in tiles.
	for r in [
		Rect2i(30, 5, 2, 2), Rect2i(4, 27, 2, 3), Rect2i(33, 26, 2, 1), Rect2i(33, 27, 1, 1),
		Rect2i(28, 18, 1, 1), Rect2i(43, 3, 3, 3), Rect2i(49, 4, 4, 2), Rect2i(44, 24, 3, 4),
		Rect2i(50, 28, 2, 3), Rect2i(52, 12, 2, 1), Rect2i(52, 13, 1, 1),
	]:
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				_paint(walls, x, y, CRATE)

	var spawns := _add(root, Node2D.new(), "Spawns")
	var start := _add(spawns, Marker2D.new(), "start") as Marker2D
	start.position = Vector2(17, 16) * TILE
	_add(root, Node2D.new(), "Doors")
	var entities := _add(root, Node2D.new(), "Entities") as Node2D
	entities.y_sort_enabled = true

	var scene := PackedScene.new()
	scene.pack(root)
	var err := ResourceSaver.save(scene, AREA_PATH)
	print("%s %s" % ["wrote" if err == OK else "FAILED", AREA_PATH])
	root.free()


func _add_layer(root: Node, layer_name: String, tileset: TileSet, z: int) -> TileMapLayer:
	var layer := TileMapLayer.new()
	layer.tile_set = tileset
	layer.z_index = z
	return _add(root, layer, layer_name)


func _add(parent: Node, node: Node, node_name: String) -> Node:
	node.name = node_name
	parent.add_child(node)
	var scene_root := parent if parent.owner == null else parent.owner
	node.owner = scene_root
	return node


func _paint(layer: TileMapLayer, x: int, y: int, column: int) -> void:
	layer.set_cell(Vector2i(x, y), 0, Vector2i(column, 0))
