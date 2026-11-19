extends Node2D

const HULL_COLOR := Color("#e8e2d0")
const SEAT_COLOR := Color("#334b50")

func _draw() -> void:
	var outline := PackedVector2Array([
		Vector2(0, -23),
		Vector2(10, -10),
		Vector2(10, 12),
		Vector2(6, 20),
		Vector2(-6, 20),
		Vector2(-10, 12),
		Vector2(-10, -10)
	])
	draw_colored_polygon(outline, HULL_COLOR)
	draw_line(Vector2(-6, -1), Vector2(6, -1), SEAT_COLOR, 2.5, true)
	draw_line(Vector2(-6, 8), Vector2(6, 8), SEAT_COLOR, 2.5, true)
