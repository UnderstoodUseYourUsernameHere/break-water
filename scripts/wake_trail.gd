extends Line2D

@export var fade_time: float = 0.9
@export var min_step: float = 9.0
@export var max_points: int = 25

var _boat: Boat
var _ages: Array[float] = []

func _ready() -> void:
	_boat = get_parent() as Boat
	assert(_boat != null, "Wake must be a direct child of Boat!")
	top_level = true
	global_transform = Transform2D.IDENTITY
	clear_points()

func _physics_process(delta: float) -> void:
	for i in range(_ages.size()):
		_ages[i] += delta
	
	while _ages.size() > 0 and _ages[0] > fade_time:
		_ages.remove_at(0)
		remove_point(0)
	
	var stern := _boat.global_position - Vector2.UP.rotated(_boat.global_rotation) * 20.0
	var should_add := get_point_count() == 0 
	if not should_add:
		should_add = stern.distance_to(get_point_position(get_point_count() - 1)) >= min_step
		
		if should_add:
			add_point(stern)
			_ages.append(0.0)
	
	while get_point_count() > max_points:
		remove_point(0)
		_ages.remove_at(0)
