class_name Interactable
extends Area2D
## Something the player can use with the interact button. Add it as a child of
## any prop, set `prompt` to what the button does, and connect `interacted`.
## Put it on the "interactables" physics layer so the player's probe finds it.

signal interacted(by: Node)

## Shown next to the button hint, e.g. "[E] Read terminal".
@export var prompt := "Use"


func interact(by: Node) -> void:
	interacted.emit(by)
