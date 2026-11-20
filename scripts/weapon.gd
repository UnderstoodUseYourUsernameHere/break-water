class_name BoatWeapon
extends Node2D

signal fired(from: Vector2, to: Vector2, hit_target: bool)
signal reloaded

const AIM_READY_COLOR := Color(1.0, 0.95, 0.84, 0.55)
const AIM_EMPTY_COLOR := Color(1.0, 0.45, 0.3, 0.35)

@onready var _muzzle: Marker2D = $Muzzle

@export var reload_time: float = 2.0
@export var shot_range: float = 900.0
@export_flags_2d_physics var hit_mask: int = 5

var aiming: bool = false:
	set(value):
		if aiming != value:
			aiming = value
			queue_redraw()

var shots_fired: int = 0
var hits: int = 0
var _reload_left: float = 0.0

func is_loaded() -> bool:
	return _reload_left <= 0.0

func reload_ratio() -> float:
	return 1.0 - _reload_left / reload_time

func try_fire(target: Vector2) -> bool:
	if not is_loaded():
		return false
	
	var from := _muzzle.global_position
	var direction := from.direction_to(target)
	if direction.is_zero_approx():
		direction = Vector2.UP.rotated(global_rotation)
	var to := from + direction * shot_range
	
	var query := PhysicsRayQueryParameters2D.create(from, to, hit_mask)
	query.collide_with_areas = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	
	var hit_target := false
	if not hit.is_empty():
		to = hit["position"]
		var collider: Object = hit["collider"]
		if collider != null and collider.has_method("take_hit"):
			collider.take_hit(1)
			hit_target = true
	
	shots_fired += 1
	if hit_target:
		hits += 1
	
	_reload_left = reload_time
	fired.emit(from, to, hit_target)
	queue_redraw()
	return true

func _physics_process(delta: float) -> void:
	if _reload_left > 0.0:
		_reload_left = maxf(0.0, _reload_left - delta)
		if _reload_left == 0.0:
			reloaded.emit()
			queue_redraw()

func _process(delta: float) -> void:
	if aiming:
		queue_redraw()

func _draw() -> void:
	if not aiming:
		return
	
	var from := _muzzle.position
	var to := to_local(get_global_mouse_position())
	var color := AIM_READY_COLOR if is_loaded() else AIM_EMPTY_COLOR
	draw_dashed_line(from, to, color, 1.5, 8.0)
	draw_circle(to, 4.0, color)
