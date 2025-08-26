extends SceneTree

func _init():
	print("=== 修复后的信号系统测试 ===")
	
	var stats_component = StatsComponent.new()
	get_root().add_child(stats_component)
	
	var signal_received = false
	var signal_data = {}
	
	stats_component.stat_changed.connect(func(stat: String, old: float, new: float):
		signal_received = true
		signal_data = {
			"stat_name": stat,
			"old_value": old,
			"new_value": new
		}
		print("✓ 信号触发: " + stat + " 从 " + str(old) + " 变为 " + str(new))
	)
	
	print("\n测试1: 设置新属性")
	print("设置前值: " + str(stats_component.get_stat("new_stat")))
	signal_received = false
	stats_component.set_base_stat("new_stat", 100.0)
	print("设置后值: " + str(stats_component.get_stat("new_stat")))
	print("信号接收: " + str(signal_received))
	if signal_received:
		print("信号数据: " + str(signal_data))
	
	print("\n测试2: 添加修改器")
	signal_received = false
	stats_component.add_additive_modifier("test_mod", "new_stat", 50.0)
	print("添加修改器后值: " + str(stats_component.get_stat("new_stat")))
	print("信号接收: " + str(signal_received))
	if signal_received:
		print("信号数据: " + str(signal_data))
	
	print("\n测试3: 设置相同值（不应触发信号）")
	signal_received = false
	stats_component.set_base_stat("new_stat", 100.0)  # 相同值
	print("信号接收: " + str(signal_received))
	
	print("\n测试4: 添加零值修改器（不应触发信号）")
	signal_received = false
	stats_component.add_additive_modifier("zero_mod", "new_stat", 0.0)
	print("信号接收: " + str(signal_received))
	
	print("\n=== 测试完成 ===")
	quit()