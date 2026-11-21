class_name RunState
extends Node

signal distance_changed(current_m: float, peak_m: float)
signal kills_changed(kills: int)
signal scrap_changed(scrap: int)

var current_m: float = 0.0
var peak_m: float = 0.0
var kills: int = 0
var scrap: int = 0

var used_docks: Dictionary = {}
var upgrade_levels: Dictionary = {}

func set_distance(value_m: float) -> void:
	var new_current := maxf(0.0, value_m)
	var new_peak := maxf(peak_m, new_current)
	
	if not is_equal_approx(new_current, current_m) or not is_equal_approx(new_peak, peak_m):
		current_m = new_current
		peak_m = new_peak
		distance_changed.emit(current_m, peak_m)
		

func add_kill() -> void:
	kills += 1
	kills_changed.emit(kills)

func add_scrap(amount: int) -> void:
	if amount <= 0:
		return
	
	scrap += amount
	scrap_changed.emit(scrap)

func can_spend(amount: int) -> bool:
	if amount <= 0:
		return true
	
	if scrap < amount:
		return false
	
	scrap -= amount
	scrap_changed.emit(scrap)
	return true

func is_dock_used(id: int) -> bool:
	return used_docks.has(id)

func mark_dock_used(id: int) -> void:
	used_docks[id] = true

func upgrade_level(id: StringName) -> int:
	return int(upgrade_levels.get(id, 0))

func add_upgrade_level(id: StringName) -> void:
	upgrade_levels[id] = upgrade_level(id) + 1
