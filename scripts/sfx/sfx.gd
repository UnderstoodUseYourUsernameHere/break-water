extends Node

const STREAMS := {
	&"row": preload("res://audio/row.ogg"),
	&"shot": preload("res://audio/shot.ogg"),
	&"reload": preload("res://audio/reload.ogg"),
	&"enemy_hit": preload("res://audio/enemy_hit.ogg"),
	&"enemy_kill": preload("res://audio/enemy_kill.ogg"),
	&"boat_hit": preload("res://audio/boat_hit.ogg"),
	&"scrap": preload("res://audio/scrap.ogg"),
	&"buy": preload("res://audio/buy.ogg"),
	&"deny": preload("res://audio/deny.ogg"),
	&"dock": preload("res://audio/dock.ogg"),
	&"undock": preload("res://audio/undock.ogg"),
	&"wave": preload("res://audio/wave.ogg"),
}

@export var default_bus: StringName = &"SFX"
@export var max_players: int = 24

var _players: Array[AudioStreamPlayer] = []
var _cursor: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(max_players):
		var player := AudioStreamPlayer.new()
		player.bus = default_bus
		add_child(player)
		_players.append(player)


func play(id: StringName, volume_db: float = 0.0, pitch_jitter: float = 0.06) -> void:
	if not STREAMS.has(id):
		push_warning("Missing SFX id: %s" % id)
		return

	var player := _players[_cursor]
	_cursor = (_cursor + 1) % _players.size()

	player.stop()
	player.stream = STREAMS[id]
	player.volume_db = volume_db
	player.pitch_scale = randf_range(1.0 - pitch_jitter, 1.0 + pitch_jitter)
	player.play()
