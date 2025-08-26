class_name StatsComponent
extends Node

# 信号定义
signal stat_changed(stat_name: String, old_value: float, new_value: float)
signal modifier_added(modifier_id: String, stat_name: String, value: float, type: String)
signal modifier_removed(modifier_id: String)

# 基础属性字典
@export var base_stats: Dictionary = {}

# 修改器字典 - 存储所有修改器
# 结构: { modifier_id: { stat_name: String, value: float, type: String } }
var modifiers: Dictionary = {}

# 修改器类型常量
enum ModifierType {
	ADDITIVE,    # 加法修改器
	MULTIPLICATIVE  # 乘法修改器
}

func _ready():
	# 确保基础属性有默认值
	if base_stats.is_empty():
		_initialize_default_stats()

# 初始化默认属性
func _initialize_default_stats():
	base_stats = {
		"max_health": 100.0,
		"move_speed": 150.0,
		"damage": 10.0,
		"attack_speed": 1.0,
		"pickup_range": 50.0,
		"experience_gain": 1.0,
		"critical_chance": 0.0,
		"critical_damage": 1.5
	}

# 设置基础属性
func set_base_stat(stat_name: String, value: float):
	var old_base_value = base_stats.get(stat_name, 0.0)
	var old_final_value = get_stat(stat_name)
	
	base_stats[stat_name] = value
	var new_final_value = get_stat(stat_name)
	
	# 只有当最终值真的发生变化时才发射信号
	if not is_equal_approx(old_final_value, new_final_value):
		stat_changed.emit(stat_name, old_final_value, new_final_value)

# 获取基础属性值
func get_base_stat(stat_name: String) -> float:
	return base_stats.get(stat_name, 0.0)

# 获取最终属性值（包含所有修改器）
func get_stat(stat_name: String) -> float:
	return calculate_final_stat(stat_name)

# 添加修改器
func add_modifier(modifier_id: String, stat_name: String, value: float, type: String):
	var old_value = get_stat(stat_name)
	
	# 存储修改器
	modifiers[modifier_id] = {
		"stat_name": stat_name,
		"value": value,
		"type": type
	}
	
	var new_value = get_stat(stat_name)
	
	# 先发射修改器添加信号
	modifier_added.emit(modifier_id, stat_name, value, type)
	
	# 只有当值真的发生变化时才发射属性变化信号
	if not is_equal_approx(old_value, new_value):
		stat_changed.emit(stat_name, old_value, new_value)

# 添加加法修改器的便捷方法
func add_additive_modifier(modifier_id: String, stat_name: String, value: float):
	add_modifier(modifier_id, stat_name, value, "additive")

# 添加乘法修改器的便捷方法
func add_multiplicative_modifier(modifier_id: String, stat_name: String, value: float):
	add_modifier(modifier_id, stat_name, value, "multiplicative")

# 移除修改器
func remove_modifier(modifier_id: String) -> bool:
	if not modifiers.has(modifier_id):
		return false
	
	var modifier = modifiers[modifier_id]
	var stat_name = modifier.stat_name
	var old_value = get_stat(stat_name)
	
	modifiers.erase(modifier_id)
	
	var new_value = get_stat(stat_name)
	
	# 先发射修改器移除信号
	modifier_removed.emit(modifier_id)
	
	# 只有当值真的发生变化时才发射属性变化信号
	if not is_equal_approx(old_value, new_value):
		stat_changed.emit(stat_name, old_value, new_value)
	
	return true

# 检查修改器是否存在
func has_modifier(modifier_id: String) -> bool:
	return modifiers.has(modifier_id)

# 获取修改器信息
func get_modifier(modifier_id: String) -> Dictionary:
	return modifiers.get(modifier_id, {})

