extends Node
## Headless smoke test. Main adds it when the game runs with `-- --smoke-test`
## (tools/check.ps1 does this). It drives the player with simulated input and
## quits with exit code 0 if every check passes, 1 otherwise.

const REQUIRED_ACTIONS: Array[StringName] = [
	&"move_left", &"move_right", &"move_up", &"move_down",
	&"attack", &"interact", &"inventory", &"pause",
]

var _failures := 0


func _ready() -> void:
	await get_tree().physics_frame
	var player := get_parent().get_node("World/Player") as Player
	var area := SceneRouter.current_area

	for action in REQUIRED_ACTIONS:
		_check(InputMap.has_action(action) and InputMap.action_get_events(action).size() >= 2,
			"input action '%s' has keyboard and gamepad bindings" % action)

	_check(area != null and area.area_id == &"hangar", "first area is the hangar")
	_check(area.get_camera_limits() == Rect2i(0, 0, 896, 544), "camera limits match the hangar floor")
	var spawn := area.get_spawn_position(&"start")
	_check(player.global_position.distance_to(spawn) < 1.0, "player starts at the spawn point")

	await _hold(&"move_right", 30)
	_check(player.global_position.x - spawn.x > 20.0, "holding right moves the player right")

	await _wait(30)
	_check(player.velocity.is_zero_approx(), "player stops when input is released")

	await _hold(&"move_left", 360)
	_check(player.global_position.x >= 16.0 and player.global_position.x < 40.0,
		"walking left stops at the hangar's west wall (x = %.1f)" % player.global_position.x)

	print("SMOKE TEST: %s" % ("PASSED" if _failures == 0 else "FAILED (%d)" % _failures))
	get_tree().quit(0 if _failures == 0 else 1)


func _check(ok: bool, what: String) -> void:
	print(("  ok    " if ok else "  FAIL  ") + what)
	if not ok:
		_failures += 1


func _hold(action: StringName, frames: int) -> void:
	Input.action_press(action)
	await _wait(frames)
	Input.action_release(action)


func _wait(frames: int) -> void:
	for i in frames:
		await get_tree().physics_frame
