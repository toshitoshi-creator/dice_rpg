class_name EnemyChapter05
extends RefCounted
## チャプター 5「くらやみの洞窟」
## 雑魚: バット / スパイダー / ゴーレム　ボス: サイクロプス

const CHAPTER := 5
const AREA := "くらやみの洞窟"

const MOBS := [
	{
		"id": &"bat", "idle": &"hover", "height": 1.7, "width": 2.6,
		"names": ["バット", "ブラッドバット", "ヴァンパイアバット"],
		"names_en": ["BAT", "BLOOD BAT", "VAMPIRE BAT"],
		"attack": "きゅうけつ",
		"desc": "洞窟の天井にぶらさがるコウモリ。暗やみでも正確にかみつく。",
		"palettes": [
			{&"fur": Color(0.4, 0.3, 0.5), &"wing": {"color": Color(0.3, 0.2, 0.38), "double": true}, &"ear": Color(0.9, 0.55, 0.6)},
			{&"fur": Color(0.55, 0.12, 0.15), &"wing": {"color": Color(0.35, 0.06, 0.1), "double": true}, &"ear": Color(1.0, 0.5, 0.4)},
			{&"fur": Color(0.12, 0.1, 0.14), &"wing": {"color": Color(0.55, 0.05, 0.12), "double": true}, &"ear": Color(0.6, 0.1, 0.2), &"eye_white": {"color": Color(1.0, 0.2, 0.2), "emission": 1.5}},
		],
	},
	{
		"id": &"spider", "idle": &"breathe", "height": 1.3, "width": 2.6,
		"names": ["スパイダー", "ポイズンスパイダー", "ゴールドスパイダー"],
		"names_en": ["SPIDER", "POISON SPIDER", "GOLD SPIDER"],
		"attack": "どくのキバ",
		"desc": "洞窟に巣をはる大グモ。8つの目で獲物をのがさない。",
		"palettes": [
			{&"body": {"color": Color(0.32, 0.22, 0.16), "rough": 0.7}, &"mark": Color(1.0, 0.55, 0.1), &"eye_glow": {"color": Color(1.0, 0.2, 0.15), "emission": 3.0}},
			{&"body": {"color": Color(0.35, 0.15, 0.45), "rough": 0.6}, &"mark": {"color": Color(0.4, 1.0, 0.3), "emission": 1.0}, &"eye_glow": {"color": Color(0.4, 1.0, 0.3), "emission": 3.0}},
			{&"body": {"color": Color(0.08, 0.07, 0.08), "rough": 0.3, "clearcoat": 0.8}, &"mark": {"color": Color(1.0, 0.8, 0.3), "metal": 0.9, "rough": 0.25}, &"eye_glow": {"color": Color(1.0, 0.85, 0.3), "emission": 3.0}},
		],
	},
	{
		"id": &"golem", "idle": &"breathe", "height": 2.2, "width": 2.6,
		"names": ["ロックゴーレム", "アイアンゴーレム", "クリスタルゴーレム"],
		"names_en": ["ROCK GOLEM", "IRON GOLEM", "CRYSTAL GOLEM"],
		"attack": "ロックパンチ",
		"desc": "魔力で動く岩の巨人。とてもかたく、パンチは強烈。",
		"palettes": [
			{&"rock": {"color": Color(0.46, 0.43, 0.41), "rough": 0.95}, &"rock2": {"color": Color(0.34, 0.32, 0.32), "rough": 0.95}, &"moss": Color(0.35, 0.55, 0.25), &"gem": {"color": Color(0.3, 0.8, 1.0), "emission": 1.5, "rough": 0.1}, &"eye_glow": {"color": Color(0.3, 0.8, 1.0), "emission": 3.0}},
			{&"rock": {"color": Color(0.6, 0.62, 0.66), "metal": 0.8, "rough": 0.35}, &"rock2": {"color": Color(0.62, 0.42, 0.25), "metal": 0.8, "rough": 0.35}, &"moss": {"color": Color(0.5, 0.3, 0.2), "metal": 0.5}, &"gem": {"color": Color(1.0, 0.4, 0.1), "emission": 1.5}, &"eye_glow": {"color": Color(1.0, 0.5, 0.1), "emission": 3.0}},
			{&"rock": {"color": Color(0.55, 0.85, 0.95), "rough": 0.1, "emission": 0.25, "clearcoat": 1.0}, &"rock2": {"color": Color(0.7, 0.55, 0.95), "rough": 0.1, "emission": 0.3}, &"moss": Color(0.9, 0.95, 1.0), &"gem": {"color": Color(1.0, 0.4, 0.9), "emission": 2.0}, &"eye_glow": {"color": Color(1.0, 0.4, 0.9), "emission": 3.0}},
		],
	},
]

