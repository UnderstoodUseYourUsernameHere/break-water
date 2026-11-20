class_name HeadWatersRiver
extends Node2D

const CHUNK_SCENE: PackedScene = preload("res://scenes/river_chunk.tscn")
const LIVE_RADIUS := 2

@export var run_seed: int = 2250
@export var current_speed: float = 90.0
@export var follow_target: Node2D
var _profile: RiverProfile
var _chunks: Dictionary = {}
var _center_id: int = 0

func get_current(_world_position: Vector2) -> Vector2:
	return Vector2.DOWN * current_speed

func _ready() -> void:
	_profile = RiverProfile.new(run_seed)
	if follow_target == null:
		push_error("River: assign the levels Boat node to Follow Target")
		set_physics_process(false)
		return
	
	_sync_chunks(_target_chunk())

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(follow_target):
		return
	
	var target_id: int = _target_chunk()
	if target_id != _center_id:
		_sync_chunks(target_id)

func _target_chunk() -> int:
	var local_y: float = to_local(follow_target.global_position).y
	return RiverProfile.chunk_id_at(local_y)

func _sync_chunks(center_id: int) -> void:
	_center_id = center_id
	
	for id in range(center_id - LIVE_RADIUS, center_id + LIVE_RADIUS + 1):
		if not _chunks.has(id):
			_chunks[id] = _spawn_chunk(id)
	
	for key in _chunks.keys():
		var id: int = int(key)
		if absi(id - center_id) > LIVE_RADIUS:
			var old_chunk: RiverChunk = _chunks[key] as RiverChunk
			_chunks.erase(key)
			old_chunk.queue_free()

func _spawn_chunk(id: int) -> RiverChunk:
	var chunk := CHUNK_SCENE.instantiate() as RiverChunk
	chunk.name = "Chunk_%d" % id
	chunk.position = Vector2(0.0, float(id * RiverProfile.HEIGHT))
	add_child(chunk)
	chunk.build(_profile, id)
	return chunk

func water_point(local_y: float, lane: float) -> Vector2:
	var banks := _profile.banks_at(local_y)
	return to_global(Vector2(lerpf(banks.x, banks.y, lane), local_y))

func clamp_to_water(world_position: Vector2, margin: float) -> Vector2:
	var local := to_local(world_position)
	var banks := _profile.banks_at(local.y)
	local.x = clampf(local.x, banks.x + margin, banks.y - margin)
	return to_global(local)
