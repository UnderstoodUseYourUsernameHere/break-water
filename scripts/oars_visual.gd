extends Node2D

const OAR_COLOR := Color("c9b98f")

@export var oar_length: float = 26.0
@export var sweep_angle: float = 1.0
@export var sweep_time: float = 0.3

var _boat: Boat
var _phase: float = 1.0
var _shipped: float = 0.0

func _ready() -> void:
	_boat = get_parent() as Boat
	assert(_boat != null, "Oars must be a direct child of Boat.")
	_boat.stroked.connect(_on_stroked)

func _process(delta: float) -> void:
	_phase = minf(1.0, _phase + delta / sweep_time)
	var ship_goal := 1.0 if (_boat.is_aiming or _boat.is_sunk) else 0.0
	_shipped = move_toward(_shipped, ship_goal, delta * 6.0)
	queue_redraw()

func _on_stroked(_perfect: bool) -> void:
	_phase = 0.0

func _draw() -> void:
	var sweep := lerpf(-sweep_angle * 0.5, sweep_angle * 0.5, ease(_phase, 0.6))
	
	for side in [-1.0, 1.0]:
		var pivot := Vector2(9.0 * side, 2.0)
		var out_dir := Vector2(side, 0.0).rotated(sweep * side)
		var shipped_dir := Vector2(0.25 * side, 1.0).normalized()
		var dir := out_dir.lerp(shipped_dir, _shipped).normalized()
		
		var tip := pivot + dir * oar_length
		draw_line(pivot, tip, OAR_COLOR, 2.0, true)
		draw_line(tip - dir * 7.0, tip, OAR_COLOR, 5.0, true)
