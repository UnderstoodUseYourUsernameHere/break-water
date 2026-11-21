extends Node2D
@export_enum("Swimmer", "Gunner", "Pulse") var style: int = 0

func _draw() -> void:
	match style: 
		0:
			draw_colored_polygon(PackedVector2Array([
				Vector2(19, 0), Vector2(-12, 10),
				Vector2(-6, 0), Vector2(-12, -10)
			]), Color("ff9364"))
		1:
			draw_rect(Rect2(-12, -12, 24, 24), Color("df7956"))
			draw_line(Vector2.ZERO, Vector2(18, 0), Color("fff0ac"), 4.0)
		2:
			draw_circle(Vector2.ZERO, 5.0, Color("#fff0ac"))
