class_name WaveDirector
extends Node2D

signal wave_started(index: int, size: int)

const PIXELS_PER_METER := 10.0

const COST_DRIFTER := 1
const COST_SWIMMER := 2
const COST_GUNNER := 3

@export var river: HeadWatersRiver
@export var boat: Boat
@export var drifter_scene: PackedScene
@export var swimmer_scene: PackedScene
@export var gunner_scene: PackedScene
@export var scrap_pickup_scene: PackedScene
@export var run_state: RunState

@export var max_gunners_per_wave: int = 2
@export var max_swimmers_per_wave: int = 3
@export var gunner_chance: float = 0.28
@export var swimmer_chance: float = 0.34

@export var first_wave_at_m: float = 30.0
@export var wave_spacing_m: float = 150.0
@export var base_wave_size: int = 3
@export var wave_growth: float = 1.0
@export var max_wave_size: int = 10
@export var max_alive: int = 10
@export var spawn_interval: float = 0.7
@export var spawn_ahead_px: float = 650.0
@export var despawn_behind_px: float = 900.0

@export var stretch_length_m: float = 200.0
@export var budget_per_stretch: int = 2
@export var budget_per_upgrade_level: float = 0.5

var wave_index: int = 0
var _next_wave_m: float = 0.0
var _pending: Array[PackedScene] = []
var _spawn_timer: float = 0.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	assert(river != null, "WaveDirector: assign River!")
	assert(boat != null, "WaveDirector: assign Boat!")
	assert(drifter_scene != null, "WaveDirector: assign DrifterScene!")
	assert(swimmer_scene != null, "WaveDirector: assign Swimmer Scene!")
	assert(gunner_scene != null, "WaveDirector: assign Gunner Scene!!!!")
	assert(run_state != null, "WaveDirector: assign RunState!")
	assert(scrap_pickup_scene != null, "WaveDirector: assign ScrapPickupScene!!")
	assert(wave_spacing_m > 0.0, "WaveDirector: Wave Spacign M must be positive!")
	_rng.seed = ("%d:waves" % river.run_seed).hash()
	_next_wave_m = first_wave_at_m

func _physics_process(delta: float) -> void:
	var boat_y := river.to_local(boat.global_position).y
	run_state.set_distance(-boat_y / PIXELS_PER_METER)
	if not boat.is_sunk:
		while run_state.peak_m >= _next_wave_m:
			_start_wave()
	
	_spawn_timer = maxf(0.0, _spawn_timer - delta)
	
	if (
		not boat.is_sunk
		and not _pending.is_empty()
		and _spawn_timer == 0.0
		and _alive_count() < max_alive 
		):
			var next_scene := _pending.pop_front() as PackedScene
			_spawn_enemy(next_scene, boat_y)
			_spawn_timer = spawn_interval
	_despawn_far(boat_y)

func _start_wave() -> void:
	wave_index += 1
	_next_wave_m += wave_spacing_m
	var size := _wave_budget()
	var plan := _wave_plan(wave_index, size)
	_pending.append_array(plan)
	wave_started.emit(wave_index, plan.size())

func _spawn_enemy(scene: PackedScene, boat_y: float) -> void:
	var instance := scene.instantiate()
	var enemy := instance as RiverEnemy
	
	if enemy == null:
		instance.free()
		push_error("WaveDirector: %s must have a RiverEnemy root." % scene.resource_path)
		return
	
	var spawn_y := boat_y - spawn_ahead_px - _rng.randf_range(0.0, 120.0)
	var lane := enemy.spawn_lane(_rng.randf())
	
	enemy.river = river
	enemy.target = boat
	enemy.died.connect(_on_enemy_died)
	enemy.position = to_local(river.water_point(spawn_y, lane))
	add_child(enemy, true)

func _alive_count() -> int:
	var count := 0
	for child in get_children():
		if child is RiverEnemy and not child.is_queued_for_deletion():
			count += 1
	return count

func _despawn_far(boat_y: float) -> void:
	for child in get_children():
		var enemy := child as RiverEnemy
		if enemy == null or enemy.is_queued_for_deletion():
			continue
		var gap := river.to_local(enemy.global_position).y - boat_y
		if gap > despawn_behind_px or gap < -(spawn_ahead_px + 510.0):
			enemy.queue_free()

func _on_enemy_died(killed_by_player: bool, bounty: int, world_position: Vector2) -> void:
	if not killed_by_player:
		return
	
	run_state.add_kill()
	
	var pickup := scrap_pickup_scene.instantiate() as ScrapPickup
	pickup.value = bounty
	pickup.target = boat
	pickup.run_state = run_state
	pickup.global_position = world_position
	
	get_parent().add_child(pickup)

func _wave_plan(index: int, points: int) -> Array[PackedScene]:
	var plan: Array[PackedScene] = []
	var left := maxi(1, points)
	
	var picks := RandomNumberGenerator.new()
	picks.seed = ("%d:wave-plan:%d" % [river.run_seed, index]).hash()
	
	var gunners := 0
	var swimmers := 0
	
	if index == 2 and left >= COST_SWIMMER:
		plan.append(swimmer_scene)
		left -= COST_SWIMMER
		swimmers += 1
	elif index == 3 and left >= COST_GUNNER:
		plan.append(gunner_scene)
		left -= COST_GUNNER
		gunners += 1
	
	while left >= COST_DRIFTER:
		var roll := picks.randf()
		
		if (
			index >= 3
			and roll < gunner_chance
			and left >= COST_GUNNER
			and gunners < max_gunners_per_wave
		):
			plan.append(gunner_scene)
			left -= COST_GUNNER
			gunners += 1
		elif (
			index >= 2
			and roll < gunner_chance + swimmer_chance
			and left >= COST_SWIMMER
			and swimmers < max_swimmers_per_wave
		):
			plan.append(swimmer_scene)
			left -= COST_SWIMMER
			swimmers += 1
		else:
			plan.append(drifter_scene)
			left -= COST_DRIFTER
	
	if index >= 4:
		for i in range(plan.size() - 1, 0, -1):
			var j := picks.randi_range(0, 1)
			var swapped := plan[i]
			plan[i] = plan[j]
			plan[j] = swapped
	
	return plan

func _wave_budget() -> int:
	var base := base_wave_size + int((wave_index - 1) * wave_growth)
	var stretch := floori(run_state.peak_m / stretch_length_m)
	var from_distance := stretch * budget_per_stretch
	var from_upgrades := floori(run_state.total_upgrade_levels() * budget_per_upgrade_level)
	return mini(base + from_distance + from_upgrades, max_wave_size)
