class_name EnemyChapter10
extends RefCounted
## チャプター 10「魔界」
## 雑魚: イビルアイ / ミミック / リーパー　ボス: デーモンロード（魔王）

const CHAPTER := 10
const AREA := "魔界"

const MOBS := [
	{
		"id": &"evil_eye", "idle": &"hover", "height": 1.9, "width": 2.2,
		"names": ["イビルアイ", "ブラッドアイ", "ゴールドアイ"],
		"names_en": ["EVIL EYE", "BLOOD EYE", "GOLD EYE"],
		"attack": "のろいのまなざし",
		"desc": "魔界にうかぶ巨大な目玉。見つめられると体がすくむ。",
		"palettes": [
			{&"skin": Color(0.45, 0.25, 0.55), &"iris": {"color": Color(1.0, 0.25, 0.2), "emission": 1.5}, &"eye_white": {"color": Color(1.0, 0.95, 0.92), "rough": 0.15}},
			{&"skin": Color(0.6, 0.12, 0.15), &"iris": {"color": Color(1.0, 0.85, 0.2), "emission": 1.5}, &"eye_white": {"color": Color(1.0, 0.85, 0.85), "rough": 0.15}},
			{&"skin": {"color": Color(1.0, 0.78, 0.28), "metal": 0.9, "rough": 0.25}, &"iris": {"color": Color(0.3, 0.9, 1.0), "emission": 1.8}, &"eye_white": {"color": Color(1.0, 1.0, 1.0), "rough": 0.1}},
		],
	},
	{
		"id": &"mimic", "idle": &"bounce", "height": 1.5, "width": 2.2,
		"names": ["ミミック", "シルバーミミック", "ゴールドミミック"],
		"names_en": ["MIMIC", "SILVER MIMIC", "GOLD MIMIC"],
		"attack": "かみくだき",
		"desc": "宝箱にばけた魔物。あけようとした冒険者をまるかじり。",
		"palettes": [
			{&"box": Color(0.55, 0.35, 0.18), &"band": {"color": Color(0.35, 0.35, 0.4), "metal": 0.8, "rough": 0.4}, &"eye_glow": {"color": Color(1.0, 0.85, 0.2), "emission": 3.0}},
			{&"box": Color(0.25, 0.2, 0.22), &"band": {"color": Color(0.85, 0.87, 0.92), "metal": 0.9, "rough": 0.2}, &"eye_glow": {"color": Color(0.3, 0.9, 1.0), "emission": 3.0}},
			{&"box": Color(0.7, 0.1, 0.12), &"band": {"color": Color(1.0, 0.78, 0.28), "metal": 0.9, "rough": 0.25}, &"eye_glow": {"color": Color(0.5, 1.0, 0.3), "emission": 3.0}},
		],
	},
	{
		"id": &"reaper", "idle": &"hover", "height": 2.4, "width": 2.6,
		"names": ["リーパー", "ブラッドリーパー", "ホワイトリーパー"],
		"names_en": ["REAPER", "BLOOD REAPER", "WHITE REAPER"],
		"attack": "しにがみのカマ",
		"desc": "大きなカマをもつ死神。たましいをかりとりにくる。",
		"palettes": [
			{&"robe": Color(0.12, 0.1, 0.16), &"robe2": Color(0.22, 0.2, 0.28), &"blade": {"color": Color(0.8, 0.85, 0.9), "metal": 0.9, "rough": 0.2}, &"eye_glow": {"color": Color(0.3, 1.0, 1.0), "emission": 3.5}},
			{&"robe": Color(0.45, 0.06, 0.1), &"robe2": Color(0.25, 0.04, 0.06), &"blade": {"color": Color(0.2, 0.18, 0.2), "metal": 0.9, "rough": 0.25}, &"eye_glow": {"color": Color(1.0, 0.9, 0.3), "emission": 3.5}},
			{&"robe": Color(0.92, 0.92, 0.95), &"robe2": Color(0.75, 0.72, 0.85), &"blade": {"color": Color(1.0, 0.8, 0.3), "metal": 0.9, "rough": 0.2}, &"eye_glow": {"color": Color(0.7, 0.3, 1.0), "emission": 3.5}},
		],
	},
]

