extends Node

# 配置文件路径
const CONFIG_PATH = "res://data/configs/"
const CONSTANTS_PATH = "res://data/constants.json"

# 配置缓存
var character_configs: Dictionary = {}
var weapon_configs: Dictionary = {}
var enemy_configs: Dictionary = {}
var effect_configs: Dictionary = {}
var game_constants: Dictionary = {}

# 错误日志
var load_errors: Array[String] = []

func _ready():
	load_all_configs()

func load_all_configs():
	load_errors.clear()
	print("ConfigManager: 开始加载所有配置文件...")
	
	load_constants()
	load_character_configs()
	load_weapon_configs()
	load_enemy_configs()
	load_effect_configs()
	
	print("ConfigManager: 配置加载完成")
	if load_errors.size() > 0:
		print("ConfigManager: 发现 %d 个加载错误:" % load_errors.size())
		for error in load_errors:
			print("  - %s" % error)

func load_constants():
	var file_path = CONSTANTS_PATH
	if not FileAccess.file_exists(file_path):
		add_error("常量文件不存在: %s" % file_path)
		game_constants = get_default_constants()
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		add_error("无法打开常量文件: %s" % file_path)
		game_constants = get_default_constants()
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		add_error("常量文件JSON解析失败: %s" % file_path)
		game_constants = get_default_constants()
		return
	
	game_constants = json.data
	print("ConfigManager: 常量文件加载成功")

func load_character_configs():
	var config_dir = CONFIG_PATH + "characters/"
	load_configs_from_directory(config_dir, character_configs, "角色")

func load_weapon_configs():
	var config_dir = CONFIG_PATH + "weapons/"
	load_configs_from_directory(config_dir, weapon_configs, "武器")

func load_enemy_configs():
	var config_dir = CONFIG_PATH + "enemies/"
	load_configs_from_directory(config_dir, enemy_configs, "敌人")

func load_effect_configs():
	var config_dir = CONFIG_PATH + "effects/"
	load_configs_from_directory(config_dir, effect_configs, "效果")

func load_configs_from_directory(dir_path: String, target_dict: Dictionary, type_name: String):
	if not DirAccess.dir_exists_absolute(dir_path):
		add_error("%s配置目录不存在: %s" % [type_name, dir_path])
		return
	
	var dir = DirAccess.open(dir_path)
	if dir == null:
		add_error("无法打开%s配置目录: %s" % [type_name, dir_path])
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var loaded_count = 0
	
	while file_name != "":
		if file_name.ends_with(".json"):
			var config_data = load_json_file(dir_path + file_name)
			if config_data != null:
				var config_id = config_data.get("id", "")
				if config_id != "":
					target_dict[config_id] = config_data
					loaded_count += 1
				else:
					add_error("%s配置文件缺少id字段: %s" % [type_name, file_name])
		file_name = dir.get_next()
	
	print("ConfigManager: 加载了 %d 个%s配置" % [loaded_count, type_name])

func load_json_file(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		add_error("配置文件不存在: %s" % file_path)
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		add_error("无法打开配置文件: %s" % file_path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		add_error("JSON解析失败: %s (错误: %s)" % [file_path, json.error_string])
		return {}
	
	return json.data

func get_character_config(id: String) -> CharacterConfig:
	if character_configs.has(id):
		return CharacterConfig.new(character_configs[id])
	add_error("角色配置不存在: %s" % id)
	return null

func get_weapon_config(id: String) -> WeaponConfig:
	if weapon_configs.has(id):
		return WeaponConfig.new(weapon_configs[id])
	add_error("武器配置不存在: %s" % id)
	return null

func get_enemy_config(id: String) -> EnemyConfig:
	if enemy_configs.has(id):
		return EnemyConfig.new(enemy_configs[id])
	add_error("敌人配置不存在: %s" % id)
	return null

func get_effect_config(id: String) -> EffectConfig:
	if effect_configs.has(id):
		return EffectConfig.new(effect_configs[id])
	add_error("效果配置不存在: %s" % id)
	return null

func get_constant(path: String, default_value = null):
	var keys = path.split(".")
	var current = game_constants
	
	for key in keys:
		if current.has(key):
			current = current[key]
		else:
			if default_value != null:
				return default_value
			add_error("常量不存在: %s" % path)
			return null
	
	return current

func get_all_character_ids() -> Array[String]:
	return character_configs.keys()

func get_all_weapon_ids() -> Array[String]:
	return weapon_configs.keys()

func get_all_enemy_ids() -> Array[String]:
	return enemy_configs.keys()

func get_all_effect_ids() -> Array[String]:
	return effect_configs.keys()

func reload_configs():
	print("ConfigManager: 重新加载配置文件...")
	load_all_configs()

func add_error(message: String):
	load_errors.append(message)
	print("ConfigManager Error: %s" % message)

func get_default_constants() -> Dictionary:
	return {
		"game": {
			"base_exp_requirement": 10,
			"exp_scaling_factor": 1.2,
			"max_level": 100,
			"enemy_spawn_interval": 2.0,
			"difficulty_scaling": 0.1
		},
		"ui": {
			"effect_choice_count": 3,
			"upgrade_display_time": 5.0
		},
		"performance": {
			"max_enemies": 200,
			"max_projectiles": 500,
			"cleanup_interval": 10.0
		}
	}