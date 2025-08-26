extends Node

# 配置系统验证脚本

func _ready():
	print("=== 配置系统验证开始 ===")
	validate_all()
	print("=== 配置系统验证完成 ===")
	get_tree().quit()

func validate_all():
	var success_count = 0
	var total_tests = 0
	
	# 验证1: 文件存在性
	total_tests += 1
	if validate_files_exist():
		print("✓ 所有配置文件存在")
		success_count += 1
	else:
		print("✗ 配置文件缺失")
	
	# 验证2: JSON格式正确性
	total_tests += 1
	if validate_json_format():
		print("✓ 所有JSON文件格式正确")
		success_count += 1
	else:
		print("✗ JSON文件格式错误")
	
	# 验证3: Resource类功能
	total_tests += 1
	if validate_resource_classes():
		print("✓ Resource类功能正常")
		success_count += 1
	else:
		print("✗ Resource类功能异常")
	
	# 验证4: ConfigManager基础功能
	total_tests += 1
	if validate_config_manager():
		print("✓ ConfigManager基础功能正常")
		success_count += 1
	else:
		print("✗ ConfigManager基础功能异常")
	
	print("\n总体结果: %d/%d 验证通过" % [success_count, total_tests])
	
	if success_count == total_tests:
		print("🎉 配置系统验证完全通过！")
	else:
		print("⚠️ 配置系统存在问题，需要检查。")

func validate_files_exist() -> bool:
	var required_files = [
		"res://data/constants.json",
		"res://data/configs/characters/basic_character.json",
		"res://data/configs/weapons/basic_gun.json",
		"res://data/configs/enemies/basic_enemy.json",
		"res://data/configs/effects/damage_boost.json"
	]
	
	for file_path in required_files:
		if not FileAccess.file_exists(file_path):
			print("  缺失文件: %s" % file_path)
			return false
	
	return true

func validate_json_format() -> bool:
	var json_files = [
		"res://data/constants.json",
		"res://data/configs/characters/basic_character.json",
		"res://data/configs/weapons/basic_gun.json",
		"res://data/configs/enemies/basic_enemy.json",
		"res://data/configs/effects/damage_boost.json"
	]
	
	for file_path in json_files:
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file == null:
			print("  无法打开文件: %s" % file_path)
			return false
		
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result != OK:
			print("  JSON解析失败: %s - %s" % [file_path, json.error_string])
			return false
	
	return true

func validate_resource_classes() -> bool:
	# 测试CharacterConfig
	var char_config = CharacterConfig.new({
		"id": "test",
		"name": "测试",
		"base_stats": {"health": 100}
	})
	
	if not char_config.is_valid():
		print("  CharacterConfig验证失败")
		return false
	
	# 测试WeaponConfig
	var weapon_config = WeaponConfig.new({
		"id": "test",
		"name": "测试",
		"base_stats": {"damage": 10}
	})
	
	if not weapon_config.is_valid():
		print("  WeaponConfig验证失败")
		return false
	
	# 测试EnemyConfig
	var enemy_config = EnemyConfig.new({
		"id": "test",
		"name": "测试",
		"base_stats": {"health": 20}
	})
	
	if not enemy_config.is_valid():
		print("  EnemyConfig验证失败")
		return false
	
	# 测试EffectConfig
	var effect_config = EffectConfig.new({
		"id": "test",
		"name": "测试",
		"effect_type": "stat_modifier",
		"effect_data": {"stat": "damage"}
	})
	
	if not effect_config.is_valid():
		print("  EffectConfig验证失败")
		return false
	
	return true

func validate_config_manager() -> bool:
	# 检查ConfigManager是否存在
	if not has_node("/root/ConfigManager"):
		print("  ConfigManager单例不存在")
		return false
	
	var config_manager = get_node("/root/ConfigManager")
	
	# 检查配置是否已加载
	if config_manager.character_configs.is_empty():
		print("  角色配置未加载")
		return false
	
	if config_manager.weapon_configs.is_empty():
		print("  武器配置未加载")
		return false
	
	if config_manager.enemy_configs.is_empty():
		print("  敌人配置未加载")
		return false
	
	if config_manager.effect_configs.is_empty():
		print("  效果配置未加载")
		return false
	
	if config_manager.game_constants.is_empty():
		print("  游戏常量未加载")
		return false
	
	return true