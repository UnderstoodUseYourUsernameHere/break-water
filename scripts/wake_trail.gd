extends Line2D

@export var fade_time: float = 0.9
@export var min_step: float = 9.0
@export var max_points: int = 25
@export var stern_offset: float = 20.0
@export var min_speed: float = 18.0

var _boat: Boat
var _ages: Array[float] = []

func _ready() -> void:
	_boat = get_parent() as Boat
	assert(_boat != null, "Wake must be a direct child of Boat!")
	top_level = true
	global_transform = Transform2D.IDENTITY
	clear_points()
	_build_style()

func _build_style() -> void:
	var g := Gradient.new()
	g.set_offset(0, 0.0)
	g.set_offset(1, 1.0)
	g.set_color(0, Color(0.62, 0.77, 0.79, 0.0))
	g.set_color(1, Color(0.78, 0.90, 0.92, 0.55))
	gradient = g
	
	var c := Curve.new()
	c.add_point(Vector2(0.0, 1.0))
	c.add_point(Vector2(0.55, 0.65))
	c.add_point(Vector2(1.0, 0.28))
	width_curve = c
	
	width = 11.0
	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND
	joint_mode = Line2D.LINE_JOINT_ROUND

func _physics_process(delta: float) -> void:
	for i in range(_ages.size()):
		_ages[i] += delta
	
	while _ages.size() > 0 and _ages[0] > fade_time:
		_ages.remove_at(0)
		remove_point(0)
	
	if _boat.get_water_speed() < min_speed:
		return
	
	var stern := _boat.global_position - Vector2.UP.rotated(_boat.global_rotation) * stern_offset
	var should_add := get_point_count() == 0
	if not should_add:
		var last := get_point_position(get_point_count() - 1)
		should_add = stern.distance_to(last) >= min_step
	
	if should_add:
		add_point(stern)
		_ages.append(0.0)
	
	while get_point_count() > max_points:
		remove_point(0)
		_ages.remove_at(0)
