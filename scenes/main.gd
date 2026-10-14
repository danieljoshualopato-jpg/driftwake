extends Node
## Boot scene. Owns the World container and the persistent Player, then hands
## the first area to SceneRouter. Areas come and go; the player stays.

@export_file("*.tscn") var first_area := "res://scenes/world/Area_Hangar.tscn"
@export var first_spawn := &"start"

@onready var _world: Node2D = $World
@onready var _player: Player = $World/Player


func _ready() -> void:
	SceneRouter.setup(_world, _player)
	SceneRouter.change_area(first_area, first_spawn, false)
	if "--smoke-test" in OS.get_cmdline_user_args():
		add_child(load("res://tests/smoke_test.gd").new())
