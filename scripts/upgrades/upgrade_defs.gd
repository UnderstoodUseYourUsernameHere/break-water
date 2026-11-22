class_name UpgradeDefs
extends RefCounted

const QUICK_BOLT := &"quick_bolt"
const HULL_PATCH := &"hull_patch"
const STRONGER_ARMS := &"stronger_stroke"

static func all_ids() -> Array[StringName]:
	return [QUICK_BOLT, HULL_PATCH, STRONGER_ARMS]

static func title(id: StringName) -> String:
	match id:
		QUICK_BOLT:
			return "Quick Bolt"
		HULL_PATCH:
			return "Hull Patch"
		STRONGER_ARMS:
			return "Stronger Arms"
		_:
			return "Unknown"


static func description(id: StringName, level: int) -> String:
	match id:
		QUICK_BOLT:
			return "Reload %.2fs -> %.2fs" % [
				2.0 * pow(0.84, level),
				2.0 * pow(0.84, level + 1)
			]
		HULL_PATCH:
			return "Repair 2 hull"
		STRONGER_ARMS:
			return "+12%% rowing force"
		_:
			return ""

static func cost(id: StringName, level: int) -> int:
	match id:
		QUICK_BOLT:
			return 4 + level * 3
		HULL_PATCH:
			return 3
		STRONGER_ARMS:
			return 4 + level * 2
		_:
			return 999

static func max_level(id: StringName) -> int:
	match id:
		QUICK_BOLT:
			return 3
		HULL_PATCH:
			return 999 ## Its a consumable so it doesnt need a max like the others
		STRONGER_ARMS:
			return 4
		_:
			return 0

static func is_consumable(id: StringName) -> bool:
	return id == HULL_PATCH
