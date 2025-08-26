extends "res://addons/gut/test.gd"

# ConfigManager单元测试

func before_each():
	# 确保ConfigManager已初始化
	if not ConfigManager.character_configs.has("basic_character"):
		ConfigManager.load_all_configs()

func test_character_config_loading():
	# 测试角色配置加载
	var config = ConfigManager.get_character_config("basic_character")
	assert_not_null(config, "角色配置应该能够加载")
	assert_eq(config.id, "basic_character", "角色ID应该正确")
	assert_eq(config.name, "基础角色", "角色名称应该正确")
	assert_true(config.is_valid(), "角色配置应该有效")
	assert_eq(config.get_base_stat("max_health"), 100, "生命值应该正确")

func test_weapon_config_loading():
	# 测试武器配置加载
	var config = ConfigManager.get_weapon_config("basic_gun")
	assert_not_null(config, "武器配置应该能够加载")
	assert_eq(config.id, "basic_gun", "武器ID应该正确")
	assert_eq(config.name, "基础枪械", "武器名称应该正确")
	assert_true(config.is_valid(), "武器配置应该有效")
	assert_eq(config.get_base_stat("damage"), 10, "伤害值应该正确")
	assert_true(config.can_evolve(), "武器应该可以进化")

func test_enemy_config_loading():
	# 测试敌人配置加载
	var config = ConfigManager.get_enemy_config("basic_enemy")
	assert_not_null(config, "敌人配置应该能够加载")
	assert_eq(config.id, "basic_enemy", "敌人ID应该正确")
	assert_eq(config.name, "基础敌人", "敌人名称应该正确")
	assert_true(config.is_valid(), "敌人配置应该有效")
	assert_eq(config.get_base_stat("max_health"), 20, "生命值应该正确")

func test_effect_config_loading():
	# 测试效果配置加载
	var config = ConfigManager.get_effect_config("damage_boost")
	assert_not_null(config, "效果配置应该能够加载")
	assert_eq(config.id, "damage_boost", "效果ID应该正确")
	assert_eq(config.name, "伤害提升", "效果名称应该正确")
	assert_true(config.is_valid(), "效果配置应该有效")
	assert_eq(config.rarity, "common", "稀有度应该正确")

func test_constants_loading():
	# 测试常量加载
	var base_exp = ConfigManager.get_constant("game.base_exp_requirement")
	assert_not_null(base_exp, "常量应该能够加载")
	assert_eq(base_exp, 10, "基础经验需求应该正确")
	
	var max_enemies = ConfigManager.get_constant("performance.max_enemies")
	assert_eq(max_enemies, 200, "最大敌人数量应该正确")

func test_invalid_config_handling():
	# 测试无效配置处理
	var invalid_char = ConfigManager.get_character_config("nonexistent")
	assert_null(invalid_char, "不存在的配置应该返回null")
	
	var invalid_constant = ConfigManager.get_constant("nonexistent.path", "default")
	assert_eq(invalid_constant, "default", "不存在的常量应该返回默认值")

func test_config_validation():
	# 测试配置验证
	var char_config = CharacterConfig.new({
		"id": "test",
		"name": "测试角色",
		"base_stats": {"max_health": 100}
	})
	assert_true(char_config.is_valid(), "有效配置应该通过验证")
	
	var invalid_config = CharacterConfig.new({})
	assert_false(invalid_config.is_valid(), "无效配置应该不通过验证")

func test_effect_rarity_weights():
	# 测试效果稀有度权重
	var common_effect = EffectConfig.new({"rarity": "common"})
	var rare_effect = EffectConfig.new({"rarity": "rare"})
	var epic_effect = EffectConfig.new({"rarity": "epic"})
	var legendary_effect = EffectConfig.new({"rarity": "legendary"})
	
	assert_eq(common_effect.get_rarity_weight(), 1.0, "普通稀有度权重应该是1.0")
	assert_eq(rare_effect.get_rarity_weight(), 0.3, "稀有稀有度权重应该是0.3")
	assert_eq(epic_effect.get_rarity_weight(), 0.1, "史诗稀有度权重应该是0.1")
	assert_eq(legendary_effect.get_rarity_weight(), 0.05, "传说稀有度权重应该是0.05")