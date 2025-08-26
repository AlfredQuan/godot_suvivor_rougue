class_name CharacterConfig
extends Resource

@export var id: String
@export var name: String
@export var description: String
@export var base_stats: Dictionary
@export var starting_weapon: String
@export var sprite_path: String
@export var special_ability: String

func _init(data: Dictionary = {}):
	if data.has("id"):
		id = data["id"]
	if data.has("name"):
		name = data["name"]
	if data.has("description"):
		description = data["description"]
	if data.has("base_stats"):
		base_stats = data["base_stats"]
	if data.has("starting_weapon"):
		starting_weapon = data["starting_weapon"]
	if data.has("sprite_path"):
		sprite_path = data["sprite_path"]
	if data.has("special_ability"):
		special_ability = data["special_ability"]

func is_valid() -> bool:
	return id != "" and name != "" and not base_stats.is_empty()

func get_base_stat(stat_name: String) -> float:
	if base_stats.has(stat_name):
		return base_stats[stat_name]
	return 0.0