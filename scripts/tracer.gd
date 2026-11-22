extends Line2D

@export var fade_time: float = 0.13
@export var impact_time: float = 0.20

const HIT_COLOR := Color(1.0, 0.92, 0.72, 1.0)
const MISS_COLOR := Color(0.70, 0.84, 0.90, 1.0)

var _life: float = 0.0
var _impact_life: float = 0.0
var _impact_at := Vector2.ZERO
var _muzzle_at := Vector2.ZERO
var _hit_target := false

func _ready() -> void:
	top_level = true
	global_transform = Transform2D.IDENTITY
	clear_points()
	visible = false
	_build_style()

func _build_style() -> void:
	var g := Gradient.new()
	g.set_offset(0, 0.0)
	g.set_offset(1, 1.0)
	g.set_color(0, Color(1.0, 0.97, 0.86, 1.0))
	g.set_color(1, Color(1.0, 0.86, 0.60, 0.15))
	gradient = g 
	
	var c := Curve.new()
	c.add_point(Vector2(0.0, 1.0))
	c.add_point(Vector2(0.35, 0.55))
	c.add_point(Vector2(1.0, 0.18))
	width_curve = c
	
	width = 6.0
	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND

func show_shot(from: Vector2, to: Vector2, hit_target: bool) -> void:
	clear_points()
	add_point(from)
	add_point(to)
	
	_muzzle_at = from
	_impact_at = to
	_hit_target = hit_target
	_life = fade_time
	_impact_life = impact_time
	
	modulate.a = 1.0
	visible = true
	queue_redraw()

func _process(delta: float) -> void:
	if _life <= 0.0 and _impact_life <= 0.0:
		return
	
	_life = maxf(0.0, _life - delta)
	_impact_life = maxf(0.0, _impact_life - delta)
	
	modulate.a = clamp(_life / fade_time, 0.0, 1.0)
	
	if _life <= 0.0:
		clear_points()
	
	if _life <= 0.0 and _impact_life <= 0.0:
		visible = false
	
	queue_redraw()

func _draw() -> void:
	if _life > 0.0:
		var flash := _life / fade_time
		draw_circle(
			_muzzle_at,
			7.0 * flash,
			Color(1.0, 0.95, 0.78, 0.55 * flash)
		)
	
	if _impact_life <= 0.0:
		return 
	
	var k := _impact_life / impact_time
	var tint: Color = HIT_COLOR if _hit_target else MISS_COLOR
	var spokes := 6 if _hit_target else 4
	var reach := (16.0 if _hit_target else 9.0) * (1.0 - k) + 3.0
	
	draw_circle(
		_impact_at,
		(5.0 if _hit_target else 3.0) * k,
		Color(tint.r, tint.g, tint.b, 0.8 * k)
	)
	
	for i in range(spokes):
		var angle := TAU * float(i) / float(spokes) + float(_hit_target) * 0.4
		var dir := Vector2.RIGHT.rotated(angle)
		draw_line(
			_impact_at + dir * 3.0,
			_impact_at + dir * reach,
			Color(tint.r, tint.g, tint.b, 0.85 * k),
			2.0 * k,
			true
		)
