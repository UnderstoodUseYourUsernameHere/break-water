class_name Drifter
extends Area2D

signal died(killed_by_player: bool)

@export var max_health: int = 1
@export var seek_speed: float = 40.0
@export var ram_damage: int = 1
@export var water_margin: float = 16.0
@export var river: HeadWatersRiver
@export var target: Node2D

var _health: int = 0
var _dead: bool = false

func _ready() -> void:
	_health = max_health
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var motion := Vector2.ZERO
	if river != null:
		motion += river.get_current(global_position)
	
	if is_instance_valid(target):
		var dx := target.global_position.x - global_position.x
		motion.x += clampf(dx / 60.0, -1.0, 1.0) * seek_speed
	
	global_position += motion * delta
	if river != null:
		global_position = river.clamp_to_water(global_position, water_margin)

func take_hit(amount: int) -> void:
	if _dead:
		return
	_health -= amount
	if _health <= 0:
		_die(true)

func _on_body_entered(body: Node2D) -> void:
	if _dead: 
		return
	if body.has_method("take_damage"):
		body.take_damage(ram_damage)
		_die(false)

func _die(killed_by_player: bool) -> void:
	_dead = true
	died.emit(killed_by_player)
	queue_free()
