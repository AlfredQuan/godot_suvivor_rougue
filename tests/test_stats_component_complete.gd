extends GutTest

# 完整的StatsComponent GUT测试
class_name TestStatsComponentComplete

var stats_component: StatsComponent

func before_each():
	stats_component = StatsComponent.new()
	add_child(stats_component)
	# 等待_ready()执行
	await get_tree().process_frame

func after_each():
	if stats_component:
		stats_component.queue_free()
		stats_component = null

# ========== 基础功能测试 ==========

func test_default_stats_initialization():
	# 验证默认属性存在且有正确的值
	assert_eq(stats_component.get_base_stat("max_health"), 100.0, "默认生命值应该是100")
	assert_eq(stats_component.get_base_stat("move_speed"), 150.0, "默认移动速度应该是150")
	assert_eq(stats_component.get_base_stat("damage"), 10.0, "默认伤害应该是10")
	assert_eq(stats_component.get_base_stat("attack_speed"), 1.0, "默认攻击速度应该是1")
	assert_eq(stats_component.get_base_stat("pickup_range"), 50.0, "默认拾取范围应该是50")
	assert_eq(stats_component.get_base_stat("experience_gain"), 1.0, "默认经验获取应该是1")
	assert_eq(stats_component.get_base_stat("critical_chance"), 0.0, "默认暴击率应该是0")
	assert_eq(stats_component.get_base_stat("critical_damage"), 1.5, "默认暴击伤害应该是1.5")

func test_base_stat_setting_and_getting():
	# 测试设置和获取基础属性
	stats_component.set_base_stat("test_stat", 42.5)
	assert_eq(stats_component.get_base_stat("test_stat"), 42.5, "基础属性应该正确设置")
	assert_eq(stats_component.get_stat("test_stat"), 42.5, "最终属性应该等于基础属性")
	
	# 测试覆盖现有属性
	stats_component.set_base_stat("damage", 25.0)
	assert_eq(stats_component.get_base_stat("damage"), 25.0, "应该能覆盖现有属性")

func test_nonexistent_stat():
	# 测试获取不存在的属性
	assert_eq(stats_component.get_base_stat("nonexistent"), 0.0, "不存在的属性应该返回0")
	assert_eq(stats_component.get_stat("nonexistent"), 0.0, "不存在的最终属性应该返回0")

# ========== 修改器系统测试 ==========

func test_additive_modifiers():
	stats_component.set_base_stat("damage", 10.0)
	
	# 添加单个加法修改器
	stats_component.add_additive_modifier("weapon", "damage", 5.0)
	assert_eq(stats_component.get_stat("damage"), 15.0, "单个加法修改器应该正确计算")
	
	# 添加多个加法修改器
	stats_component.add_additive_modifier("skill", "damage", 3.0)
	stats_component.add_additive_modifier("buff", "damage", 2.0)
	assert_eq(stats_component.get_stat("damage"), 20.0, "多个加法修改器应该累加")

func test_multiplicative_modifiers():
	stats_component.set_base_stat("damage", 10.0)
	
	# 添加单个乘法修改器
	stats_component.add_multiplicative_modifier("crit", "damage", 1.5)
	assert_eq(stats_component.get_stat("damage"), 15.0, "单个乘法修改器应该正确计算")
	
	# 添加多个乘法修改器
	stats_component.add_multiplicative_modifier("rage", "damage", 1.2)
	stats_component.add_multiplicative_modifier("boost", "damage", 1.1)
	assert_almost_eq(stats_component.get_stat("damage"), 19.8, 0.01, "多个乘法修改器应该相乘")

func test_mixed_modifiers():
	stats_component.set_base_stat("damage", 10.0)
	
	# 添加加法和乘法修改器
	stats_component.add_additive_modifier("weapon", "damage", 5.0)
	stats_component.add_additive_modifier("skill", "damage", 3.0)
	stats_component.add_multiplicative_modifier("crit", "damage", 2.0)
	stats_component.add_multiplicative_modifier("rage", "damage", 1.5)
	
	# 计算: (10 + 5 + 3) * 2.0 * 1.5 = 18 * 3 = 54
	assert_eq(stats_component.get_stat("damage"), 54.0, "混合修改器应该按正确顺序计算")

