class_name EnemyChapter04
extends RefCounted
## チャプター 4「さまよう墓場」
## 雑魚: スケルトン / ゴースト / ゾンビ　ボス: リッチ

const CHAPTER := 4
const AREA := "さまよう墓場"

const MOBS := [
	{
		"id": &"skeleton", "idle": &"sway", "height": 1.95, "width": 2.2,
		"names": ["スケルトン", "ブラッドスケルトン", "ダークスケルトン"],
		"names_en": ["SKELETON", "BLOOD SKELETON", "DARK SKELETON"],
		"attack": "ほねの剣",
		"desc": "墓場をまもる骨の兵士。何度でも立ち上がる。",
		"palettes": [
			{&"bone": Color(0.93, 0.9, 0.8), &"rust": {"color": Color(0.55, 0.45, 0.38), "metal": 0.6, "rough": 0.4}, &"cloth": Color(0.25, 0.12, 0.3)},
			{&"bone": Color(0.85, 0.55, 0.5), &"rust": {"color": Color(0.35, 0.3, 0.3), "metal": 0.7, "rough": 0.35}, &"cloth": Color(0.4, 0.05, 0.08), &"eye_glow": {"color": Color(1.0, 0.95, 0.3), "emission": 3.0}},
			{&"bone": Color(0.22, 0.2, 0.25), &"rust": {"color": Color(0.6, 0.3, 0.8), "metal": 0.6, "rough": 0.3}, &"cloth": Color(0.08, 0.06, 0.1), &"eye_glow": {"color": Color(0.7, 0.3, 1.0), "emission": 3.5}},
		],
	},
	{
		"id": &"ghost", "idle": &"hover", "height": 1.9, "width": 2.2,
		"names": ["ゴースト", "ブルーゴースト", "ファントム"],
		"names_en": ["GHOST", "BLUE GHOST", "PHANTOM"],
		"attack": "おどろかす",
		"desc": "夜の墓場にあらわれるおばけ。体がすけている。",
		"palettes": [
			{&"sheet": {"color": Color(0.95, 0.95, 1.0), "rough": 0.3, "emission": 0.25, "rim": 0.8}},
			{&"sheet": {"color": Color(0.5, 0.78, 1.0), "rough": 0.3, "emission": 0.5, "rim": 0.8}},
			{&"sheet": {"color": Color(0.58, 0.33, 0.85), "rough": 0.3, "emission": 0.45, "rim": 0.8}, &"pupil": {"color": Color(1.0, 0.9, 0.2), "emission": 2.0}},
		],
	},
	{
		"id": &"zombie", "idle": &"sway", "height": 1.9, "width": 2.2,
		"names": ["ゾンビ", "ポイズンゾンビ", "ブラッドゾンビ"],
		"names_en": ["ZOMBIE", "POISON ZOMBIE", "BLOOD ZOMBIE"],
		"attack": "くさった息",
		"desc": "墓からはい出してきた死者。動きはのろいがしつこい。",
		"palettes": [
			{&"skin": Color(0.55, 0.68, 0.5), &"shirt": Color(0.3, 0.4, 0.6), &"pants": Color(0.35, 0.28, 0.2), &"hair": Color(0.2, 0.15, 0.1)},
			{&"skin": Color(0.6, 0.45, 0.7), &"shirt": Color(0.35, 0.55, 0.25), &"pants": Color(0.25, 0.22, 0.3), &"hair": Color(0.15, 0.3, 0.1)},
			{&"skin": Color(0.8, 0.55, 0.5), &"shirt": Color(0.45, 0.08, 0.1), &"pants": Color(0.15, 0.12, 0.14), &"hair": Color(0.9, 0.9, 0.85)},
		],
	},
]

