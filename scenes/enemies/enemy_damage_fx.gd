extends Node2D

@export var body_radius: float = 14.0
@export var shake_time: float = 0.18
@export var shake_px: float = 3.2
@export var crack_color := Color(0.07, 0.04, 0.04, 0.85)

var _enemy: RiverEnemy
var _visual: Node2D

var _left: float = 0.0
var _crack_seed: int = 0
var _missing: int = 0
var _base_modulate := Color.WHITE

func _ready() -> void:
	_enemy = get_parent() as RiverEnemy
	assert(_enemy != null, "EnemyDamageFx must be a direct child of RiverEnemy!")
	_visual = _enemy.get_node_or_null("Visual") as Node2D
	_enemy.hit_taken.connect(_on_hit_taken)

func _on_hit_taken(remaining: int, maximum: int) -> void:
	_missing = maxi(0, maximum - remaining)
	_crack_seed = randi()
	_left = shake_time
	
	if _visual != null:
		_base_modulate = _visual.modulate
	
	queue_redraw()

func _process(delta: float) -> void:
	if _left <= 0.0:
		return
	
	_left = maxf(0.0, _left - delta)
	if _visual == null:
		return
	
	var k := _left / shake_time
	
	if _left <= 0.0:
		_visual.position = Vector2.ZERO
		_visual.modulate = _base_modulate
		return
	
	_visual.position = Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	) * shake_px * k
	_visual.modulate = _base_modulate.lerp(Color(2.6, 2.6, 2.6), k)

func _draw() -> void:
	if _missing <= 0:
		return
	
	var rng := RandomNumberGenerator.new()
	rng.seed = _crack_seed
	
	var count := mini(_missing * 2 + 1, 7)
	
	for i in range(count):
		var angle := rng.randf_range(0.0, TAU)
		var a := Vector2.RIGHT.rotated(angle) * body_radius * rng.randf_range(0.10, 0.40)
		var b := a + Vector2.RIGHT.rotated(
			angle + rng.randf_range(-0.55, 0.55)
		) * body_radius * rng.randf_range(0.35, 0.55)
		var c := b + Vector2.RIGHT.rotated(
			angle + rng.randf_range(-0.95, 0.95)
		) * body_radius * rng.randf_range(0.25, 0.45)
		draw_polyline(
			PackedVector2Array([a, b, c]),
			crack_color,
			1.6,
			true
		)
