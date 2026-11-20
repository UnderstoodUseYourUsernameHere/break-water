extends Line2D

@export var fade_time: float = 0.12

var _time_left: float = 0.0

func _ready() -> void:
	visible = false

func show_shot(from: Vector2, to: Vector2, _hit_target: bool) -> void:
	clear_points()
	add_point(to_local(from))
	add_point(to_local(to))
	_time_left = fade_time
	modulate.a = 1.0
	visible = true

func _process(delta: float) -> void:
	if _time_left <= 0.0:
		return
	_time_left -= delta
	modulate.a = clampf(_time_left / fade_time, 0.0, 1.0)
	if _time_left <= 0.0:
		visible = false
