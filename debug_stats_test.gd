extends SceneTree

func _init():
	print("=== 调试StatsComponent信号 ===")
	
	var stats_component = StatsComponent.new()
	get_root().add_child(stats_component)
	
	# 设置信号监听
	var signal_data = {}
	stats_component.stat_changed.connect(func(stat: String, old: float, new: float):
		print("信号触发: stat=" + stat + ", old=" + str(old) + ", new=" + str(new))
		signal_data["received"] = true
		signal_data["stat_name"] = stat
		signal_data["old_val"] = old
		signal_data["new_val"] = new
	)
	
	print("1. 设置基础属性前的值: " + str(stats_component.get_stat("test_stat")))
	
	# 设置基础属性
	stats_component.set_base_stat("test_stat", 100.0)
	print("2. 设置基础属性后的值: " + str(stats_component.get_stat("test_stat")))
	print("3. 信号数据: " + str(signal_data))
	
	# 清空信号数据
	signal_data.clear()
	
	# 添加修改器
	print("4. 添加修改器前的值: " + str(stats_component.get_stat("test_stat")))
	stats_component.add_additive_modifier("test_mod", "test_stat", 50.0)
	print("5. 添加修改器后的值: " + str(stats_component.get_stat("test_stat")))
	print("6. 信号数据: " + str(signal_data))
	
	quit()