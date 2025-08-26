extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# 测试配置管理器
	test_config_manager()

func _on_start_pressed():
	print("开始游戏按钮被点击")
	# 游戏场景将在后续任务中实现

func _on_quit_pressed():
	get_tree().quit()

func test_config_manager():
	print("=== 测试配置管理器 ===")
	
	# 测试角色配置
	var char_config = ConfigManager.get_character_config("basic_character")
	if char_config:
		print("角色配置加载成功: %s" % char_config.name)
		print("  生命值: %d" % char_config.get_base_stat("max_health"))
	
	# 测试武器配置
	var weapon_config = ConfigManager.get_weapon_config("basic_gun")
	if weapon_config:
		print("武器配置加载成功: %s" % weapon_config.name)
		print("  伤害: %d" % weapon_config.get_base_stat("damage"))
	
	# 测试常量
	var base_exp = ConfigManager.get_constant("game.base_exp_requirement", 10)
	print("基础经验需求: %d" % base_exp)
	
	print("=== 配置管理器测试完成 ===")