extends Node2D

@export var show_survey_marks := true

var _marks := PackedVector2Array()

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
	
	_set_surface($Water as Polygon2D, water, start_y)
	_set_surface($LeftLand as Polygon2D, left_land, start_y)
	_set_surface($RightLand as Polygon2D, right_land, start_y)
	
	_marks.clear()
	
	for i in range(0, left.size() - 1, 2):
		_marks.append(left[i])
		_marks.append(left[i] + Vector2(14.0, 0.0))
		_marks.append(right[i] - Vector2(14.0, 0.0))
		_marks.append(right[i])
	queue_redraw()

func _set_surface(surface: Polygon2D, points: PackedVector2Array, start_y: float) -> void:
	surface.polygon = points
	var uv := points.duplicate()
	for i in range(uv.size()):
		uv[i] = points[i] + Vector2(0.0, start_y)
	surface.uv = uv

func _draw() -> void:
	if show_survey_marks and not _marks.is_empty():
		draw_multiline(_marks, Color("#46646a"), 2.0)