func test_zero_value_modifiers():
	stats_component.set_base_stat("damage", 10.0)
	
	# 添加零值修改器
	stats_component.add_additive_modifier("zero_add", "damage", 0.0)
	stats_component.add_multiplicative_modifier("zero_mult", "damage", 1.0)
	
	assert_eq(stats_component.get_stat("damage"), 10.0, "零值修改器不应该改变结果")

func test_negative_modifiers():
	stats_component.set_base_stat("damage", 10.0)
	
	# 添加负值加法修改器
	stats_component.add_additive_modifier("debuff", "damage", -3.0)
	assert_eq(stats_component.get_stat("damage"), 7.0, "负值加法修改器应该减少属性")
	
	# 添加小于1的乘法修改器
	stats_component.add_multiplicative_modifier("weakness", "damage", 0.5)
	assert_eq(stats_component.get_stat("damage"), 3.5, "小于1的乘法修改器应该减少属性")

# ========== 修改器管理测试 ==========

func test_modifier_existence():
	stats_component.add_additive_modifier("test_mod", "damage", 5.0)
	
	assert_true(stats_component.has_modifier("test_mod"), "应该检测到修改器存在")
	assert_false(stats_component.has_modifier("nonexistent"), "不存在的修改器应该返回false")

func test_get_modifier_info():
	stats_component.add_additive_modifier("test_mod", "damage", 5.0)
	
	var modifier_info = stats_component.get_modifier("test_mod")
	assert_eq(modifier_info.stat_name, "damage", "修改器信息应该包含正确的属性名")
	assert_eq(modifier_info.value, 5.0, "修改器信息应该包含正确的值")
	assert_eq(modifier_info.type, "additive", "修改器信息应该包含正确的类型")
	
	# 测试不存在的修改器
	var empty_info = stats_component.get_modifier("nonexistent")
	assert_true(empty_info.is_empty(), "不存在的修改器应该返回空字典")

func test_remove_modifier():
	stats_component.set_base_stat("damage", 10.0)
	stats_component.add_additive_modifier("temp_bonus", "damage", 5.0)
	
	assert_eq(stats_component.get_stat("damage"), 15.0, "添加修改器后值应该改变")
	
	# 移除修改器
	var removed = stats_component.remove_modifier("temp_bonus")
	assert_true(removed, "应该成功移除修改器")
	assert_eq(stats_component.get_stat("damage"), 10.0, "移除修改器后值应该恢复")
	assert_false(stats_component.has_modifier("temp_bonus"), "修改器应该被移除")
	
	# 尝试移除不存在的修改器
	var not_removed = stats_component.remove_modifier("nonexistent")
	assert_false(not_removed, "移除不存在的修改器应该返回false")

func test_get_modifiers_for_stat():
	stats_component.add_additive_modifier("add1", "damage", 5.0)
	stats_component.add_multiplicative_modifier("mult1", "damage", 1.5)
	stats_component.add_additive_modifier("add2", "move_speed", 10.0)
	
	var damage_modifiers = stats_component.get_modifiers_for_stat("damage")
	assert_eq(damage_modifiers.size(), 2, "damage属性应该有2个修改器")
	
	var speed_modifiers = stats_component.get_modifiers_for_stat("move_speed")
	assert_eq(speed_modifiers.size(), 1, "move_speed属性应该有1个修改器")
	
	var empty_modifiers = stats_component.get_modifiers_for_stat("nonexistent")
	assert_eq(empty_modifiers.size(), 0, "不存在的属性应该返回空数组")

