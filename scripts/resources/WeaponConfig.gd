class_name WeaponConfig
extends Resource

@export var id: String
@export var name: String
@export var weapon_type: String
@export var base_stats: Dictionary
@export var evolution: Dictionary
@export var projectile_scene_path: String
@export var upgrade_tree: Array[Dictionary]

func _init(data: Dictionary = {}):
	if data.has("id"):
		id = data["id"]
	if data.has("name"):
		name = data["name"]
	if data.has("type"):
		weapon_type = data["type"]
	if data.has("base_stats"):
		base_stats = data["base_stats"]
	if data.has("evolution"):
		evolution = data["evolution"]
	if data.has("projectile_scene"):
		projectile_scene_path = data["projectile_scene"]
	if data.has("upgrade_tree"):
		upgrade_tree = data["upgrade_tree"]

func is_valid() -> bool:
	return id != "" and name != "" and not base_stats.is_empty()

func get_base_stat(stat_name: String) -> float:
	if base_stats.has(stat_name):
		return base_stats[stat_name]
	return 0.0

func can_evolve() -> bool:
	return not evolution.is_empty() and evolution.has("evolved_weapon")

func get_evolution_requirement() -> int:
	if evolution.has("required_level"):
		return evolution["required_level"]
	return 999