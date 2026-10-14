extends CanvasLayer
## F3 overlay: FPS, current area, player position (pixels and tile) and velocity.

@onready var _label: Label = $Label


func _ready() -> void:
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"debug_overlay"):
		visible = not visible
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if not visible:
		return
	var lines := PackedStringArray(["FPS  %d" % Engine.get_frames_per_second()])
	if SceneRouter.current_area:
		lines.append("Area %s" % SceneRouter.current_area.area_id)
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player:
		var pos := player.global_position
		lines.append("Pos  %d, %d" % [pos.x, pos.y])
		lines.append("Tile %d, %d" % [floori(pos.x / 16.0), floori(pos.y / 16.0)])
		lines.append("Vel  %d, %d" % [player.velocity.x, player.velocity.y])
	_label.text = "\n".join(lines)
