extends SceneTree

func _init():
	# 加载并运行StatsComponent测试
	var gut = preload("res://addons/gut/gut.gd").new()
	
	# 配置GUT
	gut.log_level = 1
	gut.should_exit = true
	gut.should_exit_on_success = true
	
	# 添加测试目录
	gut.add_directory("res://tests")
	gut.set_include_subdirectories(true)
	
	# 只运行StatsComponent测试
	gut.select_script("res://tests/test_stats_component.gd")
	
	# 运行测试
	get_root().add_child(gut)
	gut.test_scripts()