const BOSS := {
	"id": &"lich", "idle": &"hover", "height": 3.5, "width": 3.8,
	"names": ["リッチ", "フロストリッチ", "エンペラーリッチ"],
	"names_en": ["LICH", "FROST LICH", "EMPEROR LICH"],
	"attack": "しのまほう",
	"desc": "永遠の命を手に入れた魔法使いのなれのはて。死者をあやつる。",
	"palettes": [
		{&"robe": Color(0.35, 0.15, 0.5), &"robe2": Color(0.22, 0.08, 0.32), &"trim": {"color": Color(0.9, 0.75, 0.3), "metal": 0.8, "rough": 0.3}, &"glow": {"color": Color(0.4, 1.0, 0.5), "emission": 3.0}, &"eye_glow": {"color": Color(0.4, 1.0, 0.5), "emission": 3.5}},
		{&"robe": Color(0.35, 0.6, 0.85), &"robe2": Color(0.2, 0.35, 0.6), &"trim": {"color": Color(0.85, 0.9, 1.0), "metal": 0.8, "rough": 0.2}, &"glow": {"color": Color(0.5, 0.95, 1.0), "emission": 3.0}, &"eye_glow": {"color": Color(0.5, 0.95, 1.0), "emission": 3.5}},
		{&"robe": Color(0.12, 0.1, 0.14), &"robe2": Color(0.3, 0.05, 0.08), &"trim": {"color": Color(1.0, 0.8, 0.3), "metal": 0.9, "rough": 0.25}, &"glow": {"color": Color(1.0, 0.25, 0.2), "emission": 3.0}, &"eye_glow": {"color": Color(1.0, 0.25, 0.2), "emission": 3.5}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"skeleton":
			_skeleton(k, root)
		&"ghost":
			_ghost(k, root)
		&"zombie":
			_zombie(k, root)
		&"lich":
			_lich(k, root)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _skeleton(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.limb(root, &"bone", Vector3(0.13 * side, 0.72, 0), Vector3(0.13 * side, 0.4, 0.02), 0.045)
		k.limb(root, &"bone", Vector3(0.13 * side, 0.4, 0.02), Vector3(0.13 * side, 0.08, 0), 0.04)
		k.sphere(root, &"bone", Vector3(0.13 * side, 0.4, 0.03), 0.065)
		k.box(root, &"bone", Vector3(0.13 * side, 0.03, 0.05), Vector3(0.14, 0.06, 0.24))
	k.box(root, &"bone", Vector3(0, 0.76, 0), Vector3(0.38, 0.13, 0.2))
	k.cyl(root, &"cloth", Vector3(0, 0.66, 0), 0.24, 0.3, 0.2, Vector3.ZERO, 10)
	k.limb(root, &"bone", Vector3(0, 0.8, -0.03), Vector3(0, 1.38, -0.03), 0.04)
	for i in 4:
		k.torus(root, &"bone", Vector3(0, 0.98 + i * 0.1, 0.02), 0.15 - i * 0.012, 0.2 - i * 0.012, Vector3.ZERO, Vector3(1.1, 1.4, 0.75))
	var head := Vector3(0, 1.58, 0)
	k.sphere(root, &"bone", head, 0.23)
	k.box(root, &"bone", head + Vector3(0, -0.18, 0.06), Vector3(0.24, 0.1, 0.2))
	for side in [-1.0, 1.0]:
		k.sphere(root, &"dark", head + Vector3(0.085 * side, 0.02, 0.18), 0.065)
		k.sphere(root, &"eye_glow", head + Vector3(0.085 * side, 0.02, 0.22), 0.03)
	k.box(root, &"dark", head + Vector3(0, -0.08, 0.22), Vector3(0.04, 0.05, 0.04))
	k.limb(root, &"bone", Vector3(-0.28, 1.35, 0), Vector3(-0.34, 0.95, 0.12), 0.035)
	k.cyl(root, &"rust", Vector3(-0.38, 0.92, 0.22), 0.26, 0.26, 0.05, Vector3(90, 0, 0), 8)
	k.sphere(root, &"rust", Vector3(-0.38, 0.92, 0.26), 0.06)
	var w := k.pivot(root, Vector3(0.3, 1.32, 0.02), Vector3(20, 0, 0))
	k.limb(w, &"bone", Vector3.ZERO, Vector3(0, -0.5, 0), 0.035)
	k.box(w, &"rust", Vector3(0, -0.52, 0.12), Vector3(0.24, 0.04, 0.06), Vector3(-70, 0, 0))
	k.box(w, &"rust", Vector3(0, -0.4, 0.55), Vector3(0.07, 0.8, 0.02), Vector3(-70, 0, 0))
	k.parts["weapon"] = w


static func _ghost(k: ModelKit, root: Node3D) -> void:
	var c := Vector3(0, 1.4, 0)
	k.sphere(root, &"sheet", c, 0.55, Vector3(1, 1.05, 1))
	k.cyl(root, &"sheet", Vector3(0, 0.95, 0), 0.55, 0.72, 0.9, Vector3.ZERO, 20)
	for i in 10:
		var a := TAU * i / 10.0
		k.sphere(root, &"sheet", Vector3(sin(a) * 0.62, 0.52, cos(a) * 0.62), 0.15, Vector3(1, 1.3, 1), Vector3.ZERO, 12)
	k.spike(root, &"sheet", Vector3(0, 1.8, -0.35), Vector3(0.05, 2.1, -0.75), 0.18)
	for side in [-1.0, 1.0]:
		k.limb(root, &"sheet", Vector3(0.5 * side, 1.25, 0.1), Vector3(0.82 * side, 1.05, 0.38), 0.12)
		k.sphere(root, &"pupil", c + Vector3(0.19 * side, 0.08, 0.5), 0.1, Vector3(1, 1.5, 0.5))
		k.sphere(root, &"shine", c + Vector3(0.21 * side, 0.15, 0.56), 0.03)
		k.sphere(root, &"blush", c + Vector3(0.35 * side, -0.1, 0.42), 0.07, Vector3(1.2, 0.6, 0.4))
	k.sphere(root, &"mouth", c + Vector3(0, -0.2, 0.52), 0.12, Vector3(1, 1.4, 0.5))
	k.sphere(root, &"tongue", c + Vector3(0, -0.3, 0.52), 0.06, Vector3(1.2, 0.8, 0.6))


static func _zombie(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		var knee := Vector3(0.17 * side, 0.45, 0.07)
		k.limb(root, &"pants", Vector3(0.15 * side, 0.85, 0), knee, 0.11)
		k.limb(root, &"skin", knee, Vector3(0.16 * side, 0.08, 0), 0.08)
		k.box(root, &"dark", Vector3(0.16 * side, 0.04, 0.06), Vector3(0.18, 0.08, 0.3))
	var torso := k.capsule(root, &"shirt", Vector3(0, 1.25, 0.06), 0.3, 0.9, Vector3(15, 0, 0))
	torso.scale = Vector3(1.05, 1, 0.9)
	k.stud(root, &"skin", Vector3(0, 1.25, 0.06), Vector3(0.3, 0.45, 0.28), 20, -10, Vector3(0.1, 0.08, 0.02))
	k.stud(root, &"skin", Vector3(0, 1.25, 0.06), Vector3(0.3, 0.45, 0.28), -30, 25, Vector3(0.08, 0.1, 0.02))
	k.box(root, &"pants", Vector3(0, 0.84, 0), Vector3(0.6, 0.12, 0.4))
	var head := Vector3(0, 1.82, 0.28)
	k.sphere(root, &"skin", head, 0.24)
	k.sphere(root, &"eye_white", head + Vector3(0.1, 0.05, 0.19), 0.08)
	k.sphere(root, &"pupil", head + Vector3(0.1, 0.04, 0.26), 0.03)
	k.sphere(root, &"eye_white", head + Vector3(-0.1, 0.03, 0.2), 0.05)
	k.sphere(root, &"pupil", head + Vector3(-0.1, 0.03, 0.24), 0.025)
	k.box(root, &"dark", head + Vector3(0, -0.12, 0.2), Vector3(0.18, 0.05, 0.05))
	for i in 3:
		k.spike(root, &"tooth", head + Vector3(-0.05 + i * 0.05, -0.1, 0.22), head + Vector3(-0.05 + i * 0.05, -0.15, 0.23), 0.015)
	for i in 3:
		k.box(root, &"dark", head + Vector3(-0.12 + i * 0.04, 0.16, 0.16), Vector3(0.01, 0.07, 0.01), Vector3(20, 0, 0))
	for i in 5:
		var a := -60.0 + i * 30.0
		k.spike(root, &"hair", head + Vector3(sin(deg_to_rad(a)) * 0.15, 0.18, -0.02), head + Vector3(sin(deg_to_rad(a)) * 0.25, 0.33, -0.1), 0.05)
	for side in [-1.0, 1.0]:
		k.limb(root, &"shirt", Vector3(0.34 * side, 1.52, 0.1), Vector3(0.36 * side, 1.47, 0.35), 0.1)
		k.limb(root, &"skin", Vector3(0.36 * side, 1.47, 0.35), Vector3(0.36 * side, 1.38, 0.78), 0.075)
		k.sphere(root, &"skin", Vector3(0.36 * side, 1.37, 0.84), 0.08)


static func _lich(k: ModelKit, root: Node3D) -> void:
	k.cyl(root, &"robe", Vector3(0, 1.25, 0), 0.45, 1.0, 2.0, Vector3.ZERO, 16)
	k.torus(root, &"trim", Vector3(0, 0.3, 0), 0.9, 1.02, Vector3.ZERO, Vector3(1, 0.4, 1))
	for i in 12:
		var a := TAU * (i + 0.5) / 12.0
		k.spike(root, &"robe", Vector3(sin(a) * 0.88, 0.32, cos(a) * 0.88), Vector3(sin(a) * 0.98, 0.0, cos(a) * 0.98), 0.14)
	k.box(root, &"robe2", Vector3(0, 1.3, 0.62), Vector3(0.4, 1.4, 0.05), Vector3(-15, 0, 0))
	k.box(root, &"trim", Vector3(0, 1.3, 0.645), Vector3(0.1, 1.4, 0.03), Vector3(-15, 0, 0))
	k.torus(root, &"trim", Vector3(0, 2.2, 0), 0.4, 0.52, Vector3.ZERO, Vector3(1, 0.5, 1))
	for side in [-1.0, 1.0]:
		k.sphere(root, &"robe2", Vector3(0.55 * side, 2.2, 0), 0.34, Vector3(1.1, 0.8, 1))
		for j in 3:
			k.spike(root, &"trim", Vector3((0.45 + j * 0.13) * side, 2.4, 0), Vector3((0.5 + j * 0.2) * side, 2.72, -0.05), 0.05)
		var hand := Vector3(0.75 * side, 1.72, 0.48)
		k.bone(root, &"robe", Vector3(0.6 * side, 2.1, 0.05), hand + Vector3(0, 0.05, -0.1), 0.14, 0.22)
		k.sphere(root, &"bone", hand, 0.09)
		for f in 3:
			k.spike(root, &"bone", hand + Vector3((f - 1) * 0.05, -0.02, 0.05), hand + Vector3((f - 1) * 0.07, -0.18, 0.16), 0.022)
	var hood := Vector3(0, 2.55, -0.05)
	k.sphere(root, &"robe2", hood, 0.46, Vector3(1, 1.1, 1))
	k.sphere(root, &"dark", hood + Vector3(0, -0.05, 0.12), 0.35)
	var skull := hood + Vector3(0, -0.06, 0.3)
	k.sphere(root, &"bone", skull, 0.27)
	k.box(root, &"bone", skull + Vector3(0, -0.2, 0.05), Vector3(0.24, 0.1, 0.2))
	k.eyes(root, skull + Vector3(0, 0.03, 0.22), 0.18, 0.055, &"glow")
	k.cyl(root, &"trim", hood + Vector3(0, 0.45, 0), 0.3, 0.32, 0.14, Vector3.ZERO, 16)
	for i in 5:
		var a := TAU * i / 5.0
		k.spike(root, &"trim", hood + Vector3(sin(a) * 0.3, 0.5, cos(a) * 0.3), hood + Vector3(sin(a) * 0.36, 0.8, cos(a) * 0.36), 0.06)
	k.sphere(root, &"glow", hood + Vector3(0, 0.5, 0.3), 0.06)
	var w := k.pivot(root, Vector3(0.75, 1.72, 0.48))
	k.limb(w, &"wood", Vector3(0, -1.35, 0), Vector3(0, 1.0, 0), 0.05)
	k.torus(w, &"trim", Vector3(0, 1.12, 0), 0.18, 0.24, Vector3(90, 0, 0))
	k.sphere(w, &"glow", Vector3(0, 1.12, 0), 0.17)
	k.parts["weapon"] = w
	for p in [Vector3(-1.1, 2.6, 0.2), Vector3(-0.9, 1.2, -0.4), Vector3(1.2, 2.8, -0.3)]:
		k.sphere(root, &"glow", p, 0.09)
