class_name Drifter
extends RiverEnemy

@export var seek_speed: float = 40.0

func _physics_process(delta: float) -> void:
	if not can_act():
		return
	
	var motion := Vector2.ZERO
	if river != null:
		motion += river.get_current(global_position)
	
	if is_instance_valid(target):
		var dx := target.global_position.x - global_position.x
		motion.x += clampf(dx / 60.0, -1.0, 1.0) * seek_speed
	
	global_position += motion * delta
	if river != null:
		global_position = river.clamp_to_water(global_position, water_margin)
