class_name BankPulse
extends CharacterBody2D

@export var speed: float = 175.0

var target: Boat
var direction := Vector2.RIGHT
var remaining_px: float = 0.0

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target) or target.is_sunk or remaining_px <= 0.0:
		queue_free()
		return
	
	var step_px := minf(speed * delta, remaining_px)
	var collision := move_and_collide(direction * step_px)
	remaining_px -= step_px
	
	if collision != null:
		if collision.get_collider() == target:
			target.take_damage(1)
		queue_free()
	elif remaining_px <= 0.0:
		queue_free()
