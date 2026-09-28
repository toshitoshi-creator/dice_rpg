class_name EnemyChapter02
extends RefCounted
## チャプター 2「ゴブリンの森」
## 雑魚: ゴブリン / ウルフ / トレント　ボス: オーガ

const CHAPTER := 2
const AREA := "ゴブリンの森"

const MOBS := [
	{
		"id": &"goblin", "idle": &"sway", "height": 1.8, "width": 2.2,
		"names": ["ゴブリン", "レッドゴブリン", "シャドウゴブリン"],
		"names_en": ["GOBLIN", "RED GOBLIN", "SHADOW GOBLIN"],
		"attack": "こんぼう攻撃",
		"desc": "森にすむ小鬼。こんぼうをふりまわして旅人をおそう。",
		"palettes": [
			{&"skin": Color(0.46, 0.66, 0.26), &"cloth": Color(0.42, 0.26, 0.14), &"eye_glow": {"color": Color(1.0, 0.85, 0.1), "emission": 1.5}},
			{&"skin": Color(0.78, 0.3, 0.2), &"cloth": Color(0.25, 0.2, 0.3), &"eye_glow": {"color": Color(1.0, 0.95, 0.4), "emission": 1.5}},
			{&"skin": Color(0.35, 0.3, 0.5), &"cloth": Color(0.12, 0.1, 0.14), &"eye_glow": {"color": Color(0.9, 0.2, 1.0), "emission": 2.5}},
		],
	},
	{
		"id": &"wolf", "idle": &"breathe", "height": 1.5, "width": 2.4,
		"names": ["グレイウルフ", "ブラッドウルフ", "シルバーウルフ"],
		"names_en": ["GRAY WOLF", "BLOOD WOLF", "SILVER WOLF"],
		"attack": "かみつき",
		"desc": "群れで狩りをするオオカミ。するどい牙をもつ。",
		"palettes": [
			{&"fur": Color(0.5, 0.5, 0.55), &"fur2": Color(0.82, 0.8, 0.78), &"eye_glow": {"color": Color(1.0, 0.8, 0.2), "emission": 2.0}},
			{&"fur": Color(0.45, 0.1, 0.1), &"fur2": Color(0.15, 0.08, 0.08), &"eye_glow": {"color": Color(1.0, 0.2, 0.1), "emission": 3.0}},
			{&"fur": {"color": Color(0.88, 0.9, 0.95), "rim": 0.4}, &"fur2": Color(0.65, 0.72, 0.85), &"eye_glow": {"color": Color(0.3, 0.8, 1.0), "emission": 3.0}},
		],
	},
	{
		"id": &"treant", "idle": &"sway", "height": 2.1, "width": 2.4,
		"names": ["トレント", "オータムトレント", "ダークトレント"],
		"names_en": ["TREANT", "AUTUMN TREANT", "DARK TREANT"],
		"attack": "えだムチ",
		"desc": "長い年月をへて動きだした古木。えだをムチのようにふるう。",
		"palettes": [
			{&"bark": Color(0.45, 0.3, 0.17), &"bark2": Color(0.3, 0.2, 0.1), &"leaf": Color(0.25, 0.6, 0.22), &"fruit": Color(0.9, 0.15, 0.15), &"eye_glow": {"color": Color(1.0, 0.9, 0.3), "emission": 2.0}},
			{&"bark": Color(0.5, 0.32, 0.2), &"bark2": Color(0.32, 0.2, 0.12), &"leaf": Color(0.95, 0.5, 0.12), &"fruit": Color(0.8, 0.2, 0.1), &"eye_glow": {"color": Color(1.0, 0.6, 0.2), "emission": 2.0}},
			{&"bark": Color(0.18, 0.14, 0.16), &"bark2": Color(0.1, 0.08, 0.1), &"leaf": Color(0.45, 0.2, 0.6), &"fruit": {"color": Color(0.3, 1.0, 0.4), "emission": 1.5}, &"eye_glow": {"color": Color(0.4, 1.0, 0.4), "emission": 3.0}},
		],
	},
]

