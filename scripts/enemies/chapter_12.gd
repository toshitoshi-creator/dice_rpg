class_name EnemyChapter12
extends RefCounted
## チャプター 12「からくり工場」
## 雑魚: ネジロボ / プロペラドローン / ハグルマン　ボス: ギガロボ

const CHAPTER := 12
const AREA := "からくり工場"

const MOBS := [
	{
		"id": &"screw_bot", "idle": &"bounce", "height": 1.6, "width": 2.0,
		"names": ["ネジロボ", "サビネジロボ", "ゴールドネジロボ"],
		"names_en": ["SCREW BOT", "RUSTY BOT", "GOLD BOT"],
		"attack": "ネジまわしパンチ",
		"desc": "工場で生まれた小さなロボット。頭のネジがゆるむと暴れだす。",
		"palettes": [
			{&"plate": {"color": Color(0.7, 0.75, 0.82), "metal": 0.7, "rough": 0.35}, &"plate2": {"color": Color(0.3, 0.5, 0.85), "metal": 0.5, "rough": 0.4}, &"eye_glow": {"color": Color(0.3, 0.9, 1.0), "emission": 3.0}},
			{&"plate": {"color": Color(0.6, 0.38, 0.22), "metal": 0.5, "rough": 0.8}, &"plate2": {"color": Color(0.45, 0.35, 0.28), "metal": 0.4, "rough": 0.85}, &"eye_glow": {"color": Color(1.0, 0.5, 0.1), "emission": 3.0}},
			{&"plate": {"color": Color(1.0, 0.8, 0.3), "metal": 0.9, "rough": 0.25}, &"plate2": {"color": Color(0.2, 0.2, 0.25), "metal": 0.8, "rough": 0.3}, &"eye_glow": {"color": Color(1.0, 0.2, 0.3), "emission": 3.0}},
		],
	},
	{
		"id": &"drone", "idle": &"hover", "height": 1.7, "width": 2.4,
		"names": ["プロペラドローン", "ステルスドローン", "レーザードローン"],
		"names_en": ["DRONE", "STEALTH DRONE", "LASER DRONE"],
		"attack": "レーザービーム",
		"desc": "4 つのプロペラで飛ぶ見はりロボ。赤い目で侵入者をさがす。",
		"palettes": [
			{&"plate": {"color": Color(0.9, 0.9, 0.92), "metal": 0.3, "rough": 0.4}, &"plate2": {"color": Color(0.95, 0.55, 0.15), "metal": 0.3}, &"eye_glow": {"color": Color(1.0, 0.2, 0.15), "emission": 3.0}},
			{&"plate": {"color": Color(0.15, 0.16, 0.2), "metal": 0.6, "rough": 0.3}, &"plate2": {"color": Color(0.3, 0.8, 0.5), "emission": 0.5}, &"eye_glow": {"color": Color(0.3, 1.0, 0.5), "emission": 3.0}},
			{&"plate": {"color": Color(0.85, 0.2, 0.25), "metal": 0.6, "rough": 0.3}, &"plate2": {"color": Color(1.0, 0.85, 0.3), "metal": 0.8}, &"eye_glow": {"color": Color(1.0, 0.95, 0.4), "emission": 3.5}},
		],
	},
	{
		"id": &"gear_man", "idle": &"sway", "height": 1.8, "width": 2.2,
		"names": ["ハグルマン", "ブロンズハグルマン", "クロムハグルマン"],
		"names_en": ["GEAR MAN", "BRONZE GEAR", "CHROME GEAR"],
		"attack": "ギアカッター",
		"desc": "歯車が集まってできた魔物。体の歯車をとばしてくる。",
		"palettes": [
			{&"gear": {"color": Color(0.55, 0.58, 0.62), "metal": 0.85, "rough": 0.35}, &"gear2": {"color": Color(0.85, 0.65, 0.25), "metal": 0.8, "rough": 0.35}, &"eye_glow": {"color": Color(1.0, 0.6, 0.1), "emission": 3.0}},
			{&"gear": {"color": Color(0.7, 0.45, 0.25), "metal": 0.8, "rough": 0.45}, &"gear2": {"color": Color(0.4, 0.7, 0.6), "metal": 0.5, "rough": 0.6}, &"eye_glow": {"color": Color(0.3, 1.0, 0.8), "emission": 3.0}},
			{&"gear": {"color": Color(0.9, 0.92, 0.96), "metal": 1.0, "rough": 0.1}, &"gear2": {"color": Color(0.3, 0.3, 0.9), "metal": 0.9, "rough": 0.2}, &"eye_glow": {"color": Color(0.5, 0.6, 1.0), "emission": 3.5}},
		],
	},
]

