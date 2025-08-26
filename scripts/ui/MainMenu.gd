extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# 等待一帧确保ConfigManager初始化完成
	await get_tree().process_frame
	
	# 测试配置管理器
	test_config_manager()
	
	# 自动退出（用于测试）
	await get_tree().create_timer(1.0).timeout
	print("测试完成，自动退出")
	get_tree().quit()

func _on_start_pressed():
	print("开始游戏按钮被点击")
	# 游戏场景将在后续任务中实现

func _on_quit_pressed():
	get_tree().quit()

func test_config_manager():
	print("=== 配置管理器详细测试 ===")
	
	var passed = 0
	var total = 0
	
	# 测试1: 角色配置
	total += 1
	var char_config = ConfigManager.get_character_config("basic_character")
	if char_config and char_config.is_valid():
		print("✓ 角色配置加载成功: %s (生命值: %d)" % [char_config.name, char_config.get_base_stat("max_health")])
		passed += 1
	else:
		print("✗ 角色配置加载失败")
	
	# 测试2: 武器配置
	total += 1
	var weapon_config = ConfigManager.get_weapon_config("basic_gun")
	if weapon_config and weapon_config.is_valid():
		print("✓ 武器配置加载成功: %s (伤害: %d)" % [weapon_config.name, weapon_config.get_base_stat("damage")])
		passed += 1
	else:
		print("✗ 武器配置加载失败")
	
	# 测试3: 敌人配置
	total += 1
	var enemy_config = ConfigManager.get_enemy_config("basic_enemy")
	if enemy_config and enemy_config.is_valid():
		print("✓ 敌人配置加载成功: %s (生命值: %d)" % [enemy_config.name, enemy_config.get_base_stat("max_health")])
		passed += 1
	else:
		print("✗ 敌人配置加载失败")
	
	# 测试4: 效果配置
	total += 1
	var effect_config = ConfigManager.get_effect_config("damage_boost")
	if effect_config and effect_config.is_valid():
		print("✓ 效果配置加载成功: %s (稀有度: %s)" % [effect_config.name, effect_config.rarity])
		passed += 1
	else:
		print("✗ 效果配置加载失败")
	
	# 测试5: 常量
	total += 1
	var base_exp = ConfigManager.get_constant("game.base_exp_requirement")
	if base_exp == 10:
		print("✓ 常量加载成功: 基础经验需求 = %d" % base_exp)
		passed += 1
	else:
		print("✗ 常量加载失败: 期望10，实际%s" % str(base_exp))
	
	# 测试6: 错误处理
	total += 1
	var invalid_config = ConfigManager.get_character_config("nonexistent")
	if invalid_config == null:
		print("✓ 错误处理正常: 不存在的配置返回null")
		passed += 1
	else:
		print("✗ 错误处理失败: 不存在的配置应该返回null")
	
	# 测试7: 配置验证
	total += 1
	var test_config = CharacterConfig.new({
		"id": "test",
		"name": "测试",
		"base_stats": {"max_health": 100}
	})
	var empty_config = CharacterConfig.new({})
	if test_config.is_valid() and not empty_config.is_valid():
		print("✓ 配置验证正常")
		passed += 1
	else:
		print("✗ 配置验证失败")
	
	# 显示所有配置ID
	print("\n已加载的配置:")
	print("  角色: %s" % str(ConfigManager.get_all_character_ids()))
	print("  武器: %s" % str(ConfigManager.get_all_weapon_ids()))
	print("  敌人: %s" % str(ConfigManager.get_all_enemy_ids()))
	print("  效果: %s" % str(ConfigManager.get_all_effect_ids()))
	
	# 显示加载错误（如果有）
	if ConfigManager.load_errors.size() > 0:
		print("\n加载错误:")
		for error in ConfigManager.load_errors:
			print("  - %s" % error)
	
	print("\n=== 测试结果: %d/%d 通过 ===" % [passed, total])
	
	if passed == total:
		print("🎉 所有测试通过！配置系统工作正常。")
	else:
		print("❌ 有 %d 个测试失败。" % (total - passed))