extends Line2D

@export var idle_width: float = 2.0
@export var lock_width: float = 5.0
@export var pulse_speed: float = 11.0

@export var near_color := Color(1.0, 0.55, 0.25, 0.08)
@export var far_color := Color(1.0, 0.32, 0.18, 0.9)

func _ready() -> void:
	var g := Gradient.new()
	g.set_offset(0, 0.0)
	g.set_offset(1, 1.0)
	g.set_color(0, near_color)
	g.set_color(1, far_color)
	gradient = g
	
	var c := Curve.new()
	c.add_point(Vector2(0.0, 0.3))
	c.add_point(Vector2(1.0, 1.0))
	width_curve = c
	
	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND

func _process(delta: float) -> void:
	if not visible:
		return
	
	var t := 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * 0.001 * pulse_speed)
	width = lerpf(idle_width, lock_width, t)
