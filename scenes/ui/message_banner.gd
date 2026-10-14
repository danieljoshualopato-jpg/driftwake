extends CanvasLayer
## Bottom-of-screen text: terminal lines and other one-off messages, plus the
## "[E] Read terminal" hint while the player is next to something usable.
## Phase 3 replaces the messages with the full DialogueBox.

## Seconds a message stays on screen.
@export var message_duration := 4.0

@onready var _message: Label = $Message
@onready var _prompt: Label = $Prompt
@onready var _timer: Timer = $Timer


func _ready() -> void:
	_message.hide()
	_prompt.hide()
	_timer.timeout.connect(_message.hide)
	EventBus.message_posted.connect(_on_message_posted)
	EventBus.interaction_prompt_changed.connect(_on_interaction_prompt_changed)


func _on_message_posted(text: String) -> void:
	_message.text = text
	_message.show()
	_timer.start(message_duration)


func _on_interaction_prompt_changed(prompt: String) -> void:
	_prompt.visible = prompt != ""
	_prompt.text = "[%s] %s" % [_key_name(&"interact"), prompt]


static func _key_name(action: StringName) -> String:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return event.as_text_physical_keycode()
	return String(action)
