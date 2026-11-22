class_name UpgradeDefs
extends RefCounted

const QUICK_BOLT := &"quick_bolt"
const HULL_PATCH := &"hull_patch"
const STRONGER_ARMS := &"stronger_stroke"
const SECOND_ROUND := &"second_round"
const HEAVY_BOLT := &"heavy_bolt"
const PIERCING_BOLT := &"piercing_bolt"
const REINFORCED_HULL := &"reinforced_hull"
const KEEL_TRIM := &"keel_trim"

static func all_ids() -> Array[StringName]:
	return [
		QUICK_BOLT,
		HULL_PATCH,
		STRONGER_ARMS,
		SECOND_ROUND,
		HEAVY_BOLT,
		PIERCING_BOLT,
		REINFORCED_HULL,
		KEEL_TRIM
	]

static func title(id: StringName) -> String:
	match id:
		QUICK_BOLT:
			return "Quick Bolt"
		HULL_PATCH:
			return "Hull Patch"
		STRONGER_ARMS:
			return "Stronger Arms"
		SECOND_ROUND:
			return "Second Round"
		HEAVY_BOLT:
			return "Heavy Bolt"
		PIERCING_BOLT:
			return "Piercing Bolt"
		REINFORCED_HULL:
			return "Reinforced Hull"
		KEEL_TRIM:
			return "Keel Trim"
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
		SECOND_ROUND:
			return "+1 round before reloading"
		HEAVY_BOLT:
			return "+1 shot damage"
		PIERCING_BOLT:
			return "Shots pass through 1 more enemy!"
		REINFORCED_HULL:
			return "+1 max hull, repairs your damage too!"
		KEEL_TRIM: return "+15%% turning speed"
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
		SECOND_ROUND:
			return 9 + level * 5
		HEAVY_BOLT:
			return 7 + level * 5
		PIERCING_BOLT:
			return 8 + level * 6
		REINFORCED_HULL:
			return 6 + level * 4
		KEEL_TRIM:
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
		SECOND_ROUND:
			return 2
		HEAVY_BOLT:
			return 2
		PIERCING_BOLT:
			return 2
		REINFORCED_HULL:
			return 3
		KEEL_TRIM:
			return 2
		_:
			return 0

static func is_consumable(id: StringName) -> bool:
	return id == HULL_PATCH
