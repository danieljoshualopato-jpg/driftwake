class_name Player
extends CharacterBody2D
## The player character. Reads input and hands it to MovementComponent, and
## probes ahead for Interactables to use with the interact button.
## The origin sits at the feet so y-sorting works with props.

## How far ahead of the body the facing marker sits, in pixels.
@export var facing_marker_distance := 7.0
## How far ahead of the body the interaction probe reaches, in pixels.
@export var interact_reach := 8.0

## Last direction moved, snapped to four ways. Attacks and interaction aim with it.
var facing := Vector2.DOWN
## Off while SceneRouter swaps areas, so the player coasts to a stop.
var controls_enabled := true

var _interact_target: Interactable

@onready var _movement: MovementComponent = $MovementComponent
@onready var _camera: Camera2D = $Camera2D
@onready var _facing_marker: Node2D = $FacingMarker
@onready var _interaction_area: Area2D = $InteractionArea


func _physics_process(delta: float) -> void:
	var input := Vector2.ZERO
	if controls_enabled:
		input = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if not input.is_zero_approx():
		facing = _snap_four_way(input)
	_movement.move(self, input, delta)
	_facing_marker.position = Vector2(0, -8) + facing * facing_marker_distance
	_interaction_area.position = Vector2(0, -6) + facing * interact_reach
	_update_interact_target()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact") and controls_enabled and is_instance_valid(_interact_target):
		_interact_target.interact(self)
		get_viewport().set_input_as_handled()


## Teleports the player (area changes, respawns) without the camera sliding across.
func place_at(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	reset_physics_interpolation()
	_camera.reset_smoothing()


## Stops the camera at the area's edges, in world pixels. A room smaller than
## the screen is centred instead of pinned to its top-left corner.
func set_camera_limits(rect: Rect2i) -> void:
	var view := Vector2i(get_viewport_rect().size)
	var pad := (view - rect.size).maxi(0)
	rect = rect.grow_individual(pad.x / 2, pad.y / 2, pad.x - pad.x / 2, pad.y - pad.y / 2)
	_camera.limit_left = rect.position.x
	_camera.limit_top = rect.position.y
	_camera.limit_right = rect.end.x
	_camera.limit_bottom = rect.end.y
	_camera.reset_smoothing()


func _update_interact_target() -> void:
	var best: Interactable = null
	var best_distance := INF
	for area in _interaction_area.get_overlapping_areas():
		if area is Interactable:
			var distance := area.global_position.distance_squared_to(_interaction_area.global_position)
			if distance < best_distance:
				best = area
				best_distance = distance
	if best != _interact_target:
		_interact_target = best
		EventBus.interaction_prompt_changed.emit(best.prompt if best else "")


static func _snap_four_way(v: Vector2) -> Vector2:
	if absf(v.x) > absf(v.y):
		return Vector2(signf(v.x), 0)
	return Vector2(0, signf(v.y))
