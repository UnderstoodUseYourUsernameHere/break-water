class_name HeadWatersRiver
extends Node2D

const CHUNK_SCENE: PackedScene = preload("res://scenes/river_chunk.tscn")

@export var run_seed: int = 2250
@export var current_speed: float = 90.0
var _profile: RiverProfile

func get_current(_world_position: Vector2) -> Vector2:
	return Vector2.DOWN * current_speed

func _ready() -> void:
	_profile = RiverProfile.new(run_seed)
	for id in range(-1, 2):
		_spawn_chunk(id)

func _spawn_chunk(id: int) -> RiverChunk:
	var chunk := CHUNK_SCENE.instantiate() as RiverChunk
	chunk.name = "Chunk_%d" % id
	chunk.position = Vector2(0.0, float(id * RiverProfile.HEIGHT))
	add_child(chunk)
	chunk.build(_profile, id)
	return chunk
