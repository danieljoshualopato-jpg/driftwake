@tool
class_name Door
extends Area2D
## A doorway trigger. When the player walks into it, SceneRouter fades to
## `target_area` and puts the player on its `target_spawn` marker. Doors are
## data: drop one into an area's Doors node and fill in the fields.

@export_file("*.tscn") var target_area := ""
@export var target_spawn := &""
## Trigger size in pixels. 16 x 32 fits a two-tile east or west doorway.
@export var size := Vector2(16, 32):
	set(value):
		size = value
		if is_node_ready():
			_update_shape()

@onready var _shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	_update_shape()
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)


func _update_shape() -> void:
	(_shape.shape as RectangleShape2D).size = size


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		SceneRouter.change_area.call_deferred(target_area, target_spawn)
