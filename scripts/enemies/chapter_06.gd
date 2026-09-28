class_name EnemyChapter06
extends RefCounted
## チャプター 6「こおりの山」
## 雑魚: スノーマン / ペンギンナイト / イエティ　ボス: マンモス

const CHAPTER := 6
const AREA := "こおりの山"

const MOBS := [
	{
		"id": &"snowman", "idle": &"bounce", "height": 1.9, "width": 2.2,
		"names": ["スノーマン", "ブリザードマン", "キャンディスノー"],
		"names_en": ["SNOWMAN", "BLIZZARD MAN", "CANDY SNOW"],
		"attack": "ゆきだまアタック",
		"desc": "雪山で生まれた雪だるま。雪玉をぶつけてくる。",
		"palettes": [
			{&"snow": {"color": Color(0.96, 0.97, 1.0), "rough": 0.9}, &"hat": Color(0.15, 0.15, 0.2), &"band": Color(0.85, 0.15, 0.15), &"scarf": Color(0.85, 0.2, 0.2), &"carrot": Color(1.0, 0.5, 0.1)},
			{&"snow": {"color": Color(0.7, 0.88, 1.0), "rough": 0.4, "emission": 0.2}, &"hat": Color(0.15, 0.25, 0.5), &"band": Color(0.9, 0.95, 1.0), &"scarf": Color(0.95, 0.97, 1.0), &"carrot": Color(0.5, 0.85, 1.0)},
			{&"snow": {"color": Color(1.0, 0.8, 0.88), "rough": 0.6}, &"hat": Color(0.5, 0.25, 0.65), &"band": Color(1.0, 0.9, 0.3), &"scarf": Color(0.45, 0.9, 0.75), &"carrot": Color(1.0, 0.4, 0.5)},
		],
	},
	{
		"id": &"penguin", "idle": &"sway", "height": 1.7, "width": 2.0,
		"names": ["ペンギンナイト", "エンペラーペンギン", "アイスペンギン"],
		"names_en": ["PENGUIN KNIGHT", "EMPEROR PENGUIN", "ICE PENGUIN"],
		"attack": "こおりのヤリ",
		"desc": "氷の城をまもるペンギンの騎士。小さな体で勇かんにたたかう。",
		"palettes": [
			{&"black": Color(0.12, 0.13, 0.18), &"white": Color(0.97, 0.97, 0.95), &"beak": Color(1.0, 0.6, 0.15)},
			{&"black": Color(0.25, 0.27, 0.35), &"white": Color(1.0, 0.95, 0.75), &"beak": Color(1.0, 0.75, 0.2), &"metal": {"color": Color(1.0, 0.8, 0.3), "metal": 0.9, "rough": 0.25}},
			{&"black": Color(0.2, 0.4, 0.75), &"white": Color(0.8, 0.93, 1.0), &"beak": Color(0.5, 0.8, 1.0), &"metal": {"color": Color(0.75, 0.9, 1.0), "metal": 0.6, "rough": 0.1, "emission": 0.3}},
		],
	},
	{
		"id": &"yeti", "idle": &"breathe", "height": 2.3, "width": 2.6,
		"names": ["イエティ", "ブラウンイエティ", "シャドウイエティ"],
		"names_en": ["YETI", "BROWN YETI", "SHADOW YETI"],
		"attack": "ふぶきパンチ",
		"desc": "雪山にすむ毛むくじゃらの大男。ふぶきとともにあらわれる。",
		"palettes": [
			{&"fur": {"color": Color(0.95, 0.96, 1.0), "rough": 1.0}, &"fur2": Color(0.82, 0.86, 0.95), &"skin": Color(0.45, 0.65, 0.9), &"horn": Color(0.9, 0.88, 0.8)},
			{&"fur": {"color": Color(0.55, 0.4, 0.28), "rough": 1.0}, &"fur2": Color(0.45, 0.32, 0.22), &"skin": Color(0.85, 0.7, 0.55), &"horn": Color(0.3, 0.25, 0.2)},
			{&"fur": {"color": Color(0.32, 0.36, 0.48), "rough": 1.0}, &"fur2": Color(0.22, 0.25, 0.35), &"skin": Color(0.6, 0.4, 0.75), &"horn": {"color": Color(0.5, 0.9, 1.0), "emission": 1.0}},
		],
	},
]

