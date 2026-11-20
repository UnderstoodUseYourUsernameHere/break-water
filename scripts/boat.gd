extends CharacterBody2D

const AIM_TINT := Color("#a7e3df")
const COOLDOWN_EPSILON := 0.00001

@export var stroke_impulse: float = 130.0
@export var stroke_interval: float = 0.40
@export var water_drag: float = 1.8
@export var max_row_speed: float = 280.0
@export var rudder_turn_rate: float = 2.2
@export_range(1.0, 500.0, 1.0) var full_rudder_speed: float = 140.0
@export var lateral_drag: float = 4.0
@export var river: HeadWatersRiver

var is_aiming: bool = false

var _stroke_cooldown: float = 0.0
var _row_velocity := Vector2.ZERO

@onready var _hull: Node2D = $Hull
@onready var weapon: BoatWeapon = $Weapon

func _ready() -> void:
	assert(
		river != null,
		"Boat: assign the levels River node to the River field in Main!"
	)

func _physics_process(delta: float) -> void:
	is_aiming = Input.is_action_pressed(&"aim")
	_hull.modulate = AIM_TINT if is_aiming else Color.WHITE
	weapon.aiming = is_aiming
	if is_aiming and Input.is_action_pressed(&"fire"):
		weapon.try_fire(get_global_mouse_position())
	
	_stroke_cooldown = maxf(0.0, _stroke_cooldown - delta)
	var wants_row := not is_aiming and Input.is_action_pressed(&"row")
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
