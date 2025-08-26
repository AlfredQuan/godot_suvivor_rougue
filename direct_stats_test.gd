extends SceneTree

func _init():
	print("=== 直接运行StatsComponent测试 ===")
	
	var stats_component = StatsComponent.new()
	get_root().add_child(stats_component)
	
	var passed = 0
	var total = 0
	
	# 测试1: 基础属性设置
	total += 1
	stats_component.set_base_stat("damage", 10.0)
	if stats_component.get_base_stat("damage") == 10.0:
		print("✓ 测试1通过: 基础属性设置")
		passed += 1
	else:
		print("✗ 测试1失败: 基础属性设置")
	
	# 测试2: 加法修改器
	total += 1
	stats_component.add_additive_modifier("weapon", "damage", 5.0)
	if stats_component.get_stat("damage") == 15.0:
		print("✓ 测试2通过: 加法修改器")
		passed += 1
	else:
		print("✗ 测试2失败: 加法修改器，期望15.0，实际" + str(stats_component.get_stat("damage")))
	
	# 测试3: 乘法修改器
	total += 1
	stats_component.clear_all_modifiers()
	stats_component.set_base_stat("damage", 10.0)
	stats_component.add_multiplicative_modifier("crit", "damage", 2.0)
	if stats_component.get_stat("damage") == 20.0:
		print("✓ 测试3通过: 乘法修改器")
		passed += 1
	else:
		print("✗ 测试3失败: 乘法修改器，期望20.0，实际" + str(stats_component.get_stat("damage")))
	
	# 测试4: 混合修改器
	total += 1
	stats_component.clear_all_modifiers()
	stats_component.set_base_stat("damage", 10.0)
	stats_component.add_additive_modifier("weapon", "damage", 5.0)
	stats_component.add_multiplicative_modifier("crit", "damage", 2.0)
	if stats_component.get_stat("damage") == 30.0:  # (10+5)*2
		print("✓ 测试4通过: 混合修改器")
		passed += 1
	else:
		print("✗ 测试4失败: 混合修改器，期望30.0，实际" + str(stats_component.get_stat("damage")))
	
	# 测试5: 修改器移除
	total += 1
	stats_component.remove_modifier("weapon")
	if stats_component.get_stat("damage") == 20.0:  # 10*2
		print("✓ 测试5通过: 修改器移除")
		passed += 1
	else:
		print("✗ 测试5失败: 修改器移除，期望20.0，实际" + str(stats_component.get_stat("damage")))
	
	# 测试6: 信号系统
	total += 1
	var signal_received = false
	var signal_old = 0.0
	var signal_new = 0.0
	
	stats_component.stat_changed.connect(func(stat: String, old: float, new: float):
		signal_received = true
		signal_old = old
		signal_new = new
	)
	
	stats_component.clear_all_modifiers()
	stats_component.set_base_stat("test_stat", 100.0)
	
	if signal_received and signal_old == 0.0 and signal_new == 100.0:
		print("✓ 测试6通过: 信号系统")
		passed += 1
	else:
		print("✗ 测试6失败: 信号系统，接收:" + str(signal_received) + "，旧值:" + str(signal_old) + "，新值:" + str(signal_new))
	
	# 测试7: 负值保护
	total += 1
	stats_component.clear_all_modifiers()
	stats_component.set_base_stat("max_health", 100.0)
	stats_component.add_additive_modifier("debuff", "max_health", -150.0)
	if stats_component.get_stat("max_health") == 0.0:
		print("✓ 测试7通过: 负值保护")
		passed += 1
	else:
		print("✗ 测试7失败: 负值保护，期望0.0，实际" + str(stats_component.get_stat("max_health")))
	
	# 测试8: 修改器信息获取
	total += 1
	stats_component.clear_all_modifiers()
	stats_component.add_additive_modifier("test_mod", "damage", 5.0)
	var mod_info = stats_component.get_modifier("test_mod")
	if mod_info.has("stat_name") and mod_info.stat_name == "damage" and mod_info.value == 5.0:
		print("✓ 测试8通过: 修改器信息获取")
		passed += 1
	else:
		print("✗ 测试8失败: 修改器信息获取")
	
	# 测试9: 批量属性设置
	total += 1
	var batch_stats = {"custom1": 42.0, "custom2": 84.0}
	stats_component.set_base_stats_from_dict(batch_stats)
	if stats_component.get_base_stat("custom1") == 42.0 and stats_component.get_base_stat("custom2") == 84.0:
		print("✓ 测试9通过: 批量属性设置")
		passed += 1
	else:
		print("✗ 测试9失败: 批量属性设置")
	
	# 测试10: 复杂计算
	total += 1
	stats_component.clear_all_modifiers()
	stats_component.set_base_stat("complex", 10.0)
	stats_component.add_additive_modifier("add1", "complex", 5.0)
	stats_component.add_additive_modifier("add2", "complex", 3.0)
	stats_component.add_multiplicative_modifier("mult1", "complex", 1.5)
	stats_component.add_multiplicative_modifier("mult2", "complex", 1.2)
	# (10+5+3) * 1.5 * 1.2 = 18 * 1.8 = 32.4
	var expected = 32.4
	var actual = stats_component.get_stat("complex")
	if abs(actual - expected) < 0.01:
		print("✓ 测试10通过: 复杂计算")
		passed += 1
	else:
		print("✗ 测试10失败: 复杂计算，期望" + str(expected) + "，实际" + str(actual))
	
	print("\n=== 测试结果: " + str(passed) + "/" + str(total) + " 通过 ===")
	
	if passed == total:
		print("🎉 所有测试通过！StatsComponent工作正常。")
	else:
		print("⚠️  有 " + str(total - passed) + " 个测试失败。")
	
	quit()