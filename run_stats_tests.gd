extends SceneTree

func _init():
	print("=== 运行StatsComponent完整测试 ===")
	
	# 创建GUT实例
	var gut = preload("res://addons/gut/gut.gd").new()
	
	# 配置GUT
	gut.set_log_level(1)
	gut.set_should_exit(true)
	gut.set_should_exit_on_success(true)
	
	# 只运行我们的完整测试
	gut.select_script("res://tests/test_stats_component_complete.gd")
	
	# 添加到场景树并运行
	get_root().add_child(gut)
	gut.test_scripts()