extends Node2D

const OAR_COLOR := Color("c9b98f")
const FEATHER_COLOR := Color("#8f8468")
const SPLASH_COLOR := Color(0.80, 0.92, 0.94, 0.6)

@export var oar_length: float = 26.0
@export var catch_angle: float = -0.62
@export var finish_angle: float = 0.70
@export var pivot_offset := Vector2(9.0, 2.0)

var _boat: Boat
var _sweep: float = 0.0
var _in_water: float = 0.0
var _shipped: float = 0.0
var _splash: float = 0.0

func _ready() -> void:
	_boat = get_parent() as Boat
	assert(_boat != null, "Oars must be a direct child of Boat.")
	_sweep = catch_angle
	_boat.stroked.connect(_on_stroked)

func _on_stroked(_perfect: bool) -> void:
	_splash = 1.0

func _process(delta: float) -> void:
	var progress := _boat.get_stroke_progress()
	
	match _boat.get_stroke_state():
		Boat.Stroke.DRIVE:
			_sweep = lerpf(catch_angle, finish_angle, ease(progress, 0.65))
			_in_water = move_toward(_in_water, 1.0, delta * 16.0)
		
		Boat.Stroke.RECOVER:
			_sweep = lerpf(finish_angle, catch_angle, ease(progress, 2.1))
			_in_water= move_toward(_in_water, 0.0, delta * 9.0)
		_:
			_sweep = move_toward(_sweep, catch_angle, delta * 5.0)
			_in_water = move_toward(_in_water, 0.0, delta * 9.0)
	
	var ship_goal := 1.0 if (_boat.is_aiming or _boat.is_sunk) else 0.0
	_shipped = move_toward(_shipped, ship_goal, delta * 6.0)
	_splash = maxf(0.0, _splash - delta * 3.6)
	
	queue_redraw()

func _draw() -> void:
	for side in [-1.0, 1.0]:
		var pivot := Vector2(pivot_offset.x * side, pivot_offset.y)
		var out_dir := Vector2(side, 0.0).rotated(_sweep * side)
		var shipped_dir := Vector2(0.22 * side, 1.0).normalized()
		var dir := out_dir.lerp(shipped_dir, _shipped).normalized()
		
		var tip := pivot + dir * oar_length
		var shaft_color := FEATHER_COLOR.lerp(OAR_COLOR, _in_water)
		draw_line(pivot, tip, shaft_color, 2.0, true)
		
		var blade_width := lerpf(2.2, 5.5, _in_water) * (1.0 - _shipped * 0.55)
		draw_line(tip - dir * 8.0, tip, shaft_color, blade_width, true)
		
		if _splash > 0.01 and _in_water > 0.35 and _shipped < 0.5:
			var alpha := SPLASH_COLOR.a * _splash
			draw_circle(
				tip,
				5.5 * _splash,
				Color(SPLASH_COLOR.r, SPLASH_COLOR.g, SPLASH_COLOR.b, alpha)
			)