const BOSS := {
	"id": &"demon_lord", "idle": &"sway", "height": 3.7, "width": 4.4,
	"names": ["デーモンロード", "ブラッドロード", "カオスロード"],
	"names_en": ["DEMON LORD", "BLOOD LORD", "CHAOS LORD"],
	"attack": "まおうのいちげき",
	"desc": "すべての魔物をしたがえる魔王。その力は世界をのみこむ。",
	"palettes": [
		{&"skin": Color(0.5, 0.35, 0.65), &"armor": {"color": Color(0.12, 0.1, 0.14), "metal": 0.8, "rough": 0.3}, &"armor2": {"color": Color(1.0, 0.78, 0.28), "metal": 0.9, "rough": 0.25}, &"cape": {"color": Color(0.6, 0.08, 0.12), "double": true}, &"horn": Color(0.2, 0.18, 0.2), &"blade": {"color": Color(0.7, 0.2, 1.0), "emission": 1.5}, &"eye_glow": {"color": Color(1.0, 0.2, 0.15), "emission": 3.5}},
		{&"skin": Color(0.7, 0.2, 0.2), &"armor": {"color": Color(0.2, 0.05, 0.06), "metal": 0.8, "rough": 0.3}, &"armor2": {"color": Color(0.75, 0.75, 0.8), "metal": 0.9, "rough": 0.25}, &"cape": {"color": Color(0.1, 0.08, 0.1), "double": true}, &"horn": Color(0.95, 0.9, 0.8), &"blade": {"color": Color(1.0, 0.3, 0.1), "emission": 1.8}, &"eye_glow": {"color": Color(1.0, 0.9, 0.3), "emission": 3.5}},
		{&"skin": Color(0.25, 0.25, 0.3), &"armor": {"color": Color(0.9, 0.9, 0.95), "metal": 0.8, "rough": 0.2}, &"armor2": {"color": Color(1.0, 0.78, 0.28), "metal": 0.9, "rough": 0.25}, &"cape": {"color": Color(0.15, 0.2, 0.5), "double": true}, &"horn": {"color": Color(1.0, 0.8, 0.3), "metal": 0.8, "rough": 0.3}, &"blade": {"color": Color(0.3, 0.9, 1.0), "emission": 2.0}, &"eye_glow": {"color": Color(0.3, 0.9, 1.0), "emission": 3.5}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"evil_eye":
			_evil_eye(k, root)
		&"mimic":
			_mimic(k, root)
		&"reaper":
			_reaper(k, root)
		&"demon_lord":
			_demon_lord(k, root)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _evil_eye(k: ModelKit, root: Node3D) -> void:
	var c := Vector3(0, 1.25, 0)
	k.sphere(root, &"eye_white", c, 0.55)
	k.stud(root, &"iris", c, Vector3(0.55, 0.55, 0.55), 0, 0, Vector3(0.3, 0.06, 0.3))
	k.stud(root, &"pupil", c, Vector3(0.575, 0.575, 0.575), 0, 0, Vector3(0.14, 0.04, 0.2))
	k.sphere(root, &"shine", c + Vector3(0.12, 0.14, 0.55), 0.05)
	var lid := k.dome(root, &"skin", c, 0.6, 0.6, Vector3(-35, 0, 0))
	lid.name = "Lid"
	for i in 5:
		k.spike_out(root, &"skin", c, Vector3(0.6, 0.6, 0.6), -60.0 + i * 30.0 + 180.0, 40.0, 0.35, 0.08)
	for i in 5:
		var a := TAU * (i + 0.5) / 5.0
		var start := c + Vector3(sin(a) * 0.3, -0.45, cos(a) * 0.3 - 0.05)
		var pts := ModelKit.curl_points(start, Vector3(sin(a) * 0.3, -1, cos(a) * 0.3), Vector3(cos(a) * 1.2, 0.4, -sin(a) * 1.2), 0.85, 4)
		k.chain(root, &"skin", pts, 0.07, 0.02)


static func _mimic(k: ModelKit, root: Node3D) -> void:
	var w := 1.1
	var d := 0.75
	k.box(root, &"box", Vector3(0, 0.33, 0), Vector3(w, 0.6, d))
	k.box(root, &"mouth", Vector3(0, 0.62, 0.02), Vector3(w - 0.1, 0.02, d - 0.1))
	for x in [-0.45, 0.45]:
		k.box(root, &"band", Vector3(x, 0.33, 0), Vector3(0.08, 0.62, d + 0.02))
	k.box(root, &"band", Vector3(0, 0.08, 0), Vector3(w + 0.02, 0.08, d + 0.02))
	for i in 7:
		var x := -0.45 + i * 0.15
		k.spike(root, &"tooth", Vector3(x, 0.6, d * 0.5 - 0.04), Vector3(x, 0.78, d * 0.5 - 0.03), 0.045)
	k.sphere(root, &"tongue", Vector3(0.05, 0.62, 0.45), 0.2, Vector3(1.0, 0.25, 1.4), Vector3(-15, 10, 0))
	var lid := k.pivot(root, Vector3(0, 0.63, -d * 0.5), Vector3(-45, 0, 0))
	k.box(lid, &"box", Vector3(0, 0.12, d * 0.5), Vector3(w, 0.2, d))
	k.cyl(lid, &"box", Vector3(0, 0.22, d * 0.5), d * 0.5, d * 0.5, w, Vector3(0, 0, 90), 12).scale = Vector3(1, 1, 0.45)
	for x in [-0.45, 0.45]:
		k.box(lid, &"band", Vector3(x, 0.2, d * 0.5), Vector3(0.08, 0.32, d + 0.02))
	for i in 7:
		var x := -0.45 + i * 0.15
		k.spike(lid, &"tooth", Vector3(x, 0.02, d - 0.04), Vector3(x, -0.16, d - 0.03), 0.045)
	k.eyes(lid, Vector3(0, -0.02, d * 0.55), 0.4, 0.07, &"glow")
	k.box(lid, &"gold", Vector3(0, 0.1, d + 0.02), Vector3(0.14, 0.18, 0.05))
	k.parts["weapon"] = lid


static func _reaper(k: ModelKit, root: Node3D) -> void:
	k.cyl(root, &"robe", Vector3(0, 1.05, 0), 0.32, 0.7, 1.6, Vector3.ZERO, 14)
	for i in 10:
		var a := TAU * (i + 0.5) / 10.0
		k.spike(root, &"robe", Vector3(sin(a) * 0.6, 0.3, cos(a) * 0.6), Vector3(sin(a) * 0.72, -0.05, cos(a) * 0.72), 0.14)
	k.sphere(root, &"robe2", Vector3(0, 1.8, -0.05), 0.42, Vector3(1.3, 0.6, 1))
	var hood := Vector3(0, 2.05, 0.02)
	k.sphere(root, &"robe", hood, 0.38, Vector3(1, 1.1, 1.05))
	k.spike(root, &"robe", hood + Vector3(0, 0.25, -0.2), hood + Vector3(0, 0.45, -0.55), 0.18)
	k.sphere(root, &"dark", hood + Vector3(0, -0.04, 0.14), 0.3, Vector3(1, 1.05, 1))
	k.eyes(root, hood + Vector3(0, 0.0, 0.46), 0.16, 0.055, &"glow")
	for side in [-1.0, 1.0]:
		var hand := Vector3(0.5 * side, 1.35, 0.4)
		k.bone(root, &"robe", Vector3(0.32 * side, 1.75, 0), hand + Vector3(0, 0.05, -0.12), 0.12, 0.18)
		k.sphere(root, &"bone", hand, 0.07)
		for f in 3:
			k.spike(root, &"bone", hand + Vector3((f - 1) * 0.04, 0, 0.04), hand + Vector3((f - 1) * 0.05, -0.12, 0.12), 0.018)
	var w := k.pivot(root, Vector3(0.5, 1.35, 0.4))
	k.limb(w, &"wood", Vector3(0, -1.1, 0), Vector3(0, 1.1, 0), 0.04)
	var blade := [Vector3(0, 1.1, 0), Vector3(0, 1.22, 0.35), Vector3(0, 1.12, 0.72), Vector3(0, 0.88, 0.98)]
	k.chain(w, &"blade", blade, 0.09, 0.01)
	k.parts["weapon"] = w


static func _demon_lord(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.limb(root, &"armor", Vector3(0.3 * side, 1.25, 0), Vector3(0.34 * side, 0.65, 0.08), 0.2)
		k.limb(root, &"armor", Vector3(0.34 * side, 0.65, 0.08), Vector3(0.34 * side, 0.18, 0), 0.17)
		k.sphere(root, &"armor2", Vector3(0.34 * side, 0.66, 0.2), 0.1)
		k.box(root, &"armor", Vector3(0.34 * side, 0.08, 0.1), Vector3(0.34, 0.16, 0.5))
	k.cyl(root, &"armor2", Vector3(0, 1.3, 0), 0.5, 0.52, 0.18, Vector3.ZERO, 16)
	k.sphere(root, &"armor", Vector3(0, 1.1, 0), 0.5, Vector3(1.05, 0.6, 0.85))
	k.sphere(root, &"skin", Vector3(0, 1.9, 0), 0.6, Vector3(1.2, 1.1, 0.85))
	k.sphere(root, &"armor", Vector3(0, 1.95, 0.12), 0.52, Vector3(1.15, 0.95, 0.75))
	k.sphere(root, &"blade", Vector3(0, 1.98, 0.5), 0.1)
	k.torus(root, &"armor2", Vector3(0, 1.98, 0.5), 0.1, 0.15, Vector3(90, 0, 0))
	k.box(root, &"cape", Vector3(0, 1.45, -0.62), Vector3(1.9, 2.4, 0.05), Vector3(-8, 0, 0))
	var head := Vector3(0, 2.75, 0.06)
	k.sphere(root, &"skin", head, 0.36)
	k.box(root, &"skin", head + Vector3(0, -0.2, 0.15), Vector3(0.42, 0.18, 0.3))
	k.eyes(root, head + Vector3(0, 0.05, 0.33), 0.24, 0.065, &"glow")
	k.box(root, &"dark", head + Vector3(0, 0.15, 0.32), Vector3(0.4, 0.05, 0.05), Vector3(0, 0, 0))
	k.box(root, &"mouth", head + Vector3(0, -0.2, 0.31), Vector3(0.24, 0.05, 0.03))
	k.cyl(root, &"armor2", head + Vector3(0, 0.33, 0), 0.28, 0.3, 0.1, Vector3.ZERO, 16)
	for i in 5:
		var a := deg_to_rad(-60.0 + i * 30.0)
		k.spike(root, &"armor2", head + Vector3(sin(a) * 0.28, 0.36, cos(a) * 0.28), head + Vector3(sin(a) * 0.3, 0.58 if i == 2 else 0.5, cos(a) * 0.3), 0.05)
	for side in [-1.0, 1.0]:
		k.spike(root, &"tooth", head + Vector3(0.1 * side, -0.26, 0.3), head + Vector3(0.1 * side, -0.14, 0.31), 0.03)
		var horn := ModelKit.curl_points(head + Vector3(0.25 * side, 0.2, -0.02), Vector3(side, 0.35, 0), Vector3(-0.6 * side, 2.2, -0.8), 1.1, 5)
		k.chain(root, &"horn", horn, 0.11, 0.02)
		k.sphere(root, &"armor", Vector3(0.78 * side, 2.3, 0), 0.38, Vector3(1.1, 0.8, 1))
		for j in 3:
			k.spike(root, &"armor2", Vector3((0.62 + j * 0.16) * side, 2.52, 0), Vector3((0.68 + j * 0.28) * side, 2.95 - j * 0.1, -0.05), 0.07)
		var p := k.pivot(root, Vector3(0.35 * side, 2.35, -0.4))
		var tip := Vector3(2.0 * side, 1.3, -0.3)
		k.bone(p, &"horn", Vector3.ZERO, tip, 0.1, 0.04)
		for j in 3:
			k.limb(p, &"horn", tip * (0.45 + j * 0.2), Vector3((0.8 + j * 0.5) * side, -0.5 + j * 0.2, -0.5), 0.035)
		k.sphere(p, &"cape", Vector3(1.1 * side, 0.3, -0.42), 1.1, Vector3(1.0, 0.65, 0.04), Vector3(0, 0, 28.0 * side))
		k.add_wing(p, side)
	k.limb(root, &"skin", Vector3(-0.85, 2.15, 0), Vector3(-1.0, 1.55, 0.2), 0.16)
	k.limb(root, &"armor", Vector3(-1.0, 1.55, 0.2), Vector3(-0.9, 1.1, 0.35), 0.15)
	k.sphere(root, &"armor", Vector3(-0.88, 1.02, 0.38), 0.17)
	var w := k.pivot(root, Vector3(0.85, 2.15, 0))
	k.limb(w, &"skin", Vector3.ZERO, Vector3(0.12, -0.6, 0.2), 0.16)
	k.limb(w, &"armor", Vector3(0.12, -0.6, 0.2), Vector3(0.1, -0.95, 0.45), 0.15)
	k.sphere(w, &"armor", Vector3(0.1, -1.02, 0.5), 0.17)
	k.box(w, &"armor2", Vector3(0.1, -1.02, 0.6), Vector3(0.5, 0.08, 0.12), Vector3(-60, 0, 0))
	k.box(w, &"blade", Vector3(0.1, -0.6, 1.4), Vector3(0.22, 1.9, 0.05), Vector3(-60, 0, 0))
	k.parts["weapon"] = w
	k.parts["wing_speed"] = 0.9
	k.parts["wing_angle"] = 14.0