const BOSS := {
	"id": &"cyclops", "idle": &"sway", "height": 3.5, "width": 3.8,
	"names": ["サイクロプス", "ブルーサイクロプス", "ブラックサイクロプス"],
	"names_en": ["CYCLOPS", "BLUE CYCLOPS", "BLACK CYCLOPS"],
	"attack": "いわくだき",
	"desc": "洞窟の奥にすむ一つ目の巨人。石のハンマーで大地をくだく。",
	"palettes": [
		{&"skin": Color(0.85, 0.62, 0.45), &"cloth": Color(0.5, 0.35, 0.2), &"stone": {"color": Color(0.5, 0.48, 0.46), "rough": 0.95}, &"horn": Color(0.9, 0.85, 0.7), &"iris": Color(0.3, 0.6, 0.2)},
		{&"skin": Color(0.4, 0.55, 0.8), &"cloth": Color(0.3, 0.25, 0.2), &"stone": {"color": Color(0.35, 0.38, 0.45), "rough": 0.9}, &"horn": Color(0.85, 0.85, 0.9), &"iris": Color(0.9, 0.7, 0.1)},
		{&"skin": Color(0.25, 0.23, 0.26), &"cloth": Color(0.45, 0.08, 0.1), &"stone": {"color": Color(0.15, 0.13, 0.15), "rough": 0.8}, &"horn": Color(0.7, 0.2, 0.2), &"iris": {"color": Color(1.0, 0.15, 0.1), "emission": 2.0}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"bat":
			_bat(k, root)
		&"spider":
			_spider(k, root)
		&"golem":
			_golem(k, root)
		&"cyclops":
			_cyclops(k, root)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _bat(k: ModelKit, root: Node3D) -> void:
	var c := Vector3(0, 1.15, 0)
	k.sphere(root, &"fur", c, 0.3, Vector3(1, 1.1, 0.9))
	k.eyes(root, c + Vector3(0, 0.08, 0.25), 0.2, 0.075, &"angry", &"fur")
	k.sphere(root, &"mouth", c + Vector3(0, -0.1, 0.26), 0.05, Vector3(1.5, 0.7, 0.5))
	for side in [-1.0, 1.0]:
		k.spike(root, &"fur", c + Vector3(0.14 * side, 0.2, 0), c + Vector3(0.3 * side, 0.55, -0.02), 0.11)
		k.spike(root, &"ear", c + Vector3(0.15 * side, 0.22, 0.04), c + Vector3(0.28 * side, 0.48, 0.02), 0.06)
		k.spike(root, &"tooth", c + Vector3(0.05 * side, -0.12, 0.27), c + Vector3(0.05 * side, -0.22, 0.28), 0.025)
		k.limb(root, &"dark", c + Vector3(0.08 * side, -0.3, -0.05), c + Vector3(0.1 * side, -0.48, -0.05), 0.025)
		var p := k.pivot(root, c + Vector3(0.25 * side, 0.05, -0.05))
		var tip := Vector3(1.2 * side, 0.35, -0.1)
		k.limb(p, &"fur", Vector3.ZERO, tip, 0.035)
		for j in 3:
			var f := Vector3((0.45 + j * 0.28) * side, -0.45 + j * 0.12, -0.08)
			k.limb(p, &"fur", tip * (0.35 + j * 0.15), f, 0.02)
		k.sphere(p, &"wing", Vector3(0.64 * side, -0.05, -0.08), 0.62, Vector3(1.0, 0.55, 0.04), Vector3(0, 0, 12.0 * side))
		k.add_wing(p, side)
	k.parts["wing_speed"] = 0.14
	k.parts["wing_angle"] = 35.0


static func _spider(k: ModelKit, root: Node3D) -> void:
	var abd := Vector3(0, 0.68, -0.48)
	k.sphere(root, &"body", abd, 0.52, Vector3(1, 0.85, 1.1))
	k.stud(root, &"mark", abd, Vector3(0.52, 0.44, 0.57), 180, 55, Vector3(0.14, 0.03, 0.1))
	k.stud(root, &"mark", abd, Vector3(0.52, 0.44, 0.57), 180, 75, Vector3(0.1, 0.03, 0.14))
	k.stud(root, &"mark", abd, Vector3(0.52, 0.44, 0.57), 0, 60, Vector3(0.12, 0.03, 0.1))
	var head := Vector3(0, 0.56, 0.2)
	k.sphere(root, &"body", head, 0.34, Vector3(1, 0.85, 1))
	k.eyes(root, head + Vector3(0, 0.12, 0.27), 0.16, 0.06, &"glow")
	k.eyes(root, head + Vector3(0, 0.2, 0.22), 0.3, 0.035, &"glow")
	k.eyes(root, head + Vector3(0, 0.02, 0.3), 0.08, 0.03, &"glow")
	for side in [-1.0, 1.0]:
		k.spike(root, &"dark", head + Vector3(0.08 * side, -0.1, 0.26), head + Vector3(0.06 * side, -0.3, 0.34), 0.05)
		for i in 4:
			var z0 := 0.32 - i * 0.16
			var spread := (1.5 - i) * 0.3
			var knee := Vector3(0.78 * side, 1.05, z0 + spread * 0.6)
			var foot := Vector3(1.12 * side, 0.02, z0 + spread * 1.4)
			k.limb(root, &"body", Vector3(0.25 * side, 0.56, z0), knee, 0.055)
			k.limb(root, &"body", knee, foot, 0.045)
			k.sphere(root, &"mark", knee, 0.06)


static func _golem(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.box(root, &"rock", Vector3(0.32 * side, 0.36, 0), Vector3(0.42, 0.72, 0.48), Vector3(0, 0, 3.0 * side))
		k.box(root, &"rock2", Vector3(0.32 * side, 0.06, 0.08), Vector3(0.5, 0.14, 0.62))
	k.box(root, &"rock2", Vector3(0, 0.85, 0), Vector3(0.9, 0.35, 0.55))
	k.box(root, &"rock", Vector3(0, 1.45, 0), Vector3(1.3, 0.95, 0.8), Vector3(0, 0, 2))
	k.box(root, &"rock2", Vector3(0.15, 1.3, 0.38), Vector3(0.5, 0.4, 0.1), Vector3(0, 0, -8))
	k.sphere(root, &"gem", Vector3(-0.2, 1.55, 0.4), 0.13, Vector3(1, 1, 0.5))
	for s in [[Vector3(-0.45, 1.85, 0.3), 0.14], [Vector3(0.4, 1.1, 0.35), 0.1], [Vector3(0.5, 1.88, -0.2), 0.16]]:
		k.sphere(root, &"moss", s[0], s[1], Vector3(1.4, 0.5, 1.2))
	var head := Vector3(0, 2.08, 0.08)
	k.box(root, &"rock2", head, Vector3(0.52, 0.45, 0.5))
	k.box(root, &"eye_glow", head + Vector3(0, 0.03, 0.25), Vector3(0.36, 0.07, 0.04))
	for side in [-1.0, 1.0]:
		k.box(root, &"rock2", Vector3(0.85 * side, 1.75, 0), Vector3(0.5, 0.5, 0.52), Vector3(10, 0, 15.0 * side))
		k.spike(root, &"gem", Vector3(0.85 * side, 1.95, -0.05), Vector3(0.95 * side, 2.4, -0.1), 0.1)
		k.spike(root, &"gem", Vector3(0.75 * side, 1.95, 0.08), Vector3(0.72 * side, 2.25, 0.1), 0.07)
		k.box(root, &"rock", Vector3(0.95 * side, 1.2, 0.1), Vector3(0.36, 0.7, 0.36), Vector3(-10, 0, 5.0 * side))
		k.box(root, &"rock2", Vector3(1.0 * side, 0.7, 0.22), Vector3(0.52, 0.46, 0.52), Vector3(0, 10.0 * side, 0))


static func _cyclops(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.limb(root, &"skin", Vector3(0.32 * side, 1.0, 0), Vector3(0.34 * side, 0.55, 0.08), 0.2)
		k.limb(root, &"skin", Vector3(0.34 * side, 0.55, 0.08), Vector3(0.34 * side, 0.15, 0), 0.17)
		k.box(root, &"leather", Vector3(0.34 * side, 0.07, 0.1), Vector3(0.34, 0.14, 0.5))
	k.cyl(root, &"cloth", Vector3(0, 1.1, 0), 0.55, 0.68, 0.45, Vector3.ZERO, 8)
	for i in 6:
		var a := TAU * i / 6.0 + 0.3
		k.spike(root, &"cloth", Vector3(sin(a) * 0.62, 0.9, cos(a) * 0.62), Vector3(sin(a) * 0.72, 0.72, cos(a) * 0.72), 0.12)
	k.torus(root, &"leather", Vector3(0, 1.32, 0), 0.52, 0.62, Vector3.ZERO, Vector3(1, 0.5, 1))
	k.sphere(root, &"skin", Vector3(0, 1.8, 0), 0.68, Vector3(1.15, 1.05, 0.85))
	k.box(root, &"leather", Vector3(0, 1.9, 0.1), Vector3(0.15, 1.2, 0.72), Vector3(0, 0, -40))
	var head := Vector3(0, 2.65, 0.08)
	k.sphere(root, &"skin", head, 0.45, Vector3(1, 1.05, 0.95))
	var eye := head + Vector3(0, 0.08, 0.36)
	k.sphere(root, &"eye_white", eye, 0.19, Vector3(1.1, 1, 0.6))
	k.sphere(root, &"iris", eye + Vector3(0, 0, 0.08), 0.11, Vector3(1, 1, 0.5))
	k.sphere(root, &"pupil", eye + Vector3(0, 0, 0.12), 0.055, Vector3(1, 1, 0.5))
	k.sphere(root, &"shine", eye + Vector3(0.05, 0.05, 0.15), 0.025)
	k.box(root, &"skin", eye + Vector3(0, 0.2, 0.02), Vector3(0.46, 0.08, 0.12), Vector3(8, 0, 0))
	k.spike(root, &"horn", head + Vector3(0, 0.38, -0.05), head + Vector3(0, 0.78, -0.2), 0.1)
	k.box(root, &"mouth", head + Vector3(0, -0.24, 0.36), Vector3(0.3, 0.08, 0.05))
	for side in [-1.0, 1.0]:
		k.spike(root, &"tooth", head + Vector3(0.1 * side, -0.26, 0.37), head + Vector3(0.1 * side, -0.14, 0.38), 0.035)
		k.sphere(root, &"skin", head + Vector3(0.45 * side, 0.05, 0), 0.1, Vector3(0.5, 1, 1))
		k.sphere(root, &"skin", Vector3(0.78 * side, 2.2, 0), 0.3)
	k.limb(root, &"skin", Vector3(-0.85, 2.1, 0), Vector3(-1.0, 1.45, 0.15), 0.17)
	k.limb(root, &"skin", Vector3(-1.0, 1.45, 0.15), Vector3(-0.95, 0.95, 0.3), 0.15)
	k.sphere(root, &"skin", Vector3(-0.95, 0.85, 0.33), 0.2)
	var w := k.pivot(root, Vector3(0.85, 2.1, 0))
	k.limb(w, &"skin", Vector3.ZERO, Vector3(0.12, -0.55, 0.2), 0.17)
	k.limb(w, &"skin", Vector3(0.12, -0.55, 0.2), Vector3(0.12, -0.9, 0.45), 0.15)
	k.sphere(w, &"skin", Vector3(0.12, -0.98, 0.5), 0.19)
	k.limb(w, &"wood", Vector3(0.12, -1.15, 0.35), Vector3(0.12, -0.25, 1.55), 0.06)
	k.box(w, &"stone", Vector3(0.12, -0.18, 1.62), Vector3(0.55, 0.5, 0.75), Vector3(-37, 0, 0))
	k.parts["weapon"] = w