func test_clear_all_modifiers():
	stats_component.set_base_stat("damage", 10.0)
	stats_component.set_base_stat("move_speed", 100.0)
	
	stats_component.add_additive_modifier("damage_bonus", "damage", 5.0)
	stats_component.add_multiplicative_modifier("speed_mult", "move_speed", 1.5)
	
	assert_eq(stats_component.get_stat("damage"), 15.0, "清除前damage应该有修改器效果")
	assert_eq(stats_component.get_stat("move_speed"), 150.0, "清除前move_speed应该有修改器效果")
	
	stats_component.clear_all_modifiers()
	
	assert_eq(stats_component.get_stat("damage"), 10.0, "清除后damage应该回到基础值")
	assert_eq(stats_component.get_stat("move_speed"), 100.0, "清除后move_speed应该回到基础值")
	assert_false(stats_component.has_modifier("damage_bonus"), "所有修改器应该被清除")
	assert_false(stats_component.has_modifier("speed_mult"), "所有修改器应该被清除")

func test_clear_modifiers_for_stat():
	stats_component.set_base_stat("damage", 10.0)
	stats_component.set_base_stat("move_speed", 100.0)
	
	stats_component.add_additive_modifier("damage_add", "damage", 5.0)
	stats_component.add_multiplicative_modifier("damage_mult", "damage", 2.0)
	stats_component.add_additive_modifier("speed_add", "move_speed", 20.0)
	
	# 清除damage的修改器
	stats_component.clear_modifiers_for_stat("damage")
	
	assert_eq(stats_component.get_stat("damage"), 10.0, "清除后damage应该回到基础值")
	assert_eq(stats_component.get_stat("move_speed"), 120.0, "move_speed不应该受影响")
	assert_false(stats_component.has_modifier("damage_add"), "damage修改器应该被清除")
	assert_false(stats_component.has_modifier("damage_mult"), "damage修改器应该被清除")
	assert_true(stats_component.has_modifier("speed_add"), "其他属性修改器应该保留")

# ========== 负值保护测试 ==========

func test_negative_value_protection():
	# 测试受保护的属性
	var protected_stats = ["max_health", "move_speed", "attack_speed", "pickup_range"]
	
	for stat_name in protected_stats:
		stats_component.set_base_stat(stat_name, 100.0)
		stats_component.add_additive_modifier("debuff", stat_name, -150.0)
		
		assert_eq(stats_component.get_stat(stat_name), 0.0, stat_name + " 不应该小于0")
		stats_component.remove_modifier("debuff")
	
	# 测试不受保护的属性
	stats_component.set_base_stat("damage", 10.0)
	stats_component.add_additive_modifier("debuff", "damage", -15.0)
	assert_eq(stats_component.get_stat("damage"), -5.0, "damage可以为负数")

# ========== 信号系统测试 ==========

func test_stat_changed_signal():
	var signal_data = {}
	
	stats_component.stat_changed.connect(func(stat: String, old: float, new: float):
		signal_data["received"] = true
		signal_data["stat_name"] = stat
		signal_data["old_value"] = old
		signal_data["new_value"] = new
	)
	
	# 测试设置新属性
	stats_component.set_base_stat("test_stat", 100.0)
	
	assert_true(signal_data.get("received", false), "应该发射stat_changed信号")
	assert_eq(signal_data.get("stat_name", ""), "test_stat", "信号应该包含正确的属性名")
	assert_eq(signal_data.get("old_value", -1.0), 0.0, "信号应该包含正确的旧值")
	assert_eq(signal_data.get("new_value", -1.0), 100.0, "信号应该包含正确的新值")

func test_stat_changed_signal_with_modifiers():
	var signal_data = {}
	
	stats_component.stat_changed.connect(func(stat: String, old: float, new: float):
		signal_data["received"] = true
		signal_data["old_value"] = old
		signal_data["new_value"] = new
	)
	
	stats_component.set_base_stat("damage", 10.0)
	signal_data.clear()  # 清除设置基础属性的信号
	
	# 添加修改器应该触发信号
	stats_component.add_additive_modifier("bonus", "damage", 5.0)
	
	assert_true(signal_data.get("received", false), "添加修改器应该发射信号")
	assert_eq(signal_data.get("old_value", -1.0), 10.0, "信号应该包含修改前的值")
	assert_eq(signal_data.get("new_value", -1.0), 15.0, "信号应该包含修改后的值")

