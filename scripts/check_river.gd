extends SceneTree

const PROFILE := preload("res://scripts/river_profile.gd")

func _init() -> void:
	var a := PROFILE.new(2250)
	var b := PROFILE.new(2250)
	var c := PROFILE.new(2251)
	
	var ok := PROFILE.chunk_id_at(-1.0) == -1 and PROFILE.chunk_id_at(0.0) == 0
	var other_seed_differs := false
	
	for y in range(-3200, 3201, 37):
		var edges := a.banks_at(float(y))
		ok = ok and edges.is_equal_approx(b.banks_at(float(y)))
		ok = ok and edges.y - edges.x >= 2.0 * PROFILE.MIN_HALF_WIDTH - 0.01
		if not edges.is_equal_approx(c.banks_at(float(y))):
			other_seed_differs = true
	
	var midpoint := a.banks_on_row(-1).lerp(a.banks_on_row(0), 0.5)
	ok = ok and a.banks_at(-32.0).is_equal_approx(midpoint)
	
	if not ok or not other_seed_differs:
		push_error("River profile checkc failed!")
		quit(1)
		return
	
	print("PASS: river porifle")
	quit(0)
