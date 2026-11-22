extends Node2D

@export var show_survey_marks := true
@export var shrub_chance: float = 0.6
@export var snow_line_px: float = 26000.0

const LAND_LOW := Color("#23401f")
const LAND_HIGH := Color("#6a6f72")
const SHADOW_COLOR := Color(0.03, 0.09, 0.12, 0.45)

var _marks := PackedVector2Array()
var _shadow_left := PackedVector2Array()
var _shadow_right := PackedVector2Array()
var _shrub_pos := PackedVector2Array()
var _shrub_size := PackedFloat32Array()
var _shrub_color := PackedColorArray()


func paint(
	left: PackedVector2Array,
	right: PackedVector2Array,
	left_land: PackedVector2Array,
	right_land: PackedVector2Array,
	start_y: float
) -> void:
	var water := left.duplicate()
	for i in range(right.size() - 1, -1, -1):
		water.append(right[i])
	
	var altitude := clampf(-start_y / snow_line_px, 0.0, 1.0)
	var land_color := LAND_LOW.lerp(LAND_HIGH, altitude)
	
	_set_surface($Water as Polygon2D, water, start_y)
	_set_surface($LeftLand as Polygon2D, left_land, start_y)
	_set_surface($RightLand as Polygon2D, right_land, start_y)
	
	($LeftLand as Polygon2D).color = land_color
	($RightLand as Polygon2D).color = land_color
	
	_shadow_left = left
	_shadow_right = right
	
	_marks.clear()
	
	for i in range(0, left.size() - 1, 2):
		_marks.append(left[i])
		_marks.append(left[i] + Vector2(14.0, 0.0))
		_marks.append(right[i] - Vector2(14.0, 0.0))
		_marks.append(right[i])
	
	_build_shrubs(left, right, start_y, altitude)
	queue_redraw()

func _build_shrubs(
	left: PackedVector2Array,
	right: PackedVector2Array,
	start_y: float,
	altitude: float
) -> void:
	_shrub_pos.clear()
	_shrub_size.clear()
	_shrub_color.clear()
	
	var rng := RandomNumberGenerator.new()
	rng.seed = ("shrubs:%d" % int(start_y)).hash()
	
	var base := Color("#2f5a2a").lerp(Color("#59605c"), altitude)
	
	for i in range(left.size()):
		if rng.randf() < shrub_chance:
			_add_shrub(left[i] + Vector2(-rng.randf_range(16.0, 150.0), rng.randf_range(-24.0, 24.0)), rng, base)
		if rng.randf() < shrub_chance:
			_add_shrub(right[i] + Vector2(rng.randf_range(16.0, 150.0), rng.randf_range(-24.0, 24.0)), rng, base)

func _add_shrub(at: Vector2, rng: RandomNumberGenerator, base: Color) -> void:
	_shrub_pos.append(at)
	_shrub_size.append(rng.randf_range(5.0, 12.0))
	_shrub_color.append(base.lerp(Color.BLACK, rng.randf_range(0.0, 0.3)))

func _set_surface(surface: Polygon2D, points: PackedVector2Array, start_y: float) -> void:
	surface.polygon = points
	var uv := points.duplicate()
	for i in range(uv.size()):
		uv[i] = points[i] + Vector2(0.0, start_y)
	surface.uv = uv

func _draw() -> void:
	for i in range(_shrub_pos.size()):
		var at := _shrub_pos[i]
		var r := _shrub_size[i]
		var c := _shrub_color[i]
		draw_circle(at, r, c)
		draw_circle(at + Vector2(-r * 0.6, r * 0.2), r * 0.7, c)
		draw_circle(at + Vector2(r * 0.6, r * 0.25), r * 0.65, c)
	
	if _shadow_left.size() > 1:
		draw_polyline(_shadow_left, SHADOW_COLOR, 11.0)
		draw_polyline(_shadow_right, SHADOW_COLOR, 11.0)
	
	if show_survey_marks and not _marks.is_empty():
		draw_multiline(_marks, Color("#46646a"), 2.0)
