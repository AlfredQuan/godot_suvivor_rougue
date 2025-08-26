class_name EnemyConfig
extends Resource

@export var id: String
@export var name: String
@export var base_stats: Dictionary
@export var ai_type: String
@export var sprite_path: String
@export var spawn_weight: float

func _init(data: Dictionary = {}):
	if data.has("id"):
		id = data["id"]
	if data.has("name"):
		name = data["name"]
	if data.has("base_stats"):
		base_stats = data["base_stats"]
	if data.has("ai_type"):
		ai_type = data["ai_type"]
	if data.has("sprite_path"):
		sprite_path = data["sprite_path"]
	if data.has("spawn_weight"):
		spawn_weight = data["spawn_weight"]
	else:
		spawn_weight = 1.0

func is_valid() -> bool:
	return id != "" and name != "" and not base_stats.is_empty()

func get_base_stat(stat_name: String) -> float:
	if base_stats.has(stat_name):
		return base_stats[stat_name]
	return 0.0