func test_modifier_signals():
	var add_signal_data = {}
	var remove_signal_data = {}
	
	stats_component.modifier_added.connect(func(id: String, stat: String, val: float, type: String):
		add_signal_data["received"] = true
		add_signal_data["id"] = id
		add_signal_data["stat"] = stat
		add_signal_data["value"] = val
		add_signal_data["type"] = type
	)
	
	stats_component.modifier_removed.connect(func(id: String):
		remove_signal_data["received"] = true
		remove_signal_data["id"] = id
	)
	
	# 测试添加修改器信号
	stats_component.add_additive_modifier("test_mod", "damage", 5.0)
	
	assert_true(add_signal_data.get("received", false), "应该发射modifier_added信号")
	assert_eq(add_signal_data.get("id", ""), "test_mod", "信号应该包含正确的修改器ID")
	assert_eq(add_signal_data.get("stat", ""), "damage", "信号应该包含正确的属性名")
	assert_eq(add_signal_data.get("value", -1.0), 5.0, "信号应该包含正确的值")
	assert_eq(add_signal_data.get("type", ""), "additive", "信号应该包含正确的类型")
	
	# 测试移除修改器信号
	stats_component.remove_modifier("test_mod")
	
	assert_true(remove_signal_data.get("received", false), "应该发射modifier_removed信号")
	assert_eq(remove_signal_data.get("id", ""), "test_mod", "信号应该包含正确的修改器ID")

func test_signal_not_fired_for_same_value():
	var signal_count = 0
	
	stats_component.stat_changed.connect(func(_stat: String, _old: float, _new: float):
		signal_count += 1
	)
	
	stats_component.set_base_stat("damage", 10.0)
	var initial_count = signal_count
	
	# 设置相同值不应该触发信号
	stats_component.set_base_stat("damage", 10.0)
	assert_eq(signal_count, initial_count, "设置相同值不应该触发信号")
	
	# 添加零值修改器不应该触发信号
	stats_component.add_additive_modifier("zero", "damage", 0.0)
	assert_eq(signal_count, initial_count, "添加零值修改器不应该触发属性变化信号")

# ========== 批量操作测试 ==========

func test_set_base_stats_from_dict():
	var stats_dict = {
		"max_health": 200.0,
		"move_speed": 180.0,
		"damage": 15.0,
		"custom_stat": 42.0
	}
	
	stats_component.set_base_stats_from_dict(stats_dict)
	
	assert_eq(stats_component.get_base_stat("max_health"), 200.0, "批量设置应该更新max_health")
	assert_eq(stats_component.get_base_stat("move_speed"), 180.0, "批量设置应该更新move_speed")
	assert_eq(stats_component.get_base_stat("damage"), 15.0, "批量设置应该更新damage")
	assert_eq(stats_component.get_base_stat("custom_stat"), 42.0, "批量设置应该添加新属性")

func test_get_all_stat_names():
	stats_component.set_base_stat("custom1", 10.0)
	stats_component.add_additive_modifier("mod1", "custom2", 5.0)
	
	var stat_names = stats_component.get_all_stat_names()
	
	assert_true(stat_names.has("max_health"), "应该包含默认属性")
	assert_true(stat_names.has("custom1"), "应该包含自定义基础属性")
	assert_true(stat_names.has("custom2"), "应该包含修改器影响的属性")

func test_get_all_stats():
	stats_component.set_base_stat("damage", 10.0)
	stats_component.add_additive_modifier("bonus", "damage", 5.0)
	
	var all_stats = stats_component.get_all_stats()
	
	assert_true(all_stats.has("damage"), "应该包含damage属性")
	assert_eq(all_stats["damage"], 15.0, "应该返回包含修改器效果的最终值")
	assert_true(all_stats.has("max_health"), "应该包含默认属性")

