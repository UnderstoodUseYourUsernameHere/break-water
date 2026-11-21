class_name Swimmer
extends RiverEnemy

enum Phase { SEEK, WARN, LUNGE, RECOVER }

@export var approach_speed: float = 110.0
@export var trigger_distance: float = 175.0
@export var warning_seconds: float = 0.85
@export var lunge_speed: float = 400.0
@export var lunge_seconds: float = 0.55
@export var recovery_seconds: float = 1.6

var _phase := Phase.SEEK
var _left: float = 0.0
var _locked_direction := Vector2.RIGHT

@onready var _tall: Line2D = $Tell
@onready var _visual: Node2D = $Visual

func _can_ram() -> bool:
	return _phase == Phase.LUNGE

func _physics_process(delta: float) -> void:
	if not can_act():
		_tall.hide()
		return
	
	match _phase:
		Phase.SEEK:
			var offset := target.global_position - global_position
			if offset.length_squared() <= trigger_distance * trigger_distance:
				_begin_warning(offset)
				return
			
			var direction := offset.normalized()
			global_rotation = direction.angle()
			var motion := river.get_current(global_position) + direction * approach_speed
			global_position = river.clamp_to_water(global_position + motion * delta, water_margin)
		
		Phase.WARN:
			_left -= delta
			if _left <= 0.0:
				_phase = Phase.LUNGE
				_left = lunge_seconds
				_tall.hide()
				
				if overlaps_body(target):
					_on_body_entered(target)
		
		Phase.LUNGE:
			if _left <= 0.0:
				_begin_recovery()
				return
			
			var step_time := minf(delta, _left)
			var proposed := global_position + _locked_direction * lunge_speed * step_time
			var inside := river.clamp_to_water(proposed, water_margin)
			global_position = inside
			_left -= step_time
			if inside.distance_squared_to(proposed) > 0.25:
				_left = 0.0
		
		Phase.RECOVER:
			var drift := river.get_current(global_position) * delta
			global_position = river.clamp_to_water(global_position + drift, water_margin)
			_left -= delta
			if _left <= 0.0:
				_die(false)

func _begin_warning(offset: Vector2) -> void:
	_phase = Phase.WARN
	_left = warning_seconds
	_locked_direction = offset.normalized()
	if _locked_direction.is_zero_approx():
		_locked_direction = Vector2.DOWN
	
	global_rotation = _locked_direction.angle()
	_tall.points = PackedVector2Array([
		Vector2.ZERO,
		Vector2.RIGHT * lunge_speed * lunge_seconds
	])
	_tall.show()

func _begin_recovery() -> void:
	_phase = Phase.RECOVER
	_left = recovery_seconds
	_visual.modulate = Color(0.55, 0.60, 0.65, 1.0)