const BOSS := {
	"id": &"giga_robo", "idle": &"breathe", "height": 3.8, "width": 3.8,
	"names": ["ギガロボ", "ブラックギガロボ", "オメガギガロボ"],
	"names_en": ["GIGA ROBO", "BLACK GIGA ROBO", "OMEGA GIGA ROBO"],
	"attack": "ロケットパンチ",
	"desc": "工場の最深部で作られた巨大ロボ。胸のコアが力のみなもと。",
	"palettes": [
		{&"plate": {"color": Color(0.85, 0.2, 0.2), "metal": 0.6, "rough": 0.35}, &"plate2": {"color": Color(0.9, 0.9, 0.95), "metal": 0.7, "rough": 0.3}, &"joint": {"color": Color(0.25, 0.25, 0.3), "metal": 0.8}, &"eye_glow": {"color": Color(1.0, 0.9, 0.3), "emission": 3.0}, &"core": {"color": Color(0.3, 0.8, 1.0), "emission": 2.5}},
		{&"plate": {"color": Color(0.12, 0.12, 0.15), "metal": 0.8, "rough": 0.25}, &"plate2": {"color": Color(0.5, 0.2, 0.7), "metal": 0.6, "rough": 0.3}, &"joint": {"color": Color(0.35, 0.3, 0.4), "metal": 0.8}, &"eye_glow": {"color": Color(1.0, 0.2, 0.3), "emission": 3.0}, &"core": {"color": Color(1.0, 0.2, 0.4), "emission": 2.5}},
		{&"plate": {"color": Color(1.0, 0.82, 0.3), "metal": 0.95, "rough": 0.2}, &"plate2": {"color": Color(0.95, 0.95, 1.0), "metal": 1.0, "rough": 0.1}, &"joint": {"color": Color(0.2, 0.2, 0.25), "metal": 0.9}, &"eye_glow": {"color": Color(0.4, 1.0, 0.6), "emission": 3.5}, &"core": {"color": Color(1.0, 1.0, 1.0), "emission": 3.0}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"screw_bot":
			_screw_bot(k, root)
		&"drone":
			_drone(k, root)
		&"gear_man":
			_gear_man(k, root)
		&"giga_robo":
			_giga_robo(k, root)
		_:
			return false
	return true


## 歯車（円柱＋歯）
static func _gear(k: ModelKit, parent: Node3D, role: StringName, pos: Vector3, r: float, depth: float, rot: Vector3 = Vector3(90, 0, 0)) -> void:
	var p := k.pivot(parent, pos, rot)
	k.cyl(p, role, Vector3.ZERO, r, r, depth, Vector3.ZERO, 20)
	for i in 10:
		var a := TAU * i / 10.0
		k.box(p, role, Vector3(sin(a) * r, 0, cos(a) * r), Vector3(r * 0.28, depth, r * 0.28), Vector3(0, rad_to_deg(a), 0))
	k.cyl(p, &"dark", Vector3.ZERO, r * 0.25, r * 0.25, depth + 0.02, Vector3.ZERO, 10)


# ------------------------------------------------------------------
static func _screw_bot(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.cyl(root, &"plate2", Vector3(0.22 * side, 0.2, 0), 0.1, 0.12, 0.4)
		k.box(root, &"plate", Vector3(0.22 * side, 0.04, 0.06), Vector3(0.26, 0.08, 0.36))
		k.limb(root, &"plate2", Vector3(0.45 * side, 0.85, 0), Vector3(0.62 * side, 0.55, 0.12), 0.07)
		k.sphere(root, &"plate", Vector3(0.64 * side, 0.5, 0.14), 0.11)
	k.box(root, &"plate", Vector3(0, 0.72, 0), Vector3(0.8, 0.65, 0.6))
	k.box(root, &"plate2", Vector3(0, 0.72, 0.31), Vector3(0.5, 0.35, 0.02))
	k.sphere(root, &"eye_glow", Vector3(-0.12, 0.78, 0.33), 0.05)
	k.sphere(root, &"eye_glow", Vector3(0.12, 0.66, 0.33), 0.04)
	var head := Vector3(0, 1.25, 0)
	k.box(root, &"plate", head, Vector3(0.62, 0.42, 0.5))
	k.box(root, &"dark", head + Vector3(0, 0.02, 0.25), Vector3(0.5, 0.18, 0.02))
	for side in [-1.0, 1.0]:
		k.sphere(root, &"eye_glow", head + Vector3(0.13 * side, 0.02, 0.27), 0.06, Vector3(1, 0.8, 0.5))
		k.cyl(root, &"plate2", head + Vector3(0.34 * side, 0, 0), 0.08, 0.08, 0.06, Vector3(0, 0, 90))
	# 頭のネジ
	k.cyl(root, &"plate2", head + Vector3(0, 0.3, 0), 0.05, 0.05, 0.2)
	k.cyl(root, &"plate", head + Vector3(0, 0.42, 0), 0.16, 0.16, 0.06, Vector3.ZERO, 6)


static func _drone(k: ModelKit, root: Node3D) -> void:
	var c := Vector3(0, 1.2, 0)
	k.sphere(root, &"plate", c, 0.42, Vector3(1, 0.6, 1))
	k.sphere(root, &"plate2", c + Vector3(0, -0.12, 0), 0.34, Vector3(1, 0.5, 1))
	k.sphere(root, &"dark", c + Vector3(0, -0.05, 0.34), 0.16, Vector3(1, 1, 0.6))
	k.sphere(root, &"eye_glow", c + Vector3(0, -0.05, 0.42), 0.1)
	for i in 4:
		var a := deg_to_rad(45.0 + 90.0 * i)
		var arm_end := c + Vector3(sin(a) * 0.9, 0.08, cos(a) * 0.9)
		k.limb(root, &"plate2", c + Vector3(sin(a) * 0.35, 0, cos(a) * 0.35), arm_end, 0.05)
		k.cyl(root, &"plate", arm_end, 0.08, 0.08, 0.12)
		var rotor := k.pivot(root, arm_end + Vector3(0, 0.1, 0))
		k.box(rotor, &"dark", Vector3.ZERO, Vector3(0.6, 0.02, 0.07), Vector3(0, 30.0 * i, 0))
		k.box(rotor, &"dark", Vector3.ZERO, Vector3(0.6, 0.02, 0.07), Vector3(0, 30.0 * i + 90, 0))
	# 下のアンテナと足
	for side in [-1.0, 1.0]:
		k.limb(root, &"plate2", c + Vector3(0.2 * side, -0.25, 0), c + Vector3(0.3 * side, -0.6, 0.05), 0.03)
	k.limb(root, &"plate2", c + Vector3(0, 0.22, -0.1), c + Vector3(0.05, 0.55, -0.2), 0.02)
	k.sphere(root, &"eye_glow", c + Vector3(0.05, 0.58, -0.2), 0.04)


static func _gear_man(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.limb(root, &"gear2", Vector3(0.2 * side, 0.75, 0), Vector3(0.24 * side, 0.1, 0.05), 0.08)
		_gear(k, root, &"gear", Vector3(0.24 * side, 0.12, 0.05), 0.16, 0.08, Vector3(0, 0, 90))
		k.limb(root, &"gear2", Vector3(0.45 * side, 1.15, 0), Vector3(0.7 * side, 0.75, 0.1), 0.06)
		_gear(k, root, &"gear2", Vector3(0.72 * side, 0.7, 0.12), 0.13, 0.06, Vector3(0, 0, 90))
	_gear(k, root, &"gear", Vector3(0, 1.0, 0), 0.45, 0.2)
	_gear(k, root, &"gear2", Vector3(0.12, 1.05, 0.14), 0.22, 0.08)
	var head := Vector3(0, 1.6, 0)
	_gear(k, root, &"gear", head, 0.26, 0.2)
	k.eyes(root, head + Vector3(0, 0.02, 0.12), 0.18, 0.06, &"glow")


static func _giga_robo(k: ModelKit, root: Node3D) -> void:
	# 脚
	for side in [-1.0, 1.0]:
		k.box(root, &"plate", Vector3(0.45 * side, 0.12, 0.1), Vector3(0.55, 0.24, 0.8))
		k.box(root, &"plate2", Vector3(0.45 * side, 0.6, 0), Vector3(0.4, 0.75, 0.45))
		k.sphere(root, &"joint", Vector3(0.45 * side, 1.02, 0), 0.2)
	# 胴
	k.box(root, &"plate2", Vector3(0, 1.3, 0), Vector3(1.0, 0.5, 0.7))
	k.box(root, &"plate", Vector3(0, 1.95, 0), Vector3(1.6, 0.95, 0.95))
	k.cyl(root, &"core", Vector3(0, 1.95, 0.48), 0.2, 0.2, 0.05, Vector3(90, 0, 0), 16)
	k.torus(root, &"joint", Vector3(0, 1.95, 0.49), 0.2, 0.28, Vector3(90, 0, 0))
	# 肩と腕
	for side in [-1.0, 1.0]:
		k.sphere(root, &"plate", Vector3(0.98 * side, 2.25, 0), 0.34)
		k.box(root, &"plate2", Vector3(1.05 * side, 1.7, 0.1), Vector3(0.36, 0.7, 0.4))
		k.box(root, &"plate", Vector3(1.08 * side, 1.15, 0.2), Vector3(0.5, 0.5, 0.55))
		for f in 3:
			k.box(root, &"joint", Vector3(1.08 * side + (f - 1) * 0.14, 0.86, 0.35), Vector3(0.1, 0.12, 0.12))
		k.spike(root, &"plate2", Vector3(0.98 * side, 2.5, 0), Vector3(1.2 * side, 2.85, -0.05), 0.08)
	# 頭
	var head := Vector3(0, 2.7, 0.05)
	k.box(root, &"plate2", head, Vector3(0.7, 0.5, 0.6))
	k.box(root, &"dark", head + Vector3(0, 0.02, 0.3), Vector3(0.58, 0.16, 0.02))
	k.box(root, &"eye_glow", head + Vector3(0, 0.02, 0.31), Vector3(0.5, 0.07, 0.02))
	for side in [-1.0, 1.0]:
		k.spike(root, &"plate", head + Vector3(0.25 * side, 0.2, 0), head + Vector3(0.42 * side, 0.6, -0.1), 0.07)
