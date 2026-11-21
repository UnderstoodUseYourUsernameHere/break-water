class_name DockSpawner
extends Node2D

const PIXELS_PER_METER := 10.0

@export var river: HeadWatersRiver
@export var boat: Boat
@export var run_state: RunState
@export var dock_scene: PackedScene

@export var first_dock_m: float = 200.0
@export var dock_spacing_m: float = 200.0
@export var reveal_ahead_m: float = 140.0
@export var despawn_behind_m: float = 260.0

var _next_dock_index: int = 1
var _spawned: Dictionary = {}

func _ready() -> void:
	assert(river != null, "DockSpawner: assign River1!")
	assert(boat != null, "DockSpawner: assign Boat!")
	assert(run_state != null, "DockSpawner: assign RunState!")
	assert(dock_scene != null, "DockSpawner: Assing dock scene!")

func _physics_process(delta: float) -> void:
	if boat.is_sunk:
		return
	
	while _next_dock_m() <= run_state.peak_m + reveal_ahead_m:
		_spawn_dock(_next_dock_index, _next_dock_m())
		_next_dock_index += 1
	_despawn_far()

func _next_dock_m() -> float:
	return first_dock_m + float(_next_dock_index - 1) * dock_spacing_m

func _spawn_dock(index: int, dock_m: float) -> void:
	if _spawned.has(index):
		return
	
	var dock := dock_scene.instantiate() as RiverDock
	dock.dock_id = index
	dock.run_state = run_state
	
	var local_y := -dock_m * PIXELS_PER_METER
	var lane := 0.07 if index % 2 == 1 else 0.93
	
	add_child(dock)
	dock.global_position = river.water_point(local_y, lane)
	_spawned[index] = dock

func _despawn_far() -> void:
	var boat_y := river.to_local(boat.global_position).y
	var behind_px := despawn_behind_m * PIXELS_PER_METER
	
	for key in _spawned.keys():
		var dock := _spawned[key] as RiverDock
		if dock == null or not is_instance_valid(dock):
			_spawned.erase(key)
			continue
		
		var dock_y := river.to_local(dock.global_position).y
		if dock_y > boat_y + behind_px:
			_spawned.erase(key)
			dock.queue_free()
