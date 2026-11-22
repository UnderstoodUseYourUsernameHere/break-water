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
@export var max_rounds: int = 1
@export var damage: int = 1
@export var pierce: int = 0

var aiming: bool = false:
	set(value):
		if aiming != value:
			aiming = value
			queue_redraw()

var shots_fired: int = 0
var hits: int = 0
var rounds: int = 0
var _reload_left: float = 0.0
var _base_reload_time: float = 0.0

func _ready() -> void:
	_base_reload_time = reload_time
	rounds = max_rounds

func is_loaded() -> bool:
	return _reload_left <= 0.0

func reload_ratio() -> float:
	if rounds > 0 or reload_time <= 0.0:
		return 1.0
	return 1.0 - _reload_left / reload_time

func try_fire(target: Vector2) -> bool:
	if not is_loaded():
		return false
	
	var from := _muzzle.global_position
	var direction := from.direction_to(target)
	if direction.is_zero_approx():
		direction = Vector2.UP.rotated(global_rotation)
	
	var far := from + direction * shot_range
	var end := far
	var hit_any := false
	var exclude: Array[RID] = []
	var origin := from
	var targets_left := pierce + 1
	
	while targets_left > 0:
		var query := PhysicsRayQueryParameters2D.create(origin, far, hit_mask)
		query.collide_with_areas = true
		query.exclude = exclude
		var hit := get_world_2d().direct_space_state.intersect_ray(query)
		
		if hit.is_empty():
			end = far
			break
		
		var point: Vector2 = hit["position"]
		var collider: Object = hit["collider"]
		end = point
		
		if collider != null and collider.has_method("take_hit"):
			collider.take_hit(damage)
			hit_any = true
			targets_left -= 1
			if collider is CollisionObject2D:
				exclude.append((collider as CollisionObject2D).get_rid())
			origin = point + direction * 2.0
			continue
		break
	shots_fired += 1
	if hit_any:
		hits += 1
	
	rounds -= 1
	if rounds <= 0:
		_reload_left = reload_time
	
	fired.emit(from, end, hit_any)
	queue_redraw()
	return true

func _physics_process(delta: float) -> void:
	if rounds > 0:
		return
	
	if _reload_left > 0.0:
		_reload_left = maxf(0.0, _reload_left - delta)
		if _reload_left == 0.0:
			rounds = max_rounds
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
	
	for i in range(max_rounds):
		var pip := from + Vector2(-6.0 * float(max_rounds - 1) * 0.5 + 6.0 * float(i), -8.0)
		draw_circle(pip, 2.5, AIM_READY_COLOR if i < rounds else AIM_EMPTY_COLOR)

func apply_reload_multiplier(multiplier: float) -> void:
	reload_time = maxf(0.35, _base_reload_time * multiplier)

func add_round() -> void:
	max_rounds += 1
	rounds += 1

func add_damage(amount: int) -> void:
	damage += amount

func add_pierce(amount: int) -> void:
	pierce += amount
