class_name Boat
extends CharacterBody2D

const AIM_TINT := Color("#a7e3df")
const COOLDOWN_EPSILON := 0.00001
const HIT_TINT := Color("#e3572b")
const SUNK_TINT := Color(0.35, 0.35, 0.38, 0.8)

signal damaged(hull_points: int)
signal sunk

@export var stroke_impulse: float = 130.0
@export var stroke_interval: float = 0.40
@export var water_drag: float = 1.8
@export var max_row_speed: float = 280.0
@export var rudder_turn_rate: float = 2.2
@export_range(1.0, 500.0, 1.0) var full_rudder_speed: float = 140.0
@export var lateral_drag: float = 4.0
@export var river: HeadWatersRiver
@export var max_hull_points: int = 5
@export var damage_grace: float = 0.6

var is_aiming: bool = false
var hull_points: int = 0
var is_sunk: bool = false
var _grace_left: float = 0.0

var _stroke_cooldown: float = 0.0
var _row_velocity := Vector2.ZERO

@onready var _hull: Node2D = $Hull
@onready var weapon: BoatWeapon = $Weapon

func _ready() -> void:
	assert(
		river != null,
		"Boat: assign the levels River node to the River field in Main!"
	)
	hull_points = max_hull_points

func _physics_process(delta: float) -> void:
	_grace_left = maxf(0.0, _grace_left - delta)
	is_aiming = not is_sunk and Input.is_action_pressed(&"aim")
	_update_hull_tint()
	if OS.is_debug_build() and Input.is_action_just_pressed(&"debug_damage"):
		take_damage(1)
	weapon.aiming = is_aiming
	if is_aiming and Input.is_action_just_pressed(&"fire"):
		weapon.try_fire(get_global_mouse_position())
	
	_stroke_cooldown = maxf(0.0, _stroke_cooldown - delta)
	var wants_row := not is_sunk and not is_aiming and Input.is_action_pressed(&"row")
	_apply_rudder(delta, wants_row)
	
	if wants_row and _stroke_cooldown <= COOLDOWN_EPSILON:
		_row_velocity += Vector2.UP.rotated(global_rotation) * stroke_impulse
		_row_velocity = _row_velocity.limit_length(max_row_speed)
		_stroke_cooldown = stroke_interval
	
	_apply_water_drag(delta)
	var current: Vector2 = river.get_current(global_position)
	velocity = _row_velocity + current
	move_and_slide()
	_discard_blocked_row_velocity()
	

func _apply_rudder(delta: float, wants_row: bool) -> void:
	if is_sunk:
		return
		
	var steering := Input.get_axis(&"steer_left", &"steer_right")
	if is_zero_approx(steering):
		return
	
	var authority := clampf(
		_row_velocity.length() / full_rudder_speed,
		0.0,
		1.0
	)
	
	if wants_row:
		authority = maxf(authority, 0.35)
	
	global_rotation += steering * rudder_turn_rate * authority * delta

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
