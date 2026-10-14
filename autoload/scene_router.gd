extends Node
## The one thing that loads areas. Main registers the world container and the
## persistent player once; after that, anything (doors, from Phase 1) can call
## change_area() and the router handles the fade, the swap and the spawn.

const FADE_TIME := 0.25

var current_area: WorldArea

var _world: Node2D
var _player: Player
var _busy := false
var _fade_rect: ColorRect


func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color.BLACK
	_fade_rect.modulate.a = 0.0
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_fade_rect)


func setup(world: Node2D, player: Player) -> void:
	_world = world
	_player = player


func change_area(area_path: String, spawn: StringName, fade := true) -> void:
	if _busy:
		return
	var scene := load(area_path) as PackedScene
	if scene == null:
		push_error("SceneRouter: cannot load area '%s'" % area_path)
		return
	_busy = true
	if fade:
		await _fade_to(1.0)

	if current_area:
		_world.remove_child(current_area)
		current_area.queue_free()
	current_area = scene.instantiate() as WorldArea
	_world.add_child(current_area)
	_player.place_at(current_area.get_spawn_position(spawn))
	_player.set_camera_limits(current_area.get_camera_limits())

	GameState.current_area = area_path
	GameState.current_spawn = spawn
	EventBus.area_entered.emit(current_area.area_id)

	if fade:
		await _fade_to(0.0)
	_busy = false


func _fade_to(alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(_fade_rect, "modulate:a", alpha, FADE_TIME)
	await tween.finished
