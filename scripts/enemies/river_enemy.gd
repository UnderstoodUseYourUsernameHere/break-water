class_name RiverEnemy
extends Area2D

signal died(killed_by_player: bool, bounty: int, world_position: Vector2)
signal hit_taken(remaining: int, maximum: int)

@export var max_health: int = 1
@export var ram_damage: int = 1
@export var bounty: int = 1
@export var water_margin: float = 16.0
@export var river: HeadWatersRiver
@export var target: Boat
@export var shard_tint: Color = Color("#e3572b")

const SHARDS_SCENE: PackedScene = preload("res://scenes/enemies/EnemyShards.tscn")

var _health: int = 0
var _dead := false

func _ready() -> void:
	_health = maxi(1, max_health)
	body_entered.connect(_on_body_entered)

func can_act() -> bool:
	return (
		not _dead
		and not is_queued_for_deletion()
		and is_instance_valid(target)
		and not target.is_sunk
	)

func spawn_lane(roll: float) -> float:
	return lerpf(0.15, 0.85, roll)

func take_hit(amount: int) -> void:
	if not can_act() or amount <= 0:
		return
	_health -= amount
	if _health <= 0:
		_die(true)
		return
	hit_taken.emit(_health, max_health)

func _can_ram() -> bool:
	return true

func _on_body_entered(body: Node2D) -> void:
	if body != target or not can_act() or not _can_ram():
		return
	
	_die(false)
	target.take_damage(ram_damage)

func _die(killed_by_player: bool) -> void:
	if _dead:
		return
	
	_dead = true
	_spawn_shards()
	died.emit(killed_by_player, bounty, global_position)
	queue_free()

func _spawn_shards() -> void:
	var host := get_parent()
	if host == null or SHARDS_SCENE == null:
		return
	
	var shards := SHARDS_SCENE.instantiate() as EnemyShards
	shards.tint = shard_tint
	host.add_child(shards)
	shards.global_position = global_position
