class_name EnemyChapter14
extends RefCounted
## チャプター 14「ゆうれい船」
## 雑魚: ガイコツかいぞく / ヤドカリ / オウム　ボス: ゆうれいせんちょう

const CHAPTER := 14
const AREA := "ゆうれい船"

const MOBS := [
	{
		"id": &"pirate", "idle": &"sway", "height": 1.8, "width": 2.2,
		"names": ["ガイコツかいぞく", "あかひげかいぞく", "ゆうれいかいぞく"],
		"names_en": ["SKULL PIRATE", "RED PIRATE", "GHOST PIRATE"],
		"attack": "カトラスぎり",
		"desc": "ゆうれい船ではたらくガイコツの海賊。こしのカトラスがじまん。",
		"palettes": [
			{&"cloth": Color(0.2, 0.25, 0.45), &"bandana": Color(0.85, 0.15, 0.15), &"eye_glow": {"color": Color(0.3, 1.0, 0.6), "emission": 3.0}},
			{&"cloth": Color(0.55, 0.12, 0.12), &"bandana": Color(0.1, 0.1, 0.12), &"eye_glow": {"color": Color(1.0, 0.4, 0.1), "emission": 3.0}},
			{&"cloth": {"color": Color(0.4, 0.8, 0.8, 0.7), "emission": 0.5}, &"bandana": {"color": Color(0.6, 1.0, 0.9, 0.7), "emission": 0.6}, &"eye_glow": {"color": Color(0.6, 1.0, 1.0), "emission": 3.5}},
		],
	},
	{
		"id": &"hermit_crab", "idle": &"breathe", "height": 1.4, "width": 2.4,
		"names": ["ヤドカリ", "サンゴヤドカリ", "ほうせきヤドカリ"],
		"names_en": ["HERMIT CRAB", "CORAL HERMIT", "JEWEL HERMIT"],
		"attack": "はさみうち",
		"desc": "大きなまき貝を背負ったヤドカリ。貝の中はふかふか。",
		"palettes": [
			{&"shell": Color(0.9, 0.8, 0.65), &"shell2": Color(0.75, 0.55, 0.4), &"crab": Color(0.9, 0.35, 0.2)},
			{&"shell": Color(1.0, 0.55, 0.6), &"shell2": Color(0.9, 0.3, 0.45), &"crab": Color(0.95, 0.6, 0.2)},
			{&"shell": {"color": Color(0.5, 0.85, 1.0), "rough": 0.1, "clearcoat": 1.0, "emission": 0.3}, &"shell2": {"color": Color(0.8, 0.5, 1.0), "rough": 0.1, "emission": 0.3}, &"crab": Color(0.35, 0.3, 0.6)},
		],
	},
	{
		"id": &"parrot", "idle": &"hover", "height": 1.6, "width": 2.4,
		"names": ["オウム", "ブルーオウム", "ゴールドオウム"],
		"names_en": ["PARROT", "BLUE PARROT", "GOLD PARROT"],
		"attack": "くちばしつつき",
		"desc": "船長のかたにとまるおしゃべりなオウム。悪口もおぼえている。",
		"palettes": [
			{&"feather": Color(0.9, 0.15, 0.15), &"feather2": Color(1.0, 0.8, 0.1), &"feather3": Color(0.15, 0.4, 0.9), &"beak": Color(0.95, 0.9, 0.8)},
			{&"feather": Color(0.15, 0.45, 0.95), &"feather2": Color(1.0, 0.85, 0.2), &"feather3": Color(0.2, 0.75, 0.4), &"beak": Color(0.2, 0.2, 0.22)},
			{&"feather": {"color": Color(1.0, 0.8, 0.3), "metal": 0.7, "rough": 0.3}, &"feather2": Color(1.0, 0.95, 0.8), &"feather3": Color(0.9, 0.3, 0.5), &"beak": Color(0.3, 0.25, 0.2)},
		],
	},
]

