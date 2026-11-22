class_name RiverProfile
extends RefCounted

const STEP := 64
const SEGMENTS := 12
const HEIGHT := STEP * SEGMENTS
const BASE_HALF_WIDTH := 240.0
const MIN_HALF_WIDTH := 145.0
const MAX_HALF_WIDTH := 305.0

var run_seed: int
var _bend := FastNoiseLite.new()
var _width := FastNoiseLite.new()

func _init(seed_value: int = 2250) -> void:
	run_seed = seed_value
	_configure(_bend, run_seed, 0.0019)
	_bend.fractal_type = FastNoiseLite.FRACTAL_FBM
	_bend.fractal_octaves = 2
	_bend.fractal_gain = 0.45
	_configure(_width, run_seed ^ 0x35ad, 0.0025)

func _configure(field: FastNoiseLite, field_seed: int, frequency: float) -> void:
	field.seed = field_seed
	field.noise_type = FastNoiseLite.TYPE_PERLIN
	field.fractal_type = FastNoiseLite.FRACTAL_NONE
	field.frequency = frequency

static func chunk_id_at(y: float) -> int:
	return floori(y / float(HEIGHT))

func banks_on_row(row: int) -> Vector2:
	var y := float(row * STEP)
	var center := 430.0 * _bend.get_noise_1d(y)
	center *= smoothstep(0.0, 256.0, absf(y))
	
	var half_width := clampf(
		BASE_HALF_WIDTH + 115.0 * _width.get_noise_1d(y),
		MIN_HALF_WIDTH,
		MAX_HALF_WIDTH
	)
	return Vector2(center - half_width, center + half_width)

func banks_at(y: float) -> Vector2:
	var row := floori(y / float(STEP))
	var weight := (y - float(row * STEP)) / float(STEP)
	return banks_on_row(row).lerp(banks_on_row(row + 1), weight)
