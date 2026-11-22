class_name BankPulse
extends CharacterBody2D

@export var speed: float = 250.0

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
	
	queue_redraw()

func _draw() -> void:
	var back := -direction * 22.0
	
	draw_line(
		back, 
		Vector2.ZERO,
		Color(1.0, 0.72, 0.35, 0.35),
		3.0,
		true
	)
	draw_line(
		back * 0.45,
		Vector2.ZERO,
		Color(1.0, 0.86, 0.55, 0.7),
		5.0,
		true
	)
	draw_circle(Vector2.ZERO, 5.5, Color(1.0, 0.92, 0.70, 0.95))
	draw_circle(Vector2.ZERO, 2.5, Color.WHITE)
