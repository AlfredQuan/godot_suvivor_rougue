class_name EffectConfig
extends Resource

@export var id: String
@export var name: String
@export var description: String
@export var rarity: String
@export var max_stacks: int
@export var effect_type: String
@export var effect_data: Dictionary
@export var prerequisites: Array[String]
@export var exclusions: Array[String]

func _init(data: Dictionary = {}):
	if data.has("id"):
		id = data["id"]
	if data.has("name"):
		name = data["name"]
	if data.has("description"):
		description = data["description"]
	if data.has("rarity"):
		rarity = data["rarity"]
	if data.has("max_stacks"):
		max_stacks = data["max_stacks"]
	else:
		max_stacks = 1
	if data.has("effect_type"):
		effect_type = data["effect_type"]
	if data.has("effect_data"):
		effect_data = data["effect_data"]
	if data.has("prerequisites"):
		prerequisites = data["prerequisites"]
	if data.has("exclusions"):
		exclusions = data["exclusions"]

func is_valid() -> bool:
	return id != "" and name != "" and effect_type != "" and not effect_data.is_empty()

func get_rarity_weight() -> float:
	match rarity:
		"common":
			return 1.0
		"rare":
			return 0.3
		"epic":
			return 0.1
		"legendary":
			return 0.05
		_:
			return 1.0