class_name RiverDock
extends Area2D

@export var dock_id: int = 0
@export var run_state: RunState

@onready var _visual: Polygon2D = $Visual
@onready var _label: Label = $Label

func _ready() -> void:
	_refresh_visual()

func _process(delta: float) -> void:
	_refresh_visual()

func _refresh_visual() -> void:
	if run_state != null and run_state.is_dock_used(dock_id):
		_visual.color = Color("#4a4440")
		_label.text = "USED"
	else:
		_visual.color = Color("#8a6f5e")
		_label.text = "DOCK!"
