class_name EnemyDatabase
extends RefCounted
## 敵データの一覧。将来は Goblin / Skeleton / Orc / Dragon などをここに追加する。

const ENEMIES := {
	&"slime": {
		"display_name": "SLIME",
		"max_hp": 100,
		"attack": 10,
		"defense": 0,
		"model_type": &"slime",
		"body_color": Color(0.3, 0.85, 0.45),
		"model_scale": 1.15,
	},
}


static func has_enemy(id: StringName) -> bool:
	return ENEMIES.has(id)


static func get_enemy(id: StringName) -> EnemyData:
	var entry: Dictionary = ENEMIES.get(id, ENEMIES[&"slime"])
	var data := EnemyData.new()
	data.id = id if ENEMIES.has(id) else &"slime"
	data.display_name = entry["display_name"]
	data.max_hp = entry["max_hp"]
	data.attack = entry["attack"]
	data.defense = entry["defense"]
	data.model_type = entry["model_type"]
	data.body_color = entry["body_color"]
	data.model_scale = entry["model_scale"]
	return data
