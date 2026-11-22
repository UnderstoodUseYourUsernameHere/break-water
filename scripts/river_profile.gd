class_name RiverProfile
extends RefCounted

const STEP := 32
const SEGMENTS := 24
const HEIGHT := STEP * SEGMENTS

const BASE_HALF_WIDTH := 240.0
const MIN_HALF_WIDTH := 145.0
const MAX_HALF_WIDTH := 305.0

const BEND_AMPLITUDE := 330.0
const WIDTH_AMPLITUDE := 178.0
const SMOOTH_SPAN := 80.0
const LAUNCH_CENTERING := 420.0

var run_seed: int

var _bend := FastNoiseLite.new()
var _width := FastNoiseLite.new()
var _row_cache: Dictionary = {}

func _init(seed_value: int = 2250) -> void:
	run_seed = seed_value
	_configure(_bend, run_seed, 0.0019)
	_configure(_width, run_seed ^ 0x35ad, 0.0025)

func _configure(field: FastNoiseLite, field_seed: int, frequency: float) -> void:
	field.seed = field_seed
	field.noise_type = FastNoiseLite.TYPE_PERLIN
	field.fractal_type = FastNoiseLite.FRACTAL_NONE
	field.frequency = frequency

static func chunk_id_at(y: float) -> int:
	return floori(y / float(HEIGHT))

func _smooth(field: FastNoiseLite, y: float) -> float:
	return (
		field.get_noise_1d(y - SMOOTH_SPAN) * 0.12
		+ field.get_noise_1d(y - SMOOTH_SPAN * 0.5) * 0.23
		+ field.get_noise_1d(y) * 0.30
		+ field.get_noise_1d(y + SMOOTH_SPAN * 0.5) * 0.23
		+ field.get_noise_1d(y + SMOOTH_SPAN) * 0.12
	)

func banks_on_row(row: int) -> Vector2:
	if _row_cache.has(row):
		return _row_cache[row]
	
	var y := float(row * STEP)
	
	var center := BEND_AMPLITUDE * _smooth(_bend, y)
	center *= smoothstep(0.0, LAUNCH_CENTERING, absf(y))
	
	var half_width := clampf(
		BASE_HALF_WIDTH + WIDTH_AMPLITUDE * _smooth(_width, y),
		MIN_HALF_WIDTH,
		MAX_HALF_WIDTH
	)
	
	var banks := Vector2(center - half_width, center + half_width)
	_row_cache[row] = banks
	return banks

func banks_at(y: float) -> Vector2:
	var row := floori(y / float(STEP))
	var t := (y - float(row * STEP)) / float(STEP)
	
	return banks_on_row(row).lerp(
		banks_on_row(row + 1),
		smoothstep(0.0, 1.0, t)
	)
