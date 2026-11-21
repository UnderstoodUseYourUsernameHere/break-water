class_name BankGunner
extends RiverEnemy

const PULSE_SCENE: PackedScene = preload("res://scenes/enemies/BankPulse.tscn")

@export var reach_px: float = 300.0
@export var warning_seconds: float = 1.15
@export var cooldown_seconds: float = 2.8

var _warning_left: float = 0.0
var _cooldown_left: float = 0.0
var _locked_direction := Vector2.RIGHT
var _locked_range: float = 0.0

@onready var _tell: Line2D = $Tell

func spawn_lane(roll: float) -> float:
	return 0.08 if roll < 0.5 else 0.92

func _can_ram() -> bool:
	return false

func _on_screen() -> bool:
	var screen_position := get_global_transform_with_canvas().origin
	return get_viewport_rect().grow(-12.0).has_point(screen_position)

func _physics_process(delta: float) -> void:
	if not can_act():
		_tell.hide()
		return
	
	if _warning_left > 0.0:
		_warning_left = maxf(0.0, _warning_left - delta)
		if _warning_left == 0.0:
			_tell.hide()
			if _on_screen():
				_release_pulse()
			_cooldown_left = cooldown_seconds
		return
	
	_cooldown_left = maxf(0.0, _cooldown_left - delta)
	if _cooldown_left > 0.0:
		return
	
	_cooldown_left = 0.15
	_try_begin_warning()

func _try_begin_warning() -> void:
	if not _on_screen():
		return
	
	if river.to_local(global_position).y > river.to_local(target.global_position).y:
		return
	
	var offset := target.global_position - global_position
	var distance := offset.length()
	if distance < 1.0 or distance > reach_px:
		return
	
	var direction := offset / distance
	var end := global_position + direction * reach_px
	
	var query := PhysicsRayQueryParameters2D.create(global_position, end, 1)
	query.hit_from_inside = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	
	var clear_range := reach_px
	if not hit.is_empty():
		var hit_position: Vector2 = hit["position"]
		clear_range = global_position.distance_to(hit_position)
	
	if clear_range < distance:
		return
	
	_locked_direction = direction
	_locked_range = clear_range	
	global_rotation = direction.angle()
	_tell.points = PackedVector2Array([Vector2.ZERO, Vector2.RIGHT * clear_range])
	_tell.show()
	_warning_left = warning_seconds

func _release_pulse() -> void:
	var host := get_parent() as Node2D
	var pulse := PULSE_SCENE.instantiate() as BankPulse
	
	pulse.target = target
	pulse.direction = _locked_direction
	pulse.remaining_px = _locked_range
	pulse.position = host.to_local(global_position)
	host.add_child(pulse)
