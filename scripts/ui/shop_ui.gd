extends CanvasLayer

@export var run_state: RunState

var _active_dock_id: int = -1

@onready var _panel: Panel = $Panel
@onready var _scrap_label: Label = $Panel/ScrapLabel
@onready var _leave_button: Button = $Panel/LeaveButton

func _ready() -> void:
	assert(run_state != null, "ShopUI: assign Runstate!")
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	_panel.hide()
	run_state.shop_requested.connect(_on_shop_requested)
	_leave_button.pressed.connect(_on_leave_pressed)

func _on_shop_requested(dock_id: int) -> void:
	if run_state.is_dock_used(dock_id):
		return
	
	_active_dock_id = dock_id
	_scrap_label.text = "SCRAP: %d" % run_state.scrap
	_panel.show()
	get_tree().paused = true

func _on_leave_pressed() -> void:
	if _active_dock_id != -1:
		run_state.mark_dock_used(_active_dock_id)
		_active_dock_id = -1
	
	_panel.hide()
	get_tree().paused = false
