extends GutTest

var health_component: HealthComponent

func before_each():
	health_component = HealthComponent.new()
	add_child(health_component)

func after_each():
	if health_component:
		health_component.queue_free()

func test_initial_health_values():
	# 测试初始值设置
	assert_eq(health_component.max_health, 100.0, "默认最大生命值应为100")
	assert_eq(health_component.current_health, 100.0, "初始当前生命值应等于最大生命值")
	assert_false(health_component.is_dead(), "初始状态不应该死亡")
	assert_true(health_component.is_full_health(), "初始状态应该是满血")

func test_take_damage():
	# 使用watch_signals来测试信号
	watch_signals(health_component)
	
	# 测试正常伤害
	var result = health_component.take_damage(30.0)
	assert_true(result, "正常伤害应该返回true")
	assert_eq(health_component.current_health, 70.0, "受到30点伤害后应剩余70点生命值")
	assert_signal_emitted(health_component, "damage_taken", "应该发出damage_taken信号")
	assert_signal_emitted(health_component, "health_changed", "应该发出health_changed信号")

func test_take_damage_with_invulnerability():
	health_component.invulnerability_duration = 1.0
	
	# 第一次伤害
	health_component.take_damage(20.0)
	assert_eq(health_component.current_health, 80.0, "第一次伤害应该生效")
	assert_true(health_component.invulnerable, "受伤后应该进入无敌状态")
	
	# 无敌状态下的伤害
	var result = health_component.take_damage(20.0)
	assert_false(result, "无敌状态下伤害应该无效")
	assert_eq(health_component.current_health, 80.0, "无敌状态下生命值不应改变")

func test_death():
	watch_signals(health_component)
	
	# 造成致命伤害
	health_component.take_damage(150.0)
	assert_eq(health_component.current_health, 0.0, "致命伤害后生命值应为0")
	assert_true(health_component.is_dead(), "应该处于死亡状态")
	assert_signal_emitted(health_component, "died", "应该发出died信号")
	
	# 死亡后不能再受伤
	var result = health_component.take_damage(10.0)
	assert_false(result, "死亡后不应该能受到伤害")

func test_healing():
	# 先受伤
	health_component.take_damage(40.0)
	assert_eq(health_component.current_health, 60.0, "受伤后生命值应为60")
	
	# 开始监听信号
	watch_signals(health_component)
	
	# 治疗
	var result = health_component.heal(20.0)
	assert_true(result, "治疗应该成功")
	assert_eq(health_component.current_health, 80.0, "治疗后生命值应为80")
	assert_signal_emitted(health_component, "healed", "应该发出healed信号")

func test_heal_to_full():
	health_component.take_damage(50.0)
	health_component.heal_to_full()
	assert_eq(health_component.current_health, health_component.max_health, "完全治疗后应该满血")
	assert_true(health_component.is_full_health(), "完全治疗后is_full_health应该返回true")

func test_max_health_change():
	watch_signals(health_component)
	
	# 增加最大生命值
	health_component.max_health = 150.0
	assert_eq(health_component.max_health, 150.0, "最大生命值应该更新")
	assert_signal_emitted(health_component, "max_health_changed", "应该发出max_health_changed信号")
	
	# 减少最大生命值，当前生命值应该调整
	health_component.max_health = 80.0
	assert_eq(health_component.current_health, 80.0, "当前生命值应该调整到新的最大值")

func test_health_percentage():
	assert_eq(health_component.get_health_percentage(), 1.0, "满血时百分比应为1.0")
	
	health_component.take_damage(25.0)
	assert_eq(health_component.get_health_percentage(), 0.75, "75%生命值时百分比应为0.75")
	
	health_component.take_damage(75.0)
	assert_eq(health_component.get_health_percentage(), 0.0, "死亡时百分比应为0.0")

func test_reset_health():
	# 先让角色死亡
	health_component.take_damage(150.0)
	assert_true(health_component.is_dead(), "应该死亡")
	
	# 重置生命值
	health_component.reset_health()
	assert_false(health_component.is_dead(), "重置后不应该死亡")
	assert_eq(health_component.current_health, health_component.max_health, "重置后应该满血")
	assert_false(health_component.invulnerable, "重置后不应该无敌")

func test_set_invulnerable():
	health_component.set_invulnerable(2.0)
	assert_true(health_component.invulnerable, "设置无敌后应该处于无敌状态")
	
	# 测试无敌状态下不受伤害
	var result = health_component.take_damage(50.0)
	assert_false(result, "无敌状态下不应该受到伤害")

func test_negative_damage_and_heal():
	var initial_health = health_component.current_health
	
	# 负数伤害应该无效
	var result = health_component.take_damage(-10.0)
	assert_false(result, "负数伤害应该无效")
	assert_eq(health_component.current_health, initial_health, "负数伤害不应该改变生命值")
	
	# 负数治疗应该无效
	result = health_component.heal(-10.0)
	assert_false(result, "负数治疗应该无效")
	assert_eq(health_component.current_health, initial_health, "负数治疗不应该改变生命值")