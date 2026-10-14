class_name Player
extends CharacterBody2D
## The player character. Reads input and hands it to MovementComponent.
## The origin sits at the feet so y-sorting works once props exist.

## How far ahead of the body the facing marker sits, in pixels.
@export var facing_marker_distance := 7.0

## Last direction moved, snapped to four ways. Attacks and interaction aim with it.
var facing := Vector2.DOWN

@onready var _movement: MovementComponent = $MovementComponent
@onready var _camera: Camera2D = $Camera2D
@onready var _facing_marker: Node2D = $FacingMarker


func _physics_process(delta: float) -> void:
	var input := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if not input.is_zero_approx():
		facing = _snap_four_way(input)
	_movement.move(self, input, delta)
	_facing_marker.position = Vector2(0, -8) + facing * facing_marker_distance


## Teleports the player (area changes, respawns) without the camera sliding across.
func place_at(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	reset_physics_interpolation()
	_camera.reset_smoothing()


## Stops the camera at the area's edges, in world pixels.
func set_camera_limits(rect: Rect2i) -> void:
	_camera.limit_left = rect.position.x
	_camera.limit_top = rect.position.y
	_camera.limit_right = rect.end.x
	_camera.limit_bottom = rect.end.y
	_camera.reset_smoothing()


static func _snap_four_way(v: Vector2) -> Vector2:
	if absf(v.x) > absf(v.y):
		return Vector2(signf(v.x), 0)
	return Vector2(0, signf(v.y))
