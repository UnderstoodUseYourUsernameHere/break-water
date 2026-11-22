class_name RiverDock
extends Area2D

@export var dock_id: int = 0
@export var run_state: RunState
@export var max_dock_speed: float = 80.0

@onready var _visual: Polygon2D = $Visual
@onready var _label: Label = $Label

var _boat: Boat

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_label.hide()
	_refresh_visual()

func _process(delta: float) -> void:
	_refresh_visual()
	
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
		_boat.global_position = global_position
		_boat.velocity = Vector2.ZERO
		run_state.request_shop(dock_id)

func _refresh_visual() -> void:
	if run_state != null and run_state.is_dock_used(dock_id):
		_visual.color = Color("#4a4440")
	else:
		_visual.color = Color("#8a6f5e")

func _on_body_entered(body: Node2D) -> void:
	if body is Boat:
		_boat = body

func _on_body_exited(body: Node2D) -> void:
	if body == _boat:
		_boat == null
		if run_state == null or not run_state.is_dock_used(dock_id):
			_label.hide()