const BOSS := {
	"id": &"ghost_captain", "idle": &"hover", "height": 3.6, "width": 3.8,
	"names": ["ゆうれいせんちょう", "のろいのせんちょう", "かいぞくおう"],
	"names_en": ["GHOST CAPTAIN", "CURSED CAPTAIN", "PIRATE KING"],
	"attack": "たいほうぶっぱ",
	"desc": "しずんだ船をあやつる海賊の船長。いかりのついたくさりをふりまわす。",
	"palettes": [
		{&"coat": Color(0.15, 0.2, 0.4), &"trim": {"color": Color(1.0, 0.8, 0.3), "metal": 0.9, "rough": 0.3}, &"ghost": {"color": Color(0.6, 0.95, 0.9, 0.75), "emission": 0.7}, &"hat": Color(0.1, 0.1, 0.12), &"eye_glow": {"color": Color(0.4, 1.0, 0.7), "emission": 3.0}},
		{&"coat": Color(0.5, 0.08, 0.1), &"trim": {"color": Color(0.7, 0.7, 0.75), "metal": 0.9, "rough": 0.3}, &"ghost": {"color": Color(0.7, 0.5, 0.95, 0.75), "emission": 0.8}, &"hat": Color(0.25, 0.05, 0.08), &"eye_glow": {"color": Color(1.0, 0.3, 0.5), "emission": 3.0}},
		{&"coat": Color(0.1, 0.1, 0.1), &"trim": {"color": Color(1.0, 0.85, 0.35), "metal": 1.0, "rough": 0.15}, &"ghost": {"color": Color(1.0, 0.85, 0.5, 0.75), "emission": 1.0}, &"hat": Color(0.8, 0.1, 0.1), &"eye_glow": {"color": Color(1.0, 0.85, 0.2), "emission": 3.5}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"pirate":
			_pirate(k, root)
		&"hermit_crab":
			_hermit(k, root)
		&"parrot":
			_parrot(k, root)
		&"ghost_captain":
			_captain(k, root)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _pirate(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.limb(root, &"bone", Vector3(0.14 * side, 0.7, 0), Vector3(0.16 * side, 0.1, 0.05), 0.05)
		k.box(root, &"dark", Vector3(0.16 * side, 0.05, 0.08), Vector3(0.14, 0.1, 0.26))
	k.cyl(root, &"cloth", Vector3(0, 0.72, 0), 0.26, 0.3, 0.3)
	# 肋骨
	k.cyl(root, &"bone", Vector3(0, 1.0, 0), 0.06, 0.06, 0.5)
	for i in 3:
		k.torus(root, &"bone", Vector3(0, 0.9 + i * 0.12, 0), 0.16, 0.2, Vector3.ZERO, Vector3(1, 1, 0.8))
	var head := Vector3(0, 1.45, 0.02)
	k.sphere(root, &"bone", head, 0.27, Vector3(1, 1, 1.05))
	k.box(root, &"bone", head + Vector3(0, -0.2, 0.08), Vector3(0.3, 0.12, 0.25))
	for side in [-1.0, 1.0]:
		k.sphere(root, &"dark", head + Vector3(0.1 * side, 0.02, 0.22), 0.08, Vector3(1, 1, 0.5))
		k.sphere(root, &"eye_glow", head + Vector3(0.1 * side, 0.02, 0.25), 0.035)
	for x in [-0.08, 0, 0.08]:
		k.box(root, &"tooth", head + Vector3(x, -0.2, 0.21), Vector3(0.05, 0.06, 0.02))
	k.dome(root, &"bandana", head + Vector3(0, 0.08, 0), 0.29, 0.2)
	k.sphere(root, &"bandana", head + Vector3(0.2, 0.1, -0.25), 0.07)
	k.limb(root, &"bone", Vector3(-0.28, 1.15, 0), Vector3(-0.4, 0.8, 0.12), 0.04)
	var w := k.pivot(root, Vector3(0.28, 1.15, 0))
	k.limb(w, &"bone", Vector3.ZERO, Vector3(0.12, -0.35, 0.1), 0.04)
	k.box(w, &"gold", Vector3(0.12, -0.38, 0.12), Vector3(0.18, 0.04, 0.08))
	k.bone(w, &"metal", Vector3(0.12, -0.38, 0.15), Vector3(0.18, -0.25, 0.75), 0.05, 0.02)
	k.parts["weapon"] = w


static func _hermit(k: ModelKit, root: Node3D) -> void:
	# まき貝
	for i in 4:
		var r := 0.55 - i * 0.12
		k.sphere(root, &"shell" if i % 2 == 0 else &"shell2", Vector3(0, 0.6 + i * 0.28, -0.25 - i * 0.05), r, Vector3(1, 0.75, 1))
	k.cone(root, &"shell2", Vector3(0, 1.75, -0.45), 0.12, 0.35, Vector3(-20, 0, 0))
	# 体とはさみ
	k.sphere(root, &"crab", Vector3(0, 0.4, 0.35), 0.3, Vector3(1.2, 0.8, 1))
	k.eyes(root, Vector3(0, 0.62, 0.52), 0.24, 0.07, &"dot")
	for side in [-1.0, 1.0]:
		k.limb(root, &"crab", Vector3(0.1 * side, 0.55, 0.45), Vector3(0.12 * side, 0.68, 0.5), 0.025)
		k.limb(root, &"crab", Vector3(0.3 * side, 0.4, 0.4), Vector3(0.6 * side, 0.45, 0.65), 0.06)
		k.sphere(root, &"crab", Vector3(0.68 * side, 0.48, 0.72), 0.16, Vector3(1, 0.8, 1.2))
		k.bone(root, &"crab", Vector3(0.68 * side, 0.52, 0.8), Vector3(0.62 * side, 0.6, 1.0), 0.06, 0.02)
		for i in 3:
			var z := 0.35 - i * 0.18
			k.limb(root, &"crab", Vector3(0.3 * side, 0.3, z), Vector3(0.55 * side, 0.02, z + 0.05), 0.035)


static func _parrot(k: ModelKit, root: Node3D) -> void:
	var c := Vector3(0, 1.0, 0)
	k.sphere(root, &"feather", c, 0.35, Vector3(1, 1.25, 0.95))
	k.sphere(root, &"feather2", c + Vector3(0, -0.05, 0.22), 0.22, Vector3(1, 1.2, 0.5))
	var head := c + Vector3(0, 0.5, 0.05)
	k.sphere(root, &"feather", head, 0.25)
	k.eyes(root, head + Vector3(0, 0.05, 0.2), 0.22, 0.06)
	k.bone(root, &"beak", head + Vector3(0, -0.02, 0.2), head + Vector3(0, -0.2, 0.36), 0.1, 0.02)
	for i in 3:
		k.spike(root, &"feather2", head + Vector3((i - 1) * 0.06, 0.2, -0.05), head + Vector3((i - 1) * 0.1, 0.45, -0.15), 0.05)
	# しっぽ
	var tail := k.pivot(root, c + Vector3(0, -0.3, -0.25))
	for i in 3:
		k.bone(tail, &"feather3" if i == 1 else &"feather", Vector3((i - 1) * 0.06, 0, 0), Vector3((i - 1) * 0.12, -0.55, -0.4), 0.07, 0.02)
	k.parts["tail"] = tail
	for side in [-1.0, 1.0]:
		k.limb(root, &"beak", c + Vector3(0.12 * side, -0.4, 0.05), c + Vector3(0.12 * side, -0.6, 0.1), 0.03)
		var p := k.pivot(root, c + Vector3(0.3 * side, 0.2, 0))
		k.sphere(p, &"feather", Vector3(0.4 * side, -0.05, -0.05), 0.4, Vector3(1.2, 0.25, 0.7), Vector3(0, 0, -15.0 * side))
		k.sphere(p, &"feather3", Vector3(0.65 * side, -0.12, -0.1), 0.25, Vector3(1.3, 0.2, 0.6), Vector3(0, 0, -15.0 * side))
		k.add_wing(p, side)
	k.parts["wing_speed"] = 0.15
	k.parts["wing_angle"] = 30.0


static func _captain(k: ModelKit, root: Node3D) -> void:
	# ゆうれいのしっぽ（足のかわり）
	k.cone(root, &"ghost", Vector3(0, 0.6, 0), 0.55, 1.2, Vector3(180, 0, 0), 16)
	# コート
	k.cyl(root, &"coat", Vector3(0, 1.6, 0), 0.55, 0.65, 1.1, Vector3.ZERO, 16)
	k.box(root, &"trim", Vector3(0, 1.6, 0.56), Vector3(0.12, 1.0, 0.04))
	for y in [1.3, 1.6, 1.9]:
		for side in [-1.0, 1.0]:
			k.sphere(root, &"trim", Vector3(0.18 * side, y, 0.57), 0.05)
	# 肩章
	for side in [-1.0, 1.0]:
		k.sphere(root, &"trim", Vector3(0.62 * side, 2.1, 0), 0.18, Vector3(1.2, 0.5, 1))
	# 頭（ゆうれいのドクロ）
	var head := Vector3(0, 2.5, 0.05)
	k.sphere(root, &"ghost", head, 0.42)
	for side in [-1.0, 1.0]:
		k.sphere(root, &"dark", head + Vector3(0.15 * side, 0.03, 0.35), 0.1, Vector3(1, 1.1, 0.5))
		k.sphere(root, &"eye_glow", head + Vector3(0.15 * side, 0.03, 0.4), 0.05)
	k.box(root, &"dark", head + Vector3(0, -0.2, 0.38), Vector3(0.3, 0.08, 0.04))
	# ぼうし
	k.sphere(root, &"hat", head + Vector3(0, 0.35, 0), 0.55, Vector3(1.4, 0.35, 1.0))
	k.box(root, &"hat", head + Vector3(0, 0.5, 0), Vector3(0.7, 0.3, 0.5))
	k.box(root, &"bone", head + Vector3(0, 0.5, 0.26), Vector3(0.18, 0.18, 0.02))
	# うで・いかり
	k.limb(root, &"coat", Vector3(-0.65, 2.0, 0), Vector3(-0.95, 1.5, 0.25), 0.13)
	k.sphere(root, &"ghost", Vector3(-0.98, 1.42, 0.28), 0.13)
	var w := k.pivot(root, Vector3(0.65, 2.0, 0))
	k.limb(w, &"coat", Vector3.ZERO, Vector3(0.3, -0.5, 0.25), 0.13)
	k.chain(w, &"metal", [Vector3(0.3, -0.55, 0.3), Vector3(0.35, -0.8, 0.5), Vector3(0.3, -1.0, 0.75)], 0.04, 0.04)
	k.limb(w, &"metal", Vector3(0.3, -1.0, 0.75), Vector3(0.3, -1.5, 0.85), 0.06)
	k.torus(w, &"metal", Vector3(0.3, -1.55, 0.85), 0.18, 0.26, Vector3(90, 0, 0), Vector3(1, 1, 0.6))
	k.parts["weapon"] = w
