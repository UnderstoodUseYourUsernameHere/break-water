extends CharacterBody2D

const AIM_TINT := Color("#a7e3df")
const COOLDOWN_EPSILON := 0.00001

@export var stroke_impulse: float = 130.0
@export var stroke_interval: float = 0.40
@export var water_drag: float = 1.8
@export var max_row_speed: float = 280.0

var is_aiming: bool = false

var _stroke_cooldown: float = 0.0
var _row_velocity := Vector2.ZERO

@onready var _hull: Node2D = $Hull

func _physics_process(delta: float) -> void:
	is_aiming = Input.is_action_pressed(&"aim")
	_hull.modulate = AIM_TINT if is_aiming else Color.WHITE
	
	_stroke_cooldown = maxf(0.0, _stroke_cooldown - delta)
	var wants_row := not is_aiming and Input.is_action_pressed(&"row")
	
	if wants_row and _stroke_cooldown <= COOLDOWN_EPSILON:
		_row_velocity += Vector2.UP.rotated(global_rotation) * stroke_impulse
		_row_velocity = _row_velocity.limit_length(max_row_speed)
		_stroke_cooldown = stroke_interval
	
	_row_velocity *= exp(-water_drag * delta)
	velocity = _row_velocity
	move_and_slide()
