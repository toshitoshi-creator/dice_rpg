class_name EnemyDatabase
extends RefCounted
## 敵データの一覧。新しい敵はここに追加し、EnemyActor._build_model() に見た目を追加する。

const ENEMIES := {
	&"slime": {
		"display_name": "SLIME",
		"max_hp": 100,
		"attack": 10,
		"defense": 0,
		"model_type": &"slime",
		"body_color": Color(0.3, 0.85, 0.45),
		"model_scale": 1.15,
		"attack_name": "たいあたり",
		"hit_height": 0.9,
		"jump_height": 0.9,
		"lunge_ratio": 0.7,
	},
	&"goblin": {
		"display_name": "GOBLIN",
		"max_hp": 120,
		"attack": 12,
		"defense": 0,
		"model_type": &"goblin",
		"body_color": Color(0.46, 0.66, 0.26),
		"model_scale": 1.5,
		"attack_name": "こんぼう攻撃",
		"hit_height": 1.7,
		"jump_height": 0.6,
		"lunge_ratio": 0.7,
	},
	&"skeleton": {
		"display_name": "SKELETON",
		"max_hp": 150,
		"attack": 13,
		"defense": 0,
		"model_type": &"skeleton",
		"body_color": Color(0.93, 0.9, 0.8),
		"model_scale": 1.5,
		"attack_name": "ほねの剣",
		"hit_height": 1.8,
		"jump_height": 0.5,
		"lunge_ratio": 0.7,
	},
	&"dragon": {
		"display_name": "DRAGON",
		"max_hp": 220,
		"attack": 14,
		"defense": 0,
		"model_type": &"dragon",
		"body_color": Color(0.62, 0.12, 0.2),
		"model_scale": 1.0,
		"attack_name": "ほのおのツメ",
		"hit_height": 2.2,
		"hit_forward": 0.9,
		"jump_height": 0.35,
		"lunge_ratio": 0.5,
		"is_boss": true,
	},
}


static func has_enemy(id: StringName) -> bool:
	return ENEMIES.has(id)


static func get_enemy(id: StringName) -> EnemyData:
	var key: StringName = id if ENEMIES.has(id) else &"slime"
	var entry: Dictionary = ENEMIES[key]
	var data := EnemyData.new()
	data.id = key
	for prop in entry:
		data.set(prop, entry[prop])
	return data
