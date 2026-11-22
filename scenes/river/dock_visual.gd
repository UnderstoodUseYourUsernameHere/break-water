extends Node2D

const WOOD_DARK := Color("#49372f")
const WOOD := Color("#8a6f5e")
const WOOD_LIGHT := Color("#ae9279")
const METAL := Color("#4b5a5d")
const LAMP := Color("#ffd166")
const SPENT := Color("#5a5551")

var _used: bool = false
var _ready_to_dock: bool = false
var _time: float = 0.0

func set_used(value: bool) -> void:
	if _used == value:
		return
	
	_used = value
	queue_redraw()

func set_ready_to_dock(value: bool) -> void:
	if _ready_to_dock == value:
		return
	
	_ready_to_dock = value
	queue_redraw()

func _process(delta: float) -> void:
	_time += delta
	
	if _ready_to_dock and not _used:
		queue_redraw()

func _draw() -> void:
	var deck := SPENT if _used else WOOD
	var trim := SPENT.lightened(0.12) if _used else WOOD_LIGHT
	
	draw_rect(
		Rect2(5, -10, 88, 32),
		Color(0.02, 0.06, 0.08, 0.55)
	)
	
	draw_rect(Rect2(-18, -42, 34, 84), WOOD_DARK)
	draw_rect(Rect2(0, -16, 88, 32), deck)
	
	draw_line(Vector2(0, -16), Vector2(88, -16), trim, 3.0)
	draw_line(Vector2(0, 16), Vector2(88, 16), trim, 3.0)
	
	for x in range(8, 88, 10):
		draw_line(
			Vector2(float(x), -14),
			Vector2(float(x), 14),
			WOOD_DARK,
			1.5
		)
	
	for x in [12.0, 78.0]:
		for y in [-21.0, 21.0]:
			var at := Vector2(x, y)
			draw_circle(at + Vector2(1, 2), 5.0, WOOD_DARK)
			draw_circle(at, 4.0, METAL)
	
	draw_rect(Rect2(20, -34, 21, 15), WOOD_DARK)
	draw_line(Vector2(22, -32), Vector2(39, -21), trim, 1.5)
	draw_line(Vector2(39, -32), Vector2(22, -21), trim, 1.5)
	
	var lantern_position := Vector2(70, -29)
	
	if _used:
		draw_circle(lantern_position, 5.0, SPENT)
		draw_line(
			lantern_position + Vector2(-5, -5),
			lantern_position + Vector2(5, 5),
			WOOD_DARK,
			2.5
		)
	else:
		var brightness := 0.75
		if _ready_to_dock:
			brightness = 0.75 + 0.25 * sin(_time * 8.0)
		
		draw_circle(
			lantern_position,
			11.0,
			Color(1.0, 0.72, 0.28, 0.15 * brightness)
			)
		draw_circle(
			lantern_position,
			11.0,
			Color(1.0, 0.72, 0.28, 0.15 * brightness)
			)
		draw_circle(lantern_position, 4.5, LAMP)
	
	if _ready_to_dock and not _used:
		for x in [96.0, 110.0, 124.0]:
			draw_polyline(
				PackedVector2Array([
					Vector2(x + 8.0, 30.0),
					Vector2(x + 38.0),
					Vector2(x + 6.0, 46.0)
				]),
				Color(1.0, 0.87, 0.52, 0.75),
				2.0,
				true
			)
	
