# 吸血鬼幸存者风格肉鸽游戏

使用Godot 4.x引擎开发的类似《吸血鬼幸存者》的肉鸽幸存者游戏。

## 项目结构

```
├── data/                          # 游戏数据文件
│   ├── configs/                   # 配置文件目录
│   │   ├── characters/            # 角色配置
│   │   ├── weapons/               # 武器配置
│   │   ├── enemies/               # 敌人配置
│   │   └── effects/               # 效果配置
│   └── constants.json             # 游戏常量
├── scripts/                       # 脚本文件
│   ├── managers/                  # 管理器脚本
│   │   ├── ConfigManager.gd       # 配置管理器
│   │   ├── SaveManager.gd         # 存档管理器
│   │   └── GameManager.gd         # 游戏管理器
│   ├── resources/                 # 资源类脚本
│   │   ├── CharacterConfig.gd     # 角色配置资源
│   │   ├── WeaponConfig.gd        # 武器配置资源
│   │   ├── EnemyConfig.gd         # 敌人配置资源
│   │   └── EffectConfig.gd        # 效果配置资源
│   ├── components/                # 组件脚本
│   └── ui/                        # UI脚本
├── scenes/                        # 场景文件
│   ├── components/                # 组件场景
│   └── ui/                        # UI场景
├── sprites/                       # 精灵图片
│   ├── characters/                # 角色精灵
│   ├── enemies/                   # 敌人精灵
│   ├── weapons/                   # 武器精灵
│   └── effects/                   # 效果精灵
└── tests/                         # 测试文件
    └── test_config_manager.gd     # 配置管理器测试
```

## 核心系统

### 配置管理系统 (ConfigManager)
- 支持JSON配置文件加载
- 热重载支持（开发模式）
- 配置验证和错误处理
- 缓存机制提高性能

### 资源系统
- CharacterConfig: 角色配置资源
- WeaponConfig: 武器配置资源
- EnemyConfig: 敌人配置资源
- EffectConfig: 效果配置资源

## 运行测试

可以通过以下方式运行配置系统测试：

1. 在Godot编辑器中运行 `test_runner.gd`
2. 使用GUT测试框架运行 `tests/test_config_manager.gd`

## 开发状态

- [x] 项目结构建立
- [x] 配置管理系统
- [x] 基础资源类
- [x] 单元测试
- [ ] 组件系统（待实现）
- [ ] 角色系统（待实现）
- [ ] 武器系统（待实现）
- [ ] 敌人系统（待实现）
- [ ] 效果系统（待实现）

## 配置文件示例

### 角色配置 (characters/basic_character.json)
```json
{
  "id": "basic_character",
  "name": "基础角色",
  "description": "平衡的新手角色",
  "base_stats": {
    "max_health": 100,
    "move_speed": 150,
    "pickup_range": 50
  },
  "starting_weapon": "basic_gun",
  "sprite_path": "res://sprites/characters/basic.png"
}
```

### 武器配置 (weapons/basic_gun.json)
```json
{
  "id": "basic_gun",
  "name": "基础枪械",
  "type": "projectile",
  "base_stats": {
    "damage": 10,
    "fire_rate": 1.0,
    "range": 200,
    "projectile_speed": 300
  },
  "evolution": {
    "required_level": 8,
    "evolved_weapon": "advanced_gun"
  }
}
```