const BOSS := {
	"id": &"ogre", "idle": &"sway", "height": 3.3, "width": 3.8,
	"names": ["オーガ", "ブラッドオーガ", "ストーンオーガ"],
	"names_en": ["OGRE", "BLOOD OGRE", "STONE OGRE"],
	"attack": "トゲこんぼう",
	"desc": "森のぬし。巨大なトゲこんぼうで木々ごとなぎはらう。",
	"palettes": [
		{&"skin": Color(0.55, 0.62, 0.3), &"cloth": Color(0.4, 0.28, 0.16), &"horn": Color(0.95, 0.9, 0.78)},
		{&"skin": Color(0.72, 0.22, 0.18), &"cloth": Color(0.2, 0.15, 0.15), &"horn": Color(0.2, 0.18, 0.18)},
		{&"skin": {"color": Color(0.55, 0.55, 0.58), "rough": 0.95}, &"cloth": Color(0.3, 0.3, 0.45), &"horn": {"color": Color(0.4, 0.8, 1.0), "emission": 0.6}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"goblin":
			_goblin(k, root)
		&"wolf":
			_wolf(k, root)
		&"treant":
			_treant(k, root)
		&"ogre":
			_ogre(k, root)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _goblin(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.limb(root, &"skin", Vector3(0.15 * side, 0.55, 0), Vector3(0.17 * side, 0.1, 0.02), 0.1)
		k.box(root, &"dark", Vector3(0.17 * side, 0.04, 0.07), Vector3(0.18, 0.08, 0.28))
	k.capsule(root, &"skin", Vector3(0, 0.82, 0), 0.32, 0.8)
	k.cyl(root, &"cloth", Vector3(0, 0.56, 0), 0.34, 0.4, 0.32)
	k.box(root, &"leather", Vector3(0, 0.9, 0.22), Vector3(0.7, 0.08, 0.1), Vector3(0, 0, -35))
	var head := Vector3(0, 1.42, 0.02)
	k.sphere(root, &"skin", head, 0.33)
	for side in [-1.0, 1.0]:
		k.spike(root, &"skin", head + Vector3(0.26 * side, 0.08, -0.02), head + Vector3(0.62 * side, 0.2, -0.08), 0.1)
		k.sphere(root, &"eye_glow", head + Vector3(0.13 * side, 0.08, 0.27), 0.08)
		k.sphere(root, &"pupil", head + Vector3(0.13 * side, 0.08, 0.34), 0.035)
		k.spike(root, &"tooth", head + Vector3(0.08 * side, -0.14, 0.29), head + Vector3(0.08 * side, -0.24, 0.3), 0.03)
		k.box(root, &"dark", head + Vector3(0.13 * side, 0.2, 0.28), Vector3(0.16, 0.04, 0.04), Vector3(0, 0, 20.0 * side))
	k.sphere(root, &"skin", head + Vector3(0, 0, 0.33), 0.08)
	k.box(root, &"mouth", head + Vector3(0, -0.13, 0.29), Vector3(0.26, 0.04, 0.05))
	k.limb(root, &"skin", Vector3(-0.38, 1.05, 0.02), Vector3(-0.48, 0.65, 0.12), 0.08)
	var w := k.pivot(root, Vector3(0.4, 1.02, 0.05))
	k.limb(w, &"skin", Vector3.ZERO, Vector3(0.05, -0.38, 0.05), 0.08)
	k.bone(w, &"wood", Vector3(0.05, -0.42, -0.05), Vector3(0.05, -0.2, 0.75), 0.05, 0.08)
	k.bone(w, &"wood", Vector3(0.05, -0.28, 0.5), Vector3(0.05, -0.12, 0.95), 0.13, 0.17)
	for i in 3:
		k.spike(w, &"metal", Vector3(0.05 + (i - 1) * 0.12, -0.08, 0.8), Vector3(0.05 + (i - 1) * 0.2, 0.08, 0.85), 0.04)
	k.parts["weapon"] = w


static func _wolf(k: ModelKit, root: Node3D) -> void:
	k.capsule(root, &"fur", Vector3(0, 0.78, -0.1), 0.33, 1.35, Vector3(90, 0, 0))
	k.sphere(root, &"fur", Vector3(0, 0.85, 0.38), 0.4, Vector3(1, 1.05, 1))
	k.sphere(root, &"fur2", Vector3(0, 0.66, 0.15), 0.3, Vector3(0.9, 0.8, 1.4))
	for i in 5:
		var a := -60.0 + i * 30.0
		k.spike(root, &"fur", Vector3(sin(deg_to_rad(a)) * 0.3, 1.02, 0.4), Vector3(sin(deg_to_rad(a)) * 0.5, 1.15, 0.2), 0.12)
	k.limb(root, &"fur", Vector3(0, 0.95, 0.45), Vector3(0, 1.12, 0.72), 0.22)
	var head := Vector3(0, 1.18, 0.82)
	k.sphere(root, &"fur", head, 0.27)
	k.limb(root, &"fur2", head + Vector3(0, -0.08, 0.12), head + Vector3(0, -0.12, 0.42), 0.12)
	k.sphere(root, &"dark", head + Vector3(0, -0.07, 0.56), 0.065)
	for side in [-1.0, 1.0]:
		k.spike(root, &"fur", head + Vector3(0.13 * side, 0.17, -0.04), head + Vector3(0.2 * side, 0.46, -0.08), 0.085)
		k.sphere(root, &"eye_glow", head + Vector3(0.12 * side, 0.07, 0.22), 0.05)
		k.spike(root, &"tooth", head + Vector3(0.06 * side, -0.2, 0.42), head + Vector3(0.06 * side, -0.3, 0.44), 0.025)
		# 脚
		for z in [0.42, -0.62]:
			k.limb(root, &"fur", Vector3(0.21 * side, 0.72, z), Vector3(0.23 * side, 0.1, z + 0.05), 0.095)
			k.sphere(root, &"fur2", Vector3(0.23 * side, 0.07, z + 0.1), 0.1, Vector3(1, 0.6, 1.3))
	var tail := k.pivot(root, Vector3(0, 0.9, -0.75))
	k.chain(tail, &"fur", ModelKit.curl_points(Vector3.ZERO, Vector3(0, 0.5, -1), Vector3(0, 1.2, 0), 0.75, 4), 0.13, 0.05)
	k.parts["tail"] = tail


static func _treant(k: ModelKit, root: Node3D) -> void:
	for a in [35.0, 145.0, 215.0, 325.0]:
		var d := Vector3(sin(deg_to_rad(a)), 0, cos(deg_to_rad(a)))
		k.bone(root, &"bark2", d * 0.3 + Vector3(0, 0.35, 0), d * 0.75 + Vector3(0, 0.02, 0), 0.17, 0.06)
	k.cyl(root, &"bark", Vector3(0, 0.9, 0), 0.38, 0.5, 1.5, Vector3.ZERO, 12)
	var c := Vector3(0, 0.9, 0)
	for s in [[30, -10, 0.1], [-50, 20, 0.08], [160, 5, 0.12], [-140, -20, 0.09], [90, 30, 0.07]]:
		k.stud(root, &"bark2", c, Vector3(0.44, 0.75, 0.44), s[0], s[1], Vector3(s[2], s[2], 0.04))
	for side in [-1.0, 1.0]:
		k.sphere(root, &"dark", Vector3(0.14 * side, 1.2, 0.36), 0.1, Vector3(1, 0.8, 0.5))
		k.sphere(root, &"eye_glow", Vector3(0.14 * side, 1.2, 0.41), 0.055)
		k.box(root, &"bark2", Vector3(0.15 * side, 1.35, 0.4), Vector3(0.2, 0.06, 0.06), Vector3(0, 0, 18.0 * side))
		var elbow := Vector3(0.8 * side, 1.0, 0.2)
		k.bone(root, &"bark", Vector3(0.35 * side, 1.25, 0), elbow, 0.12, 0.08)
		k.bone(root, &"bark", elbow, Vector3(0.95 * side, 1.35, 0.35), 0.08, 0.04)
		k.bone(root, &"bark", elbow, Vector3(1.05 * side, 0.85, 0.35), 0.06, 0.03)
		k.sphere(root, &"leaf", Vector3(0.95 * side, 1.4, 0.35), 0.17)
	k.box(root, &"dark", Vector3(0, 0.9, 0.42), Vector3(0.32, 0.12, 0.06))
	for s in [[Vector3(0, 2.0, 0), 0.6], [Vector3(0.45, 1.8, -0.1), 0.45], [Vector3(-0.45, 1.82, -0.05), 0.45], [Vector3(0, 1.85, -0.4), 0.5], [Vector3(0.1, 2.35, -0.1), 0.35]]:
		k.sphere(root, &"leaf", s[0], s[1], Vector3.ONE, Vector3.ZERO, 12)
	for p in [Vector3(0.3, 1.9, 0.42), Vector3(-0.35, 2.05, 0.38), Vector3(0.05, 2.3, 0.3)]:
		k.sphere(root, &"fruit", p, 0.09)


static func _ogre(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.limb(root, &"skin", Vector3(0.35 * side, 0.95, 0), Vector3(0.4 * side, 0.2, 0.05), 0.22)
		k.box(root, &"dark", Vector3(0.4 * side, 0.08, 0.12), Vector3(0.36, 0.16, 0.5))
	k.cyl(root, &"cloth", Vector3(0, 1.08, 0), 0.62, 0.72, 0.5, Vector3.ZERO, 10)
	k.torus(root, &"leather", Vector3(0, 1.3, 0), 0.55, 0.66, Vector3.ZERO, Vector3(1, 0.6, 1))
	k.sphere(root, &"skin", Vector3(0, 1.55, 0.08), 0.72, Vector3(1, 1.0, 0.95))
	k.sphere(root, &"skin", Vector3(0, 2.05, -0.05), 0.66, Vector3(1.25, 0.8, 0.85))
	var head := Vector3(0, 2.62, 0.12)
	k.sphere(root, &"skin", head, 0.38)
	k.box(root, &"skin", head + Vector3(0, -0.2, 0.18), Vector3(0.5, 0.2, 0.3))
	k.eyes(root, head + Vector3(0, 0.07, 0.33), 0.26, 0.07, &"angry")
	k.sphere(root, &"skin", head + Vector3(0, -0.04, 0.38), 0.08, Vector3(1.2, 0.8, 1))
	k.spike(root, &"horn", head + Vector3(0, 0.3, 0.05), head + Vector3(0, 0.72, 0.18), 0.1)
	for side in [-1.0, 1.0]:
		k.spike(root, &"horn", head + Vector3(0.14 * side, -0.24, 0.34), head + Vector3(0.18 * side, -0.02, 0.44), 0.05)
		k.sphere(root, &"skin", Vector3(0.78 * side, 2.2, 0), 0.32)
		k.dome(root, &"metal", Vector3(0.78 * side, 2.28, 0), 0.34, 0.25, Vector3(0, 0, -20.0 * side))
		for j in 2:
			k.spike(root, &"metal", Vector3((0.72 + j * 0.15) * side, 2.45, 0), Vector3((0.8 + j * 0.25) * side, 2.75, 0), 0.06)
	k.limb(root, &"skin", Vector3(-0.85, 2.1, 0), Vector3(-1.0, 1.55, 0.18), 0.18)
	k.limb(root, &"skin", Vector3(-1.0, 1.55, 0.18), Vector3(-0.95, 1.1, 0.35), 0.16)
	k.sphere(root, &"skin", Vector3(-0.95, 1.0, 0.38), 0.2)
	var w := k.pivot(root, Vector3(0.85, 2.1, 0))
	k.limb(w, &"skin", Vector3.ZERO, Vector3(0.12, -0.55, 0.18), 0.18)
	k.limb(w, &"skin", Vector3(0.12, -0.55, 0.18), Vector3(0.12, -0.95, 0.4), 0.16)
	k.sphere(w, &"skin", Vector3(0.12, -1.02, 0.45), 0.2)
	k.bone(w, &"wood", Vector3(0.12, -1.1, 0.3), Vector3(0.12, -0.4, 1.4), 0.08, 0.1)
	k.bone(w, &"wood", Vector3(0.12, -0.65, 1.0), Vector3(0.12, -0.25, 1.7), 0.22, 0.28)
	for i in 6:
		var a := i * 60.0
		k.spike_out(w, &"metal", Vector3(0.12, -0.45, 1.35), Vector3(0.26, 0.26, 0.26), a, 0.0 if i % 2 == 0 else 35.0, 0.18, 0.06)
	k.parts["weapon"] = w
