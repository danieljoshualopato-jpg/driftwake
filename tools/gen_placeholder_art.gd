extends SceneTree
## Generates the placeholder pixel art: a 16 px tile atlas and the player square.
## Run: godot --headless --path . --script res://tools/gen_placeholder_art.gd
## Real art replaces these files later without any code changes.

const TILE := 16
const ATLAS_PATH := "res://assets/tiles/placeholder_tiles.png"
const PLAYER_PATH := "res://assets/sprites/player_placeholder.png"
const TERMINAL_PATH := "res://assets/sprites/terminal_placeholder.png"

# Atlas columns, in order. tools/build_rooms.gd uses the same indices.
# Only ever append: painted maps refer to tiles by column.
enum { FLOOR, GRATE, HAZARD, WALL, CRATE, PIT, DOOR, MED_FLOOR, BED, COUNT }


func _initialize() -> void:
	var atlas := Image.create_empty(TILE * COUNT, TILE, false, Image.FORMAT_RGBA8)
	_floor(atlas, FLOOR * TILE)
	_grate(atlas, GRATE * TILE)
	_hazard(atlas, HAZARD * TILE)
	_wall(atlas, WALL * TILE)
	_crate(atlas, CRATE * TILE)
	_pit(atlas, PIT * TILE)
	_door(atlas, DOOR * TILE)
	_med_floor(atlas, MED_FLOOR * TILE)
	_bed(atlas, BED * TILE)
	_save(atlas, ATLAS_PATH)
	_save(_player(), PLAYER_PATH)
	_save(_terminal(), TERMINAL_PATH)
	quit()


func _floor(img: Image, ox: int) -> void:
	img.fill_rect(Rect2i(ox, 0, TILE, TILE), Color("2a2f37"))
	img.fill_rect(Rect2i(ox, 0, TILE, 1), Color("363c46"))
	img.fill_rect(Rect2i(ox, 0, 1, TILE), Color("363c46"))
	img.fill_rect(Rect2i(ox, TILE - 1, TILE, 1), Color("1f232a"))
	img.fill_rect(Rect2i(ox + TILE - 1, 0, 1, TILE), Color("1f232a"))
	for p in [Vector2i(2, 2), Vector2i(13, 2), Vector2i(2, 13), Vector2i(13, 13)]:
		img.set_pixel(ox + p.x, p.y, Color("4a515d"))


func _grate(img: Image, ox: int) -> void:
	img.fill_rect(Rect2i(ox, 0, TILE, TILE), Color("1d2127"))
	for y in range(1, TILE, 3):
		img.fill_rect(Rect2i(ox + 1, y, TILE - 2, 1), Color("2c3139"))


func _hazard(img: Image, ox: int) -> void:
	for y in TILE:
		for x in TILE:
			var stripe := ((x + y) / 4) % 2 == 0
			img.set_pixel(ox + x, y, Color("d9a520") if stripe else Color("22252b"))


func _wall(img: Image, ox: int) -> void:
	img.fill_rect(Rect2i(ox, 0, TILE, TILE), Color("4b5567"))
	img.fill_rect(Rect2i(ox, 0, TILE, 2), Color("7a879d"))
	img.fill_rect(Rect2i(ox, 12, TILE, 4), Color("343b48"))
	img.fill_rect(Rect2i(ox + 8, 2, 1, 10), Color("3f4757"))


func _crate(img: Image, ox: int) -> void:
	img.fill_rect(Rect2i(ox, 0, TILE, TILE), Color("5a3a1b"))
	img.fill_rect(Rect2i(ox + 1, 1, TILE - 2, TILE - 2), Color("8b5a2b"))
	img.fill_rect(Rect2i(ox + 1, 1, TILE - 2, 1), Color("a8743d"))
	for i in range(2, TILE - 2):
		img.set_pixel(ox + i, i, Color("6e4622"))
		img.set_pixel(ox + TILE - 1 - i, i, Color("6e4622"))


func _pit(img: Image, ox: int) -> void:
	img.fill_rect(Rect2i(ox, 0, TILE, TILE), Color("07080a"))
	for p in [Vector2i(3, 9), Vector2i(11, 5), Vector2i(7, 13), Vector2i(13, 11)]:
		img.set_pixel(ox + p.x, p.y, Color("15181d"))


func _door(img: Image, ox: int) -> void:
	img.fill_rect(Rect2i(ox, 0, TILE, TILE), Color("22262d"))
	img.fill_rect(Rect2i(ox + 2, 0, 1, TILE), Color("2f343c"))
	img.fill_rect(Rect2i(ox + 13, 0, 1, TILE), Color("2f343c"))
	for y in [1, 14]:
		img.set_pixel(ox + 2, y, Color("3ddc84"))
		img.set_pixel(ox + 13, y, Color("3ddc84"))


func _med_floor(img: Image, ox: int) -> void:
	img.fill_rect(Rect2i(ox, 0, TILE, TILE), Color("8fa3a8"))
	img.fill_rect(Rect2i(ox, 0, TILE, 1), Color("a7b8bc"))
	img.fill_rect(Rect2i(ox, 0, 1, TILE), Color("a7b8bc"))
	img.fill_rect(Rect2i(ox, TILE - 1, TILE, 1), Color("74878c"))
	img.fill_rect(Rect2i(ox + TILE - 1, 0, 1, TILE), Color("74878c"))


func _bed(img: Image, ox: int) -> void:
	img.fill_rect(Rect2i(ox, 0, TILE, TILE), Color("5b6670"))
	img.fill_rect(Rect2i(ox + 2, 2, 12, 12), Color("d8e0e3"))
	img.fill_rect(Rect2i(ox + 3, 2, 10, 3), Color("f2f5f6"))
	img.fill_rect(Rect2i(ox + 2, 8, 12, 6), Color("4fa3a0"))


func _terminal() -> Image:
	var img := Image.create_empty(TILE, TILE, false, Image.FORMAT_RGBA8)
	img.fill_rect(Rect2i(2, 2, 12, 14), Color("2a303a"))
	img.fill_rect(Rect2i(3, 3, 10, 12), Color("3a4250"))
	img.fill_rect(Rect2i(4, 4, 8, 6), Color("0f2a1e"))
	img.fill_rect(Rect2i(5, 5, 5, 1), Color("3ddc84"))
	img.fill_rect(Rect2i(5, 7, 3, 1), Color("3ddc84"))
	img.fill_rect(Rect2i(4, 12, 8, 1), Color("525c6c"))
	return img


func _player() -> Image:
	var img := Image.create_empty(TILE, TILE, false, Image.FORMAT_RGBA8)
	img.fill_rect(Rect2i(3, 2, 10, 14), Color("1d6f6b"))
	img.fill_rect(Rect2i(4, 3, 8, 12), Color("39c6be"))
	img.fill_rect(Rect2i(5, 5, 6, 3), Color("0e2a30"))
	img.set_pixel(6, 5, Color("9ff5ef"))
	return img


func _save(img: Image, path: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var err := img.save_png(path)
	print("%s %s" % ["wrote" if err == OK else "FAILED", path])
