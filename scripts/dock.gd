class_name RiverDock
extends Area2D

@export var dock_id: int = 0
@export var run_state: RunState
@export var max_dock_speed: float = 80.0
@export var mooring_time: float = 0.35

@onready var _visual: CanvasItem = $Visual
@onready var _mooring_point: Marker2D = $MooringPoint

var _boat: Boat
var _docking: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_refresh_visual()

func _physics_process(_delta: float) -> void:
	_refresh_visual()
	if _docking:
		_set_prompt("")
		return
	
	if run_state == null or run_state.is_dock_used(dock_id):
		_set_prompt("")
		return
	
	if not is_instance_valid(_boat) or _boat.is_sunk:
		_set_prompt("")
		return
	
	if _boat.get_water_speed() > max_dock_speed:
		_set_prompt("RELEASE W TO SLOW DOWN AND MOOR!")
		return
	_set_prompt("[E] TO MOOR AT SUPPLY DOCK!")
		
		
	
	if Input.is_action_just_pressed(&"interact"):
		_begin_docking()

func _refresh_visual() -> void:
	var used := (
		run_state != null
		and run_state.is_dock_used(dock_id)
	)
	
	var ready_to_dock := (
		run_state != null
		and not used
		and not _docking
		and is_instance_valid(_boat)
		and not _boat.is_sunk
		and _boat.get_water_speed() <= max_dock_speed
	)
	
	if _visual.has_method("set_used"):
		_visual.call("set_used", used)
	
	if _visual.has_method("set_ready_to_dock"):
		_visual.call("set_ready_to_dock", ready_to_dock)

func _on_body_entered(body: Node2D) -> void:
	if body is Boat:
		_boat = body

func _on_body_exited(body: Node2D) -> void:
	if body == _boat and not _docking:
		_boat = null
		_set_prompt("")
		_refresh_visual()

func _begin_docking() -> void:
	if not is_instance_valid(_boat) or _boat.is_sunk:
		return
	
	_docking = true
	_set_prompt("")
	_boat.set_moored(true)
	
	var desired_rotation := global_rotation + PI * 0.5
	var target_rotation := _boat.global_rotation + angle_difference(
		_boat.global_rotation,
		desired_rotation
	)
	
	var duration := maxf(0.05, mooring_time)
	var tween := create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(
		_boat,
		"global_position",
		_mooring_point.global_position,
		duration
	)
	tween.parallel().tween_property(
		_boat,
		"global_rotation",
		target_rotation,
		duration
	)
	tween.finished.connect(_finish_docking)
	

func _finish_docking() -> void:
	_docking = false
	
	if not is_instance_valid(_boat):
		return
	
	if (
		_boat.is_sunk
		or run_state == null
		or run_state.is_dock_used(dock_id)
	):
		_boat.set_moored(false)
		return
	
	SFX.play(&"dock", -5.0, 0.05)
	run_state.request_shop(dock_id)

func _set_prompt(message: String) -> void:
	var hud := get_tree().get_first_node_in_group(&"hud")
	if hud != null and hud.has_method("set_dock_prompt"):
		hud.call("set_dock_prompt", self, message)
