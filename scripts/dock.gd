class_name RiverDock
extends Area2D

@export var dock_id: int = 0
@export var run_state: RunState
@export var max_dock_speed: float = 80.0
@export var mooring_time: float = 0.35

@onready var _visual: CanvasItem = $Visual
@onready var _label: Label = $Label
@onready var _mooring_point: Marker2D = $MooringPoint

var _boat: Boat
var _docking: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_label.hide()
	_refresh_visual()

func _physics_process(_delta: float) -> void:
	_refresh_visual()
	if _docking:
		return
	
	if run_state == null or run_state.is_dock_used(dock_id):
		_label.show()
		_label.text = "USED"
		return
	
	if not is_instance_valid(_boat) or _boat.is_sunk:
		_label.hide()
		return
	
	_label.show()
	
	if _boat.get_water_speed() > max_dock_speed:
		_label.text = "TOO FAST!"
		_label.modulate = Color("#e3572b")
		return
	
	_label.text = "[E] Dock!"
	_label.modulate = Color("#fff3d6")
	
	if Input.is_action_just_pressed(&"interact"):
		_begin_docking()

func _refresh_visual() -> void:
	if run_state != null and run_state.is_dock_used(dock_id):
		_visual.modulate = Color(0.42, 0.42, 0.44, 1.0)
	else:
		_visual.modulate = Color.WHITE

func _on_body_entered(body: Node2D) -> void:
	if body is Boat:
		_boat = body

func _on_body_exited(body: Node2D) -> void:
	if body == _boat and not _docking:
		_boat = null
		if run_state == null or not run_state.is_dock_used(dock_id):
			_label.hide()

func _begin_docking() -> void:
	if not is_instance_valid(_boat) or _boat.is_sunk:
		return
	
	_docking = true
	_label.hide()
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
		"target_rotation",
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
	
	run_state.request_shop(dock_id)
