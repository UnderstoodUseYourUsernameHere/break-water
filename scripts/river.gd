extends Node2D

const HALF_WIDTH := 240.0
const HALF_LENGTH := 6144
const MARK_SPACING := 96

const LAND_COLOR := Color("#1a1a1c")
const WATER_COLOR := Color("#0f2a33")
const EDGE_COLOR := Color("#46646a")
const MARK_COLOR := Color("#3b616a")
const START_COLOR := Color("#72918e")

func _draw() -> void:
	draw_rect(
		Rect2(-2048, -HALF_LENGTH, 4096, HALF_LENGTH * 2),
		LAND_COLOR
	)
	draw_rect(
		Rect2(
			-HALF_WIDTH,
			-HALF_LENGTH,
			HALF_WIDTH * 2.0,
			HALF_LENGTH * 2.0
		),
		WATER_COLOR
	)
	
	for side in [-1.0, 1.0]:
		var x: float = side * HALF_WIDTH
		draw_line(
			Vector2(x, -HALF_LENGTH),
			Vector2(x, HALF_LENGTH),
			EDGE_COLOR,
			2.0
		)
	
	for y in range(-HALF_LENGTH, HALF_LENGTH + 1, MARK_SPACING):
		if y == 0:
			continue
		
		draw_line(
			Vector2(-HALF_WIDTH, y),
			Vector2(-HALF_WIDTH + 16, y),
			MARK_COLOR,
			2.0
		)
		draw_line(
			Vector2(-6, y),
			Vector2(6, y),
			MARK_COLOR,
			1.0
		)
	
	draw_line(
		Vector2(-HALF_WIDTH, 0),
		Vector2(HALF_WIDTH, 0),
		START_COLOR,
		2.0
	)
	
