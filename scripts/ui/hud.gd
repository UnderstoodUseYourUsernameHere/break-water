extends CanvasLayer

@export var boat: Boat
@export var director: WaveDirector
@export var banner_time: float = 1.6

var _game_over: bool = false
var _banner_left: float = 0.0

@onready var _distance: Label = $Stats/Distance
@onready var _hull: Label = $Stats/Hull
@onready var _kills: Label = $Stats/Kills
@onready var _scrap: Label = $Stats/Scrap
@onready var _reload: ProgressBar = $Stats/Reload
@onready var _banner: Label = $WaveBanner
@onready var _game_over_label: Label = $GameOver

func _ready() -> void:
	assert(boat != null and director != null, "HUD: assign Boat and Director!")
	_banner.visible = false
	_game_over_label.visible = false
	boat.sunk.connect(_on_boat_sunk)
	director.wave_started.connect(_on_wave_started)

func _process(delta: float) -> void:
	var stats: RunState = director.run_state
	_distance.text = "%d m     best %d m" % [maxi(0, roundi(stats.current_m)), roundi(stats.peak_m)]
	_kills.text = "KILLS  %d" % stats.kills
	_scrap.text = "SCRAP  %d" % stats.scrap
	_reload.value = boat.weapon.reload_ratio()
	
	if _banner_left > 0.0:
		_banner_left -= delta
		_banner.visible = _banner_left > 0.0
	
	if _game_over and Input.is_action_pressed(&"restart"):
		get_tree().reload_current_scene()

func _on_wave_started(index: int, size: int) -> void:
	_banner.text = "WAVE %d  -  %d incoming" % [index, size]
	_banner_left = banner_time
	_banner.visible = true

func _on_boat_sunk() -> void:
	_game_over = true
	var shots: int = boat.weapon.shots_fired
	var stats: RunState = director.run_state
	var accuracy := 0.0
	if shots > 0:
		accuracy = 100.0 * boat.weapon.hits / shots
	_game_over_label.text = (
		"SUNK\n\n%d m\n\nkills %d    shots %d    accuracy %d%%\n\n Press R to row again!" % [roundi(stats.peak_m), stats.kills, shots, roundi(accuracy)]
	)
	_game_over_label.visible = true