const BOSS := {
	"id": &"mammoth", "idle": &"breathe", "height": 3.4, "width": 4.2,
	"names": ["マンモス", "アイスマンモス", "マグママンモス"],
	"names_en": ["MAMMOTH", "ICE MAMMOTH", "MAGMA MAMMOTH"],
	"attack": "キバとっしん",
	"desc": "氷河の時代から生きる巨獣。長いキバで何でもつきとばす。",
	"palettes": [
		{&"fur": {"color": Color(0.5, 0.33, 0.2), "rough": 1.0}, &"fur2": Color(0.38, 0.24, 0.15), &"tusk": Color(0.97, 0.93, 0.82), &"skin": Color(0.35, 0.28, 0.25)},
		{&"fur": {"color": Color(0.88, 0.93, 1.0), "rough": 1.0}, &"fur2": Color(0.6, 0.75, 0.9), &"tusk": {"color": Color(0.6, 0.9, 1.0), "emission": 0.8, "rough": 0.1}, &"skin": Color(0.4, 0.5, 0.65)},
		{&"fur": {"color": Color(0.16, 0.12, 0.12), "rough": 0.9}, &"fur2": {"color": Color(1.0, 0.35, 0.05), "emission": 2.0}, &"tusk": {"color": Color(1.0, 0.6, 0.2), "emission": 1.0}, &"skin": Color(0.2, 0.15, 0.15)},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"snowman":
			_snowman(k, root)
		&"penguin":
			_penguin(k, root)
		&"yeti":
			_yeti(k, root)
		&"mammoth":
			_mammoth(k, root)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _snowman(k: ModelKit, root: Node3D) -> void:
	k.sphere(root, &"snow", Vector3(0, 0.46, 0), 0.5)
	k.sphere(root, &"snow", Vector3(0, 1.08, 0), 0.38)
	var head := Vector3(0, 1.55, 0.02)
	k.sphere(root, &"snow", head, 0.29)
	k.cyl(root, &"hat", head + Vector3(0, 0.18, -0.02), 0.34, 0.34, 0.05, Vector3(-8, 0, 0), 20)
	k.cyl(root, &"hat", head + Vector3(0, 0.38, -0.05), 0.22, 0.23, 0.38, Vector3(-8, 0, 0), 20)
	k.cyl(root, &"band", head + Vector3(0, 0.24, -0.03), 0.235, 0.235, 0.08, Vector3(-8, 0, 0), 20)
	k.eyes(root, head + Vector3(0, 0.07, 0.26), 0.18, 0.045, &"dot")
	k.spike(root, &"carrot", head + Vector3(0, -0.02, 0.24), head + Vector3(0, -0.06, 0.58), 0.06)
	for i in 5:
		var a := deg_to_rad(-40.0 + i * 20.0)
		k.sphere(root, &"pupil", head + Vector3(sin(a) * 0.14, -0.13 - cos(a) * 0.03 + 0.03, 0.26), 0.02)
	k.torus(root, &"scarf", Vector3(0, 1.36, 0), 0.2, 0.34, Vector3(5, 0, 0), Vector3(1, 0.7, 1))
	k.box(root, &"scarf", Vector3(0.2, 1.1, 0.3), Vector3(0.14, 0.42, 0.05), Vector3(-15, 0, 12))
	for y in [1.2, 1.02, 0.84]:
		k.sphere(root, &"pupil", Vector3(0, y, 0.37), 0.035)
	for side in [-1.0, 1.0]:
		var hand := Vector3(0.82 * side, 1.42, 0.1)
		k.limb(root, &"wood", Vector3(0.32 * side, 1.15, 0), hand, 0.03)
		k.limb(root, &"wood", hand + Vector3(-0.15 * side, -0.05, 0), hand + Vector3(-0.05 * side, 0.18, 0.02), 0.02)
		k.limb(root, &"wood", hand, hand + Vector3(0.12 * side, 0.1, 0), 0.02)


static func _penguin(k: ModelKit, root: Node3D) -> void:
	var c := Vector3(0, 0.78, 0)
	k.sphere(root, &"black", c, 0.45, Vector3(1, 1.4, 0.95))
	k.sphere(root, &"white", c + Vector3(0, -0.05, 0.13), 0.38, Vector3(1, 1.35, 0.9))
	var head := Vector3(0, 1.22, 0.05)
	k.eyes(root, head + Vector3(0, 0.02, 0.33), 0.22, 0.075)
	k.spike(root, &"beak", head + Vector3(0, -0.1, 0.3), head + Vector3(0, -0.13, 0.6), 0.08)
	for side in [-1.0, 1.0]:
		k.sphere(root, &"blush", head + Vector3(0.2 * side, -0.1, 0.3), 0.05, Vector3(1.2, 0.6, 0.4))
		k.sphere(root, &"beak", Vector3(0.15 * side, 0.04, 0.2), 0.12, Vector3(1, 0.35, 1.4))
	k.limb(root, &"black", Vector3(-0.4, 1.0, 0), Vector3(-0.62, 0.6, 0.08), 0.08)
	k.dome(root, &"metal", Vector3(0, 1.4, -0.02), 0.4, 0.32)
	k.spike(root, &"metal", Vector3(0, 1.7, -0.02), Vector3(0, 1.95, -0.05), 0.06)
	k.box(root, &"metal", Vector3(0, 1.42, 0.36), Vector3(0.1, 0.08, 0.08))
	var w := k.pivot(root, Vector3(0.45, 0.95, 0.1))
	k.limb(w, &"black", Vector3.ZERO, Vector3(0.12, -0.3, 0.1), 0.08)
	k.limb(w, &"wood", Vector3(0.15, -0.6, 0.2), Vector3(0.15, 0.9, 0.35), 0.03)
	k.spike(w, &"metal", Vector3(0.15, 0.88, 0.35), Vector3(0.15, 1.2, 0.38), 0.07)
	k.parts["weapon"] = w


static func _yeti(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.limb(root, &"fur", Vector3(0.3 * side, 0.85, 0), Vector3(0.33 * side, 0.15, 0.05), 0.2)
		k.sphere(root, &"skin", Vector3(0.33 * side, 0.06, 0.15), 0.17, Vector3(1, 0.5, 1.4))
	var body := Vector3(0, 1.38, 0)
	var radii := Vector3(0.72, 0.82, 0.62)
	k.sphere(root, &"fur", body, 0.72, Vector3(1, 1.14, 0.86))
	for el in [-40.0, -10.0, 20.0, 50.0]:
		for i in 8:
			var az: float = i * 45.0 + el
			k.stud(root, &"fur2", body, radii, az, el, Vector3(0.14, 0.1, 0.14))
	var head := Vector3(0, 2.12, 0.18)
	k.sphere(root, &"fur", head, 0.4)
	k.sphere(root, &"skin", head + Vector3(0, -0.04, 0.24), 0.27, Vector3(1, 0.9, 0.6))
	k.eyes(root, head + Vector3(0, 0.05, 0.38), 0.18, 0.06, &"angry", &"fur2")
	k.sphere(root, &"mouth", head + Vector3(0, -0.13, 0.38), 0.08, Vector3(1.6, 0.8, 0.5))
	for side in [-1.0, 1.0]:
		k.spike(root, &"tooth", head + Vector3(0.08 * side, -0.1, 0.4), head + Vector3(0.08 * side, -0.02, 0.42), 0.025)
		k.spike(root, &"horn", head + Vector3(0.28 * side, 0.25, -0.05), head + Vector3(0.42 * side, 0.55, -0.1), 0.08)
		var shoulder := Vector3(0.66 * side, 1.78, 0)
		var elbow := Vector3(0.9 * side, 1.15, 0.2)
		k.limb(root, &"fur", shoulder, elbow, 0.19)
		k.limb(root, &"fur", elbow, Vector3(0.9 * side, 0.6, 0.35), 0.17)
		k.sphere(root, &"skin", Vector3(0.9 * side, 0.5, 0.38), 0.18)


static func _mammoth(k: ModelKit, root: Node3D) -> void:
	var body := Vector3(0, 1.95, -0.35)
	k.sphere(root, &"fur", body, 1.1, Vector3(1, 0.95, 1.3))
	k.sphere(root, &"fur", Vector3(0, 2.7, -0.05), 0.62)
	for i in 14:
		var a := TAU * i / 14.0
		k.spike(root, &"fur2", body + Vector3(sin(a) * 1.0, -0.55, cos(a) * 1.25), body + Vector3(sin(a) * 1.1, -1.05, cos(a) * 1.35), 0.18)
	for p in [Vector3(0.58, 0.72, 0.35), Vector3(-0.58, 0.72, 0.35), Vector3(0.58, 0.72, -1.05), Vector3(-0.58, 0.72, -1.05)]:
		k.cyl(root, &"fur", p, 0.3, 0.34, 1.45, Vector3.ZERO, 12)
		for t in 3:
			k.sphere(root, &"tusk", p + Vector3((t - 1) * 0.14, -0.66, 0.28), 0.07, Vector3(1, 0.7, 0.6))
	var head := Vector3(0, 2.35, 0.78)
	k.sphere(root, &"fur", head, 0.62)
	k.sphere(root, &"fur", head + Vector3(0, 0.35, -0.1), 0.42)
	k.eyes(root, head + Vector3(0, 0.12, 0.52), 0.52, 0.07, &"angry", &"fur2")
	for side in [-1.0, 1.0]:
		k.sphere(root, &"fur2", head + Vector3(0.62 * side, -0.05, -0.2), 0.48, Vector3(0.22, 1.0, 0.9))
		var tusk := ModelKit.curl_points(head + Vector3(0.24 * side, -0.38, 0.4), Vector3(0.35 * side, -0.55, 1.0), Vector3(-0.1 * side, 2.6, 0.2), 1.45, 5)
		k.chain(root, &"tusk", tusk, 0.1, 0.02)
	var trunk := ModelKit.curl_points(head + Vector3(0, -0.15, 0.55), Vector3(0, -0.45, 1), Vector3(0, -2.2, -0.6), 1.7, 6)
	k.chain(root, &"skin", trunk, 0.2, 0.08)
	var tail := k.pivot(root, body + Vector3(0, 0.1, -1.4))
	k.chain(tail, &"fur2", ModelKit.curl_points(Vector3.ZERO, Vector3(0, -0.6, -1), Vector3(0, -1.0, 0), 0.6, 3), 0.08, 0.1)
	k.parts["tail"] = tail
