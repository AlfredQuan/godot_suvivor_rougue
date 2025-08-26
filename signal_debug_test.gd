extends SceneTree

func _init():
	print("=== 信号系统调试测试 ===")
	
	var stats_component = StatsComponent.new()
	get_root().add_child(stats_component)
	
	var signal_count = 0
	var last_signal_data = {}
	
	stats_component.stat_changed.connect(func(stat: String, old: float, new: float):
		signal_count += 1
		last_signal_data = {
			"stat_name": stat,
			"old_value": old,
			"new_value": new
		}
		print("信号 #" + str(signal_count) + ": " + stat + " 从 " + str(old) + " 变为 " + str(new))
	)
	
	print("\n1. 测试设置新属性:")
	print("设置前 test_stat 值: " + str(stats_component.get_stat("test_stat")))
	print("设置前 base_stats 包含 test_stat: " + str(stats_component.base_stats.has("test_stat")))
	
	stats_component.set_base_stat("test_stat", 100.0)
	
	print("设置后 test_stat 值: " + str(stats_component.get_stat("test_stat")))
	print("信号触发次数: " + str(signal_count))
	print("最后信号数据: " + str(last_signal_data))
	
	print("\n2. 测试修改现有属性:")
	signal_count = 0
	stats_component.set_base_stat("test_stat", 150.0)
	
	print("修改后 test_stat 值: " + str(stats_component.get_stat("test_stat")))
	print("信号触发次数: " + str(signal_count))
	print("最后信号数据: " + str(last_signal_data))
	
	print("\n3. 测试添加修改器:")
	signal_count = 0
	stats_component.add_additive_modifier("test_mod", "test_stat", 50.0)
	
	print("添加修改器后 test_stat 值: " + str(stats_component.get_stat("test_stat")))
	print("信号触发次数: " + str(signal_count))
	print("最后信号数据: " + str(last_signal_data))
	
	print("\n4. 测试设置相同值:")
	signal_count = 0
	stats_component.set_base_stat("test_stat", 150.0)  # 设置相同值
	
	print("设置相同值后信号触发次数: " + str(signal_count))
	
	quit()