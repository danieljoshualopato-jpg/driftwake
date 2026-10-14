extends Node
## Headless smoke test. Main adds it when the game runs with `-- --smoke-test`
## (tools/check.ps1 does this). It drives the player with simulated input and
## quits with exit code 0 if every check passes, 1 otherwise.

const REQUIRED_ACTIONS: Array[StringName] = [
	&"move_left", &"move_right", &"move_up", &"move_down",
	&"attack", &"interact", &"inventory", &"pause", &"debug_overlay",
]

var _failures := 0
var _player: Player
var _messages: PackedStringArray = []
var _prompts: PackedStringArray = []


func _ready() -> void:
	EventBus.message_posted.connect(func(text: String) -> void: _messages.append(text))
	EventBus.interaction_prompt_changed.connect(func(prompt: String) -> void: _prompts.append(prompt))
	await get_tree().physics_frame
	_player = get_parent().get_node("World/Player") as Player

	for action in REQUIRED_ACTIONS:
		_check(InputMap.has_action(action) and InputMap.action_get_events(action).size() >= 2,
			"input action '%s' has keyboard and gamepad bindings" % action)

	await _test_hangar_movement()
	await _test_doors()
	await _test_terminal()
	await _test_pit()
	await _test_debug_overlay()

	print("SMOKE TEST: %s" % ("PASSED" if _failures == 0 else "FAILED (%d)" % _failures))
	get_tree().quit(0 if _failures == 0 else 1)


func _test_hangar_movement() -> void:
	var area := SceneRouter.current_area
	_check(area != null and area.area_id == &"hangar", "first area is the hangar")
	_check(area.get_camera_limits() == Rect2i(0, 0, 896, 544), "camera limits match the hangar floor")
	var spawn := area.get_spawn_position(&"start")
	_check(_player.global_position.distance_to(spawn) < 1.0, "player starts at the spawn point")

	await _hold(&"move_right", 30)
	_check(_player.global_position.x - spawn.x > 20.0, "holding right moves the player right")

	await _wait(30)
	_check(_player.velocity.is_zero_approx(), "player stops when input is released")

	await _hold(&"move_left", 360)
	_check(_player.global_position.x >= 16.0 and _player.global_position.x < 40.0,
		"walking left stops at the hangar's west wall (x = %.1f)" % _player.global_position.x)


func _test_doors() -> void:
	# Hangar east door -> corridor.
	_player.place_at(Vector2(840, 272))
	await _walk_through_door(&"move_right")
	_check(_area_id() == &"corridor", "hangar's east door leads to the corridor")
	_check(_at_spawn(&"from_hangar"), "player arrives at the corridor's from_hangar spawn")
	var camera := _player.get_node("Camera2D") as Camera2D
	_check(camera.limit_bottom - camera.limit_top >= 360 and camera.limit_top < 0,
		"a room shorter than the screen is centred vertically")

	# Corridor east door -> medbay.
	_player.place_at(Vector2(720, 104))
	await _walk_through_door(&"move_right")
	_check(_area_id() == &"medbay", "corridor's east door leads to the medbay")
	_check(_at_spawn(&"from_corridor"), "player arrives at the medbay's from_corridor spawn")

	# And back: medbay west door -> corridor.
	_player.place_at(Vector2(40, 200))
	await _walk_through_door(&"move_left")
	_check(_area_id() == &"corridor", "medbay's west door leads back to the corridor")
	_check(_at_spawn(&"from_medbay"), "player arrives at the corridor's from_medbay spawn")


func _test_terminal() -> void:
	# The corridor terminal stands at (392, 46); approach it from below.
	_player.place_at(Vector2(392, 64))
	await _hold(&"move_up", 20)
	_check(_prompts.size() > 0 and _prompts[-1] == "Read terminal", "standing at a terminal shows its prompt")
	var before := _messages.size()
	await _press(&"interact")
	_check(_messages.size() == before + 1 and _messages[-1].begins_with("MAINTENANCE"),
		"interacting with the terminal posts its first line")
	await _press(&"interact")
	_check(_messages.size() == before + 2 and _messages[-1].begins_with("Ticket closed"),
		"interacting again posts the next line")
	await _hold(&"move_down", 30)
	_check(_prompts[-1] == "", "walking away clears the prompt")


func _test_pit() -> void:
	await _walk_through_door(&"move_right", Vector2(720, 104))
	_check(_area_id() == &"medbay", "back in the medbay for the pit test")
	# The pit fills tiles (22..27, 14..18); its top edge is y = 224.
	_player.place_at(Vector2(392, 192))
	await _hold(&"move_down", 90)
	_check(_player.global_position.y <= 224.5 and _player.global_position.y > 210.0,
		"the pit blocks the player at its edge (y = %.1f)" % _player.global_position.y)


func _test_debug_overlay() -> void:
	var overlay := get_parent().get_node("DebugOverlay") as CanvasLayer
	_check(not overlay.visible, "debug overlay starts hidden")
	await _press(&"debug_overlay")
	_check(overlay.visible, "debug overlay toggles on")
	await _press(&"debug_overlay")
	_check(not overlay.visible, "debug overlay toggles off")


## Walks in `direction` until the area changes (or 3 seconds pass), then waits
## for the fade-in to finish. `from` optionally teleports the player first.
func _walk_through_door(direction: StringName, from := Vector2.INF) -> void:
	if from != Vector2.INF:
		_player.place_at(from)
	var start := SceneRouter.current_area
	Input.action_press(direction)
	for i in 180:
		await get_tree().physics_frame
		if SceneRouter.current_area != start:
			break
	Input.action_release(direction)
	await _wait(40)


func _area_id() -> StringName:
	return SceneRouter.current_area.area_id


func _at_spawn(spawn: StringName) -> bool:
	return _player.global_position.distance_to(SceneRouter.current_area.get_spawn_position(spawn)) < 2.0


func _check(ok: bool, what: String) -> void:
	print(("  ok    " if ok else "  FAIL  ") + what)
	if not ok:
		_failures += 1


func _hold(action: StringName, frames: int) -> void:
	Input.action_press(action)
	await _wait(frames)
	Input.action_release(action)


func _press(action: StringName) -> void:
	for pressed in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)
		await _wait(2)


func _wait(frames: int) -> void:
	for i in frames:
		await get_tree().physics_frame
