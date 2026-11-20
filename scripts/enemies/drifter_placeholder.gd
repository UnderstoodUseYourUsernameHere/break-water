extends Node2D

const BODY_COLOR := Color("e3572b")
const MARK_COLOR := Color("1a1a1c")

func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -15),
		Vector2(12, 0),
		Vector2(0, 15),
		Vector2(-12, 0)
	]), BODY_COLOR)
	draw_line(Vector2(-5.0, 0), Vector2(5, 0), MARK_COLOR, 2.0)
