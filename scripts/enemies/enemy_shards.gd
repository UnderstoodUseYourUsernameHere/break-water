class_name EnemyShards
extends Node2D

@export var tint: Color = Color("#e3572b")
@export var count: int = 8 
@export var lifetime: float = 0.45
@export var drag: float = 3.4

var _pos: Array[Vector2] = []
var _vel: Array[Vector2] = []
var _rot: Array[float] = []
var _spin: Array[float] = []
var _size: Array[float] = []
var _age: float = 0.0


func _ready() -> void:
	for i in range(count):
		var angle := randf_range(0.0, TAU)
		_pos.append(Vector2.ZERO)
		_vel.append(Vector2.RIGHT.rotated(angle) * randf_range(95.0, 240.0))
		_rot.append(randf_range(0.0, TAU))
		_spin.append(randf_range(-10.0, 10.0))
		_size.append(randf_range(3.0, 6.5))

func _process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		queue_free()
		return
	
	var damp := exp(-drag * delta)
	for i in range(_pos.size()):
		_pos[i] = _pos[i] + _vel[i] * delta
		_vel[i] = _vel[i] * damp
		_rot[i] = _rot[i] + _spin[i] * delta
	
	queue_redraw()

func _draw() -> void:
	var k := 1.0 -_age / lifetime
	var color := Color(tint.r, tint.g, tint.b, tint.a * k)
	
	for i in range(_pos.size()):
		var s := _size[i] * k
		var at := _pos[i]
		var r := _rot[i]
		
		draw_colored_polygon(
			PackedVector2Array([
				Vector2(0.0, -s).rotated(r) + at,
				Vector2(s * 0.85, s * 0.72).rotated(r) + at,
				Vector2(-s * 0.85, s * 0.72).rotated(r) + at,
			]),
			color
		)
