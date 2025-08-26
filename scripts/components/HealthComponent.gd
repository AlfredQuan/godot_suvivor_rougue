class_name HealthComponent
extends Node

# 信号定义
signal health_changed(old_health: float, new_health: float)
signal max_health_changed(old_max_health: float, new_max_health: float)
signal damage_taken(damage_amount: float)
signal healed(heal_amount: float)
signal died()

# 生命值属性
@export var max_health: float = 100.0 : set = set_max_health
@export var current_health: float : set = set_current_health
@export var invulnerable: bool = false
@export var invulnerability_duration: float = 0.0

# 内部变量
var _invulnerability_timer: Timer
var _is_dead: bool = false

func _ready():
	# 初始化当前生命值为最大生命值
	if current_health <= 0:
		current_health = max_health
	
	# 创建无敌时间计时器
	_invulnerability_timer = Timer.new()
	_invulnerability_timer.wait_time = max(0.01, invulnerability_duration)  # 确保时间大于0
	_invulnerability_timer.one_shot = true
	_invulnerability_timer.timeout.connect(_on_invulnerability_timeout)
	add_child(_invulnerability_timer)

# 设置最大生命值
func set_max_health(value: float):
	var old_max_health = max_health
	max_health = max(0, value)
	
	# 如果当前生命值超过新的最大值，调整当前生命值
	if current_health > max_health:
		current_health = max_health
	
	max_health_changed.emit(old_max_health, max_health)

# 设置当前生命值
func set_current_health(value: float):
	if _is_dead:
		return
		
	var old_health = current_health
	current_health = clamp(value, 0, max_health)
	
	if old_health != current_health:
		health_changed.emit(old_health, current_health)
		
		# 检查是否死亡
		if current_health <= 0 and not _is_dead:
			_is_dead = true
			died.emit()

# 受到伤害
func take_damage(damage_amount: float) -> bool:
	if _is_dead or invulnerable or damage_amount <= 0:
		return false
	
	set_current_health(current_health - damage_amount)
	
	damage_taken.emit(damage_amount)
	
	# 如果设置了无敌时间，启动无敌状态
	if invulnerability_duration > 0:
		invulnerable = true
		_invulnerability_timer.wait_time = max(0.01, invulnerability_duration)
		_invulnerability_timer.start()
	
	return true

# 治疗
func heal(heal_amount: float) -> bool:
	if _is_dead or heal_amount <= 0:
		return false
	
	var old_health = current_health
	set_current_health(current_health + heal_amount)
	
	if current_health > old_health:
		healed.emit(heal_amount)
		return true
	
	return false

# 完全治疗
func heal_to_full():
	heal(max_health - current_health)

# 获取生命值百分比
func get_health_percentage() -> float:
	if max_health <= 0:
		return 0.0
	return current_health / max_health

# 检查是否死亡
func is_dead() -> bool:
	return _is_dead

# 检查是否满血
func is_full_health() -> bool:
	return current_health >= max_health

# 重置生命值（用于复活等）
func reset_health():
	_is_dead = false
	current_health = max_health
	invulnerable = false
	if _invulnerability_timer:
		_invulnerability_timer.stop()

# 设置无敌状态
func set_invulnerable(duration: float = 0.0):
	invulnerable = true
	if duration > 0:
		_invulnerability_timer.wait_time = duration
		_invulnerability_timer.start()

# 无敌时间结束回调
func _on_invulnerability_timeout():
	invulnerable = false