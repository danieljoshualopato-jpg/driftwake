extends StaticBody2D
## A wall terminal holding a short log. Each use shows the next line.

@export_multiline var lines: PackedStringArray = []

var _next := 0


func _ready() -> void:
	$Interactable.interacted.connect(_on_interacted)


func _on_interacted(_by: Node) -> void:
	if lines.is_empty():
		return
	EventBus.message_posted.emit(lines[_next])
	_next = (_next + 1) % lines.size()
