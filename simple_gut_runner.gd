extends SceneTree

func _init():
	print("=== 开始GUT测试 ===")
	
	# 直接运行GUT命令行工具
	var gut_cmdln = preload("res://addons/gut/gut_cmdln.gd").new()
	
	# 设置参数
	var args = [
		"-gtest=tests/test_stats_component_complete.gd"
	]
	
	# 运行测试
	gut_cmdln.run_tests(args)
	
	quit()