func test_get_modifier_stats():
	stats_component.add_additive_modifier("add1", "damage", 5.0)
	stats_component.add_additive_modifier("add2", "damage", 3.0)
	stats_component.add_multiplicative_modifier("mult1", "damage", 1.5)
	stats_component.add_additive_modifier("add3", "move_speed", 10.0)
	
	var modifier_stats = stats_component.get_modifier_stats()
	
	assert_eq(modifier_stats.total_modifiers, 4, "总修改器数量应该是4")
	assert_eq(modifier_stats.additive_modifiers, 3, "加法修改器数量应该是3")
	assert_eq(modifier_stats.multiplicative_modifiers, 1, "乘法修改器数量应该是1")
	assert_eq(modifier_stats.affected_stats["damage"], 3, "damage属性应该有3个修改器")
	assert_eq(modifier_stats.affected_stats["move_speed"], 1, "move_speed属性应该有1个修改器")

# ========== 边界情况和错误处理测试 ==========

func test_large_numbers():
	var large_number = 999999.0
	stats_component.set_base_stat("big_stat", large_number)
	stats_component.add_additive_modifier("big_add", "big_stat", large_number)
	
	assert_eq(stats_component.get_stat("big_stat"), large_number * 2, "应该正确处理大数值")

func test_very_small_numbers():
	var small_number = 0.001
	stats_component.set_base_stat("small_stat", small_number)
	stats_component.add_additive_modifier("small_add", "small_stat", small_number)
	
	assert_almost_eq(stats_component.get_stat("small_stat"), small_number * 2, 0.0001, "应该正确处理小数值")

func test_floating_point_precision():
	stats_component.set_base_stat("precision_test", 0.1)
	stats_component.add_additive_modifier("add1", "precision_test", 0.2)
	stats_component.add_additive_modifier("add2", "precision_test", 0.3)
	
	# 0.1 + 0.2 + 0.3 = 0.6，但浮点数可能有精度问题
	assert_almost_eq(stats_component.get_stat("precision_test"), 0.6, 0.0001, "应该正确处理浮点数精度")

func test_modifier_overwrite():
	stats_component.set_base_stat("damage", 10.0)
	stats_component.add_additive_modifier("test_mod", "damage", 5.0)
	
	assert_eq(stats_component.get_stat("damage"), 15.0, "初始修改器应该生效")
	
	# 用相同ID添加新修改器应该覆盖旧的
	stats_component.add_additive_modifier("test_mod", "damage", 8.0)
	
	assert_eq(stats_component.get_stat("damage"), 18.0, "新修改器应该覆盖旧的")
	assert_eq(stats_component.get_modifiers_for_stat("damage").size(), 1, "应该只有一个修改器")

func test_complex_calculation_scenario():
	# 复杂的计算场景
	stats_component.set_base_stat("complex_stat", 20.0)
	
	# 添加多个不同类型的修改器
	stats_component.add_additive_modifier("base_bonus", "complex_stat", 10.0)
	stats_component.add_additive_modifier("skill_bonus", "complex_stat", 5.0)
	stats_component.add_additive_modifier("item_bonus", "complex_stat", 3.0)
	stats_component.add_multiplicative_modifier("crit_mult", "complex_stat", 1.5)
	stats_component.add_multiplicative_modifier("buff_mult", "complex_stat", 1.2)
	stats_component.add_multiplicative_modifier("final_mult", "complex_stat", 1.1)
	
	# 计算: (20 + 10 + 5 + 3) * 1.5 * 1.2 * 1.1 = 38 * 1.98 = 75.24
	var expected = (20.0 + 10.0 + 5.0 + 3.0) * 1.5 * 1.2 * 1.1
	assert_almost_eq(stats_component.get_stat("complex_stat"), expected, 0.01, "复杂计算应该正确")