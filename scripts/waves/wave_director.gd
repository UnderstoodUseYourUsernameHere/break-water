class_name WaveDirector
extends Node2D

signal wave_started(index: int, size: int)

const PIXELS_PER_METER := 10.0

@export var river: HeadWatersRiver
@export var boat: Boat
@export var drifter_scene: PackedScene

@export var first_wave_at_m: float = 30.0
@export var wave_spacing_m: float = 150.0
@export var base_wave_size: int = 3
@export var wave_growth: float = 1.0
@export var max_wave_size: int = 10
@export var max_alive: int = 10
@export var spawn_interval: float = 0.7
@export var spawn_ahead_px: float = 650.0
@export var despawn_behind_px: float = 900.0

var wave_index: int = 0
var current_m: float = 0.0
var peak_m: float = 0.0
var kills: int = 0

var _next_wave_m: float = 0.0
var _queued: int = 0
var _spawn_timer: float = 0.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	assert(river != null, "WaveDirector: assign River!")
	assert(boat != null, "WaveDirector: assign Boat!")
	assert(drifter_scene != null, "WaveDirector: assign DrifterScene!")
	_rng.seed = ("%d:waves" % river.run_seed).hash()
	_next_wave_m = first_wave_at_m

func _physics_process(delta: float) -> void:
	var boat_y := river.to_local(boat.global_position).y
	current_m = -boat_y / PIXELS_PER_METER
	peak_m = maxf(peak_m, current_m)
	if not boat.is_sunk:
		while peak_m >= _next_wave_m:
			_start_wave()
	
	_spawn_timer = maxf(0.0, _spawn_timer - delta)
	
	if (
		not boat.is_sunk
		and _queued > 0
		and _spawn_timer == 0.0
		and _alive_count() < max_alive 
		):
			_spawn_drifter(boat_y)
			_queued -= 1
			_spawn_timer = spawn_interval
	_despawn_far(boat_y)

func _start_wave() -> void:
	wave_index += 1
	_next_wave_m += wave_spacing_m
	var size := mini(
		base_wave_size + int((wave_index - 1) * wave_growth),
		max_wave_size
	)
	_queued += size
	wave_started.emit(wave_index, size)

func _spawn_drifter(boat_y: float) -> void:
	var spawn_y := boat_y - spawn_ahead_px - _rng.randf_range(0.0, 120.0)
	var lane := _rng.randf_range(0.15, 0.85)
	
	var drifter := drifter_scene.instantiate() as Drifter
	drifter.river = river
	drifter.target = boat
	drifter.died.connect(_on_enemy_died)
	add_child(drifter)
	drifter.global_position = river.water_point(spawn_y, lane)

func _alive_count() -> int:
	var count := 0
	for child in get_children():
		if not child.is_queued_for_deletion():
			count += 1
	return count

func _despawn_far(boat_y: float) -> void:
	for child in get_children():
		var enemy := child as Node2D
		if enemy == null or enemy.is_queued_for_deletion():
			continue
		if river.to_local(enemy.global_position).y > boat_y + despawn_behind_px:
			enemy.queue_free()

func _on_enemy_died(killed_by_player: bool) -> void:
	if killed_by_player:
		kills += 1
