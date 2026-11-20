class_name RiverChunk
extends Node2D

signal geometry_ready(
	left: PackedVector2Array,
	right: PackedVector2Array,
	left_land: PackedVector2Array,
	right_land: PackedVector2Array,
	start_y: float
)

const OUTER_X := 2048.0

func build(profile: RiverProfile, chunk_id: int) -> void:
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	var first_row := chunk_id * RiverProfile.SEGMENTS
	
	for i in range(RiverProfile.SEGMENTS + 1):
		var edges := profile.banks_on_row(first_row + i)
		var y := float(i * RiverProfile.STEP)
		left.append(Vector2(edges.x, y))
		right.append(Vector2(edges.y, y))
	
	var left_land := _close_bank(left, -OUTER_X)
	var right_land := _close_bank(right, OUTER_X)
	
	($Banks/LeftBank as CollisionPolygon2D).polygon = left_land
	($Banks/RightBank as CollisionPolygon2D).polygon = right_land
	geometry_ready.emit(left, right, left_land, right_land, float(chunk_id * RiverProfile.HEIGHT))

func _close_bank(edge: PackedVector2Array, outer_x: float) -> PackedVector2Array:
	var land := edge.duplicate()
	land.append(Vector2(outer_x, RiverProfile.HEIGHT))
	land.append(Vector2(outer_x, 0.0))
	return land
