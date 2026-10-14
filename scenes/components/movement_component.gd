class_name MovementComponent
extends Node
## Top-down movement with acceleration and friction. The player uses it now;
## enemies will use the same component, so movement feel is tuned in one place.

## Top speed in pixels per second (16 px = one tile).
@export var max_speed := 90.0
## How quickly the body reaches max_speed, in pixels per second squared.
@export var acceleration := 900.0
## How quickly the body stops when there is no input.
@export var friction := 1100.0


## Moves `body` towards `direction` (length 0..1, so analogue sticks walk slowly).
func move(body: CharacterBody2D, direction: Vector2, delta: float) -> void:
	direction = direction.limit_length(1.0)
	if direction.is_zero_approx():
		body.velocity = body.velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		body.velocity = body.velocity.move_toward(direction * max_speed, acceleration * delta)
	body.move_and_slide()
