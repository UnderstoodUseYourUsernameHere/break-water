class_name Drifter
extends RiverEnemy

@export var chase_speed: float = 140.0
@export var current_influence: float = 0.35
@export var turn_rate: float = 3.5

var _heading := Vector2.DOWN

func _physics_process(delta: float) -> void:
	if not can_act():
		return
	
	var to_target := target.global_position - global_position
	if not to_target.is_zero_approx():
		_heading = _heading.slerp(
			to_target.normalized(),
			clampf(turn_rate * delta, 0.0, 1.0)
		)
	
	var motion := _heading * chase_speed
	if river != null:
		motion += river.get_current(global_position) * current_influence
	
	global_position += motion * delta
	global_rotation = _heading.angle() + PI / 2.0
	
	if river != null:
		global_position = river.clamp_to_water(global_position, water_margin)
