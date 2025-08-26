extends SceneTree

# 简单的测试运行器，用于验证配置系统
func _init():
	print("=== 开始配置系统测试 ===")
	
	# 手动初始化ConfigManager（因为我们不在正常的游戏循环中）
	var config_manager = preload("res://scripts/managers/ConfigManager.gd").new()
	config_manager.name = "ConfigManager"
	root.add_child(config_manager)
	
	# 等待一帧让ConfigManager初始化
	await process_frame
	
	run_tests()
	quit()

func run_tests():
	var passed = 0
	var total = 0
	
	# 测试角色配置加载
	total += 1
	var char_config = ConfigManager.get_character_config("basic_character")
	if char_config and char_config.is_valid():
		print("✓ 角色配置加载测试通过")
		passed += 1
	else:
		print("✗ 角色配置加载测试失败")
	
	# 测试武器配置加载
	total += 1
	var weapon_config = ConfigManager.get_weapon_config("basic_gun")
	if weapon_config and weapon_config.is_valid():
		print("✓ 武器配置加载测试通过")
		passed += 1
	else:
		print("✗ 武器配置加载测试失败")
	
	# 测试敌人配置加载
	total += 1
	var enemy_config = ConfigManager.get_enemy_config("basic_enemy")
	if enemy_config and enemy_config.is_valid():
		print("✓ 敌人配置加载测试通过")
		passed += 1
	else:
		print("✗ 敌人配置加载测试失败")
	
	# 测试效果配置加载
	total += 1
	var effect_config = ConfigManager.get_effect_config("damage_boost")
	if effect_config and effect_config.is_valid():
		print("✓ 效果配置加载测试通过")
		passed += 1
	else:
		print("✗ 效果配置加载测试失败")
	
	# 测试常量加载
	total += 1
	var base_exp = ConfigManager.get_constant("game.base_exp_requirement")
	if base_exp == 10:
		print("✓ 常量加载测试通过")
		passed += 1
	else:
		print("✗ 常量加载测试失败")
	
	# 测试配置验证
	total += 1
	var valid_config = CharacterConfig.new({
		"id": "test",
		"name": "测试",
		"base_stats": {"health": 100}
	})
	var invalid_config = CharacterConfig.new({})
	if valid_config.is_valid() and not invalid_config.is_valid():
		print("✓ 配置验证测试通过")
		passed += 1
	else:
		print("✗ 配置验证测试失败")
	
	print("=== 测试结果: %d/%d 通过 ===" % [passed, total])
	
	if passed == total:
		print("🎉 所有测试通过！配置系统工作正常。")
	else:
		print("❌ 有测试失败，请检查配置系统。")