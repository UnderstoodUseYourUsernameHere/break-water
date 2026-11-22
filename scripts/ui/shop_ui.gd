extends CanvasLayer

@export var run_state: RunState
@export var boat: Boat
@export var river: HeadWatersRiver

var _active_dock_id: int = -1
var _offers: Array[StringName] = []

@onready var _panel: Panel = $Panel
@onready var _scrap_label: Label = $Panel/ScrapLabel
@onready var _leave_button: Button = $Panel/LeaveButton
@onready var _offer_buttons: Array[Button] = [
	$Panel/Offer1,
	$Panel/Offer2,
	$Panel/Offer3
]

func _ready() -> void:
	assert(run_state != null, "ShopUI: assign Runstate!")
	assert(boat != null, "ShopUI: assign the damn boat, CJ!")
	assert(river != null, "ShopUI: assign River!")
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	_panel.hide()
	run_state.shop_requested.connect(_on_shop_requested)
	_leave_button.pressed.connect(_on_leave_pressed)
	
	for i in range(_offer_buttons.size()):
		_offer_buttons[i].pressed.connect(_on_offer_pressed.bind(i))

func _on_shop_requested(dock_id: int) -> void:
	if run_state.is_dock_used(dock_id):
		return
	
	_active_dock_id = dock_id
	_roll_offers(dock_id)
	_refresh()
	_panel.show()
	get_tree().paused = true

func _roll_offers(dock_id: int) -> void:
	_offers.clear()
	
	var pool: Array[StringName] = []
	for id in UpgradeDefs.all_ids():
		if UpgradeDefs.is_consumable(id):
			continue
		if run_state.upgrade_level(id) < UpgradeDefs.max_level(id):
			pool.append(id)
	
	var rng := RandomNumberGenerator.new()
	rng.seed = ("%d:shop.%d" % [river.run_seed, dock_id]).hash()
	
	for i in range(pool.size() - 1, 0, -1):
		var j := rng.randi_range(0, 1)
		var swapped := pool[i]
		pool[i] = pool[j]
		pool[j] = swapped
	
	if boat.hull_points < boat.max_hull_points:
		_offers.append(UpgradeDefs.HULL_PATCH)
	
	for id in pool:
		if _offers.size() >= _offer_buttons.size():
			break
		_offers.append(id)
	
	if _offers.is_empty():
		_offers.append(UpgradeDefs.HULL_PATCH)

func _refresh() -> void:
	_scrap_label.text = "SCRAP: %d" % run_state.scrap
	
	for i in range(_offer_buttons.size()):
		var button := _offer_buttons[i]
		
		if i >= _offers.size():
			button.hide()
			continue
		
		button.show()
		var id := _offers[i]
		var level := run_state.upgrade_level(id)
		var cost := UpgradeDefs.cost(id, level)
		var maxed := (not UpgradeDefs.is_consumable(id)) and level >= UpgradeDefs.max_level(id)
		var useless_patch := (
			id == UpgradeDefs.HULL_PATCH
			and boat.hull_points >= boat.max_hull_points
		)
		
		button.text = "%s   -   %d scrap\n%s" % [
			UpgradeDefs.title(id),
			cost,
			"MAXED" if maxed else UpgradeDefs.description(id, level)
		]
		button.disabled = maxed or useless_patch or not run_state.can_spend(cost)

func _on_offer_pressed(index: int) -> void:
	var id := _offers[index]
	var level := run_state.upgrade_level(id)
	var cost := UpgradeDefs.cost(id, level)
	
	if id == UpgradeDefs.HULL_PATCH and boat.hull_points >= boat.max_hull_points:
		return
	
	if not run_state.spend_scrap(cost):
		return
	
	_apply_upgrade(id)
	SFX.play(&"buy", -4.0, 0.05)
	
	if not UpgradeDefs.is_consumable(id):
		run_state.add_upgrade_level(id)
	
	_refresh()

func _on_leave_pressed() -> void:
	if _active_dock_id != -1:
		run_state.mark_dock_used(_active_dock_id)
		SFX.play(&"undock", -6.0, 0.05)
		_active_dock_id = -1
	
	_panel.hide()
	if is_instance_valid(boat):
		boat.set_moored(false)
	get_tree().paused = false

func _apply_upgrade(id: StringName) -> void:
	var next_level := run_state.upgrade_level(id) + 1
	
	match id:
		UpgradeDefs.QUICK_BOLT:
			boat.weapon.apply_reload_multiplier(pow(0.84, next_level))
		UpgradeDefs.HULL_PATCH:
			boat.repair_hull(2)
		UpgradeDefs.STRONGER_ARMS:
			boat._apply_stroke_multiplier(1.0 + 0.12 * float(next_level))
		UpgradeDefs.SECOND_ROUND:
			boat.weapon.add_round()
		UpgradeDefs.HEAVY_BOLT:
			boat.weapon.add_damage(1)
		UpgradeDefs.PIERCING_BOLT:
			boat.weapon.add_pierce(1)
		UpgradeDefs.REINFORCED_HULL:
			boat.add_max_hull(1)
		UpgradeDefs.KEEL_TRIM:
			boat.apply_turn_multiplier(1.0 + 0.15 * float(next_level))
