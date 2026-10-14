class_name WorldArea
extends Node2D
## Base script for every area scene. An area is one room: a Floor and Walls
## tile layer, named spawn points under Spawns, and (from Phase 1) Doors.
## SceneRouter instances it and asks where to put the player and the camera.

@export var area_id: StringName

@onready var _floor: TileMapLayer = $Floor


func get_spawn_position(spawn: StringName) -> Vector2:
	var marker := get_node_or_null(NodePath("Spawns/" + String(spawn))) as Node2D
	if marker == null:
		push_warning("%s has no spawn point '%s'" % [name, spawn])
		return Vector2(get_camera_limits().get_center())
	return marker.global_position


## Camera bounds in world pixels: the painted extent of the Floor layer.
func get_camera_limits() -> Rect2i:
	var used := _floor.get_used_rect()
	var tile := _floor.tile_set.tile_size
	var origin := Vector2i(_floor.global_position)
	return Rect2i(origin + used.position * tile, used.size * tile)