# 获取所有影响指定属性的修改器
func get_modifiers_for_stat(stat_name: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for modifier_id in modifiers:
		var modifier = modifiers[modifier_id]
		if modifier.stat_name == stat_name:
			var modifier_info = modifier.duplicate()
			modifier_info["id"] = modifier_id
			result.append(modifier_info)
	return result

# 计算最终属性值
func calculate_final_stat(stat_name: String) -> float:
	var base_value = get_base_stat(stat_name)
	var additive_total = 0.0
	var multiplicative_total = 1.0
	
	# 收集所有影响该属性的修改器
	for modifier_id in modifiers:
		var modifier = modifiers[modifier_id]
		if modifier.stat_name == stat_name:
			match modifier.type:
				"additive":
					additive_total += modifier.value
				"multiplicative":
					multiplicative_total *= modifier.value
				_:
					# 默认为加法修改器
					additive_total += modifier.value
	
	# 计算最终值：(基础值 + 加法修改器) * 乘法修改器
	var final_value = (base_value + additive_total) * multiplicative_total
	
	# 确保某些属性不为负数
	if stat_name in ["max_health", "move_speed", "attack_speed", "pickup_range"]:
		final_value = max(0.0, final_value)
	
	return final_value

# 清除所有修改器
func clear_all_modifiers():
	var affected_stats = {}
	
	# 记录受影响的属性
	for modifier_id in modifiers:
		var modifier = modifiers[modifier_id]
		var stat_name = modifier.stat_name
		if not affected_stats.has(stat_name):
			affected_stats[stat_name] = get_stat(stat_name)
	
	modifiers.clear()
	
	# 发送变化信号
	for stat_name in affected_stats:
		var old_value = affected_stats[stat_name]
		var new_value = get_stat(stat_name)
		if not is_equal_approx(old_value, new_value):
			stat_changed.emit(stat_name, old_value, new_value)

# 清除指定属性的所有修改器
func clear_modifiers_for_stat(stat_name: String):
	var old_value = get_stat(stat_name)
	var modifiers_to_remove = []
	
	# 找到所有影响该属性的修改器
	for modifier_id in modifiers:
		var modifier = modifiers[modifier_id]
		if modifier.stat_name == stat_name:
			modifiers_to_remove.append(modifier_id)
	
	# 移除修改器
	for modifier_id in modifiers_to_remove:
		modifiers.erase(modifier_id)
		modifier_removed.emit(modifier_id)
	
	var new_value = get_stat(stat_name)
	if not is_equal_approx(old_value, new_value):
		stat_changed.emit(stat_name, old_value, new_value)

# 获取所有属性名称
func get_all_stat_names() -> Array[String]:
	var stat_names: Array[String] = []
	
	# 添加基础属性名称
	for stat_name in base_stats:
		if not stat_names.has(stat_name):
			stat_names.append(stat_name)
	
	# 添加修改器影响的属性名称
	for modifier_id in modifiers:
		var modifier = modifiers[modifier_id]
		var stat_name = modifier.stat_name
		if not stat_names.has(stat_name):
			stat_names.append(stat_name)
	
	return stat_names

# 获取所有属性的当前值
func get_all_stats() -> Dictionary:
	var result = {}
	var stat_names = get_all_stat_names()
	
	for stat_name in stat_names:
		result[stat_name] = get_stat(stat_name)
	
	return result

# 从字典批量设置基础属性
func set_base_stats_from_dict(stats_dict: Dictionary):
	for stat_name in stats_dict:
		set_base_stat(stat_name, stats_dict[stat_name])

# 获取修改器统计信息
func get_modifier_stats() -> Dictionary:
	var stats = {
		"total_modifiers": modifiers.size(),
		"additive_modifiers": 0,
		"multiplicative_modifiers": 0,
		"affected_stats": {}
	}
	
	for modifier_id in modifiers:
		var modifier = modifiers[modifier_id]
		var stat_name = modifier.stat_name
		var type = modifier.type
		
		# 统计修改器类型
		if type == "additive":
			stats.additive_modifiers += 1
		elif type == "multiplicative":
			stats.multiplicative_modifiers += 1
		
		# 统计受影响的属性
		if not stats.affected_stats.has(stat_name):
			stats.affected_stats[stat_name] = 0
		stats.affected_stats[stat_name] += 1
	
	return stats