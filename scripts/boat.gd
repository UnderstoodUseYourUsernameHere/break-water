class_name Boat
extends CharacterBody2D

const AIM_TINT := Color("#a7e3df")
const HIT_TINT := Color("#e3572b")
const SUNK_TINT := Color(0.35, 0.35, 0.38, 0.8)

signal damaged(hull_points: int)
signal sunk
signal stroked(perfect: bool)

@export var stroke_force: float = 900.0
@export var drive_time: float = 0.18
@export var recovery_time: float = 0.26
@export var launch_bonus: float = 0.4
@export var water_drag: float = 1.8
@export var max_row_speed: float = 280.0
@export var turn_rate: float = 2.8
@export var turn_accel: float = 14.0
@export var pivot_authority: float = 0.45
@export var aim_turn_scale: float = 0.35
@export_range(1.0, 500.0, 1.0) var full_rudder_speed: float = 140.0
@export var lateral_drag: float = 4.0
@export var river: HeadWatersRiver
@export var max_hull_points: int = 5
@export var damage_grace: float = 0.6

var is_aiming: bool = false
var hull_points: int = 0
var is_sunk: bool = false
var _grace_left: float = 0.0

enum Stroke { READY, DRIVE, RECOVER }
var _stroke := Stroke.READY
var _stroke_left: float = 0.0
var _stroke_power: float = 1.0
var _base_stroke_force: float = 0.0

var _row_velocity := Vector2.ZERO
var _turn_speed: float = 0.0

@onready var _hull: Node2D = $Hull
@onready var weapon: BoatWeapon = $Weapon

func _ready() -> void:
	assert(
		river != null,
		"Boat: assign the levels River node to the River field in Main!"
	)
	hull_points = max_hull_points
	_base_stroke_force = stroke_force

func _physics_process(delta: float) -> void:
	_grace_left = maxf(0.0, _grace_left - delta)
	is_aiming = not is_sunk and Input.is_action_pressed(&"aim")
	_update_hull_tint()
	if OS.is_debug_build() and Input.is_action_just_pressed(&"debug_damage"):
		take_damage(1)
	weapon.aiming = is_aiming
	if is_aiming and Input.is_action_just_pressed(&"fire"):
		weapon.try_fire(get_global_mouse_position())
	
	var wants_row := not is_sunk and not is_aiming and Input.is_action_pressed(&"row")
	_apply_rudder(delta)
	_update_stroke(delta, wants_row)
	
	_apply_water_drag(delta)
	var current: Vector2 = river.get_current(global_position)
	velocity = _row_velocity + current
	move_and_slide()
	_discard_blocked_row_velocity()
	

func _apply_rudder(delta: float) -> void:
	if is_sunk:
		return
		
	var steering := Input.get_axis(&"steer_left", &"steer_right")
	var speed_authority := clampf(_row_velocity.length() / full_rudder_speed, 0.0, 1.0)
	var authority := maxf(speed_authority, pivot_authority)
	if is_aiming:
		authority *= aim_turn_scale
	
	var target_turn := steering * turn_rate * authority
	_turn_speed = move_toward(_turn_speed, target_turn, turn_accel * delta)
	global_rotation += _turn_speed * delta
 
func _apply_water_drag(delta: float) -> void:
	var right := Vector2.RIGHT.rotated(global_rotation)
	var sideways_velocity := right * _row_velocity.dot(right)
	
	_row_velocity -= sideways_velocity * (1.0 - exp(-lateral_drag * delta))
	_row_velocity *= exp(-water_drag * delta)

func _discard_blocked_row_velocity() -> void:
	for i in range(get_slide_collision_count()):
		var normal := get_slide_collision(i).get_normal()
		
		if _row_velocity.dot(normal) < 0.0:
			_row_velocity = _row_velocity.slide(normal)

func take_damage(amount: int = 1) -> void:
	if is_sunk or _grace_left > 0.0:
		return
	
	hull_points = maxi(0, hull_points - amount)
	_grace_left = damage_grace
	damaged.emit(hull_points)
	if hull_points == 0:
		is_sunk = true
		sunk.emit()

func _update_hull_tint() -> void:
	if is_sunk:
		_hull.modulate = SUNK_TINT
	elif _grace_left > 0.0 and fmod(_grace_left, 0.12) > 0.06:
		_hull.modulate = HIT_TINT
	elif is_aiming:
		_hull.modulate = AIM_TINT
	else:
		_hull.modulate = Color.WHITE

func _update_stroke(delta: float, wants_row: bool) -> void:
	if _stroke == Stroke.READY and wants_row:
		_begin_stroke(false)
	
	if _stroke == Stroke.DRIVE:
		if is_aiming or is_sunk:
			_enter_recovery()
			return
		
		var push_time := minf(delta, _stroke_left)
		var forward := Vector2.UP.rotated(global_rotation)
		_row_velocity += forward * stroke_force * _stroke_power * push_time
		_row_velocity = _row_velocity.limit_length(max_row_speed)
		
		_stroke_left -= delta
		if _stroke_left <= 0.0:
			_enter_recovery()
	elif _stroke == Stroke.RECOVER:
		_stroke_left -= delta
		if _stroke_left <= 0.0:
			_stroke = Stroke.READY
			_stroke_left = 0.0

func _begin_stroke(perfect: bool) -> void:
	var speed_ratio := clampf(_row_velocity.length() / max_row_speed, 0.0, 1.0)
	_stroke_power = 1.0 + launch_bonus * (1.0 - speed_ratio)
	_stroke = Stroke.DRIVE
	_stroke_left = drive_time
	stroked.emit(perfect)

func _enter_recovery() -> void:
	_stroke = Stroke.RECOVER
	_stroke_left = recovery_time

func get_water_speed() -> float:
	return _row_velocity.length()
	

func repair_hull(amount: int) -> bool:
	if amount <= 0 or is_sunk or hull_points >= max_hull_points:
		return false
	
	hull_points = mini(max_hull_points, hull_points + amount)
	damaged.emit(hull_points)
	return true

func _apply_stroke_multiplier(multiplier: float) -> void:
	stroke_force = _base_stroke_force * multiplier
