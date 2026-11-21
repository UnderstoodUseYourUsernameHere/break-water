class_name ScrapPickup
extends Node2D

@export var value: int = 1
@export var float_time: float  = 0.22
@export var magnet_speed: float = 560.0
@export var collect_distance: float = 20.0
@export var max_lifetime: float = 4.0

var target: Boat
var run_state: RunState

var _age: float = 0.0
var _float_velocity := Vector2.ZERO

func _ready() -> void:
	_float_velocity = Vector2(
		randf_range(-45.0, 45.0),
		randf_range(-65.0, -25.0)
	)
	queue_redraw()

func _process(delta: float) -> void:
	_age += delta
	
	if _age >= max_lifetime:
		_collect()
		return
	
	if _age < float_time or not is_instance_valid(target):
		global_position += _float_velocity * delta
		return
	
	var to_target := target.global_position - global_position
	if to_target.length() <= collect_distance:
		_collect()
		return
	
	global_position += to_target.normalized() * magnet_speed * delta

func _collect() -> void:
	if run_state != null:
		run_state.add_scrap(value)
	queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 6.0, Color("#e69c56"))
	draw_circle(Vector2.ZERO, 2.5, Color("fff3d6"))
