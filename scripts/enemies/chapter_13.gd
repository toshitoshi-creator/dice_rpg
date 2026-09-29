class_name EnemyChapter13
extends RefCounted
## チャプター 13「ようせいの花園」
## 雑魚: ピクシー / マンドラゴラ / バタフライ　ボス: フェアリークイーン

const CHAPTER := 13
const AREA := "ようせいの花園"

const MOBS := [
	{
		"id": &"pixie", "idle": &"hover", "height": 1.5, "width": 2.4,
		"names": ["ピクシー", "ナイトピクシー", "サンピクシー"],
		"names_en": ["PIXIE", "NIGHT PIXIE", "SUN PIXIE"],
		"attack": "いたずらまほう",
		"desc": "花のあいだを飛びまわる小さな妖精。いたずらが大好き。",
		"palettes": [
			{&"skin": Color(1.0, 0.85, 0.75), &"hair": Color(0.4, 0.85, 0.5), &"dress": Color(0.5, 0.9, 0.55), &"wing": {"color": Color(0.8, 1.0, 0.9, 0.6), "double": true, "emission": 0.4}},
			{&"skin": Color(0.8, 0.8, 0.95), &"hair": Color(0.3, 0.3, 0.6), &"dress": Color(0.25, 0.2, 0.5), &"wing": {"color": Color(0.6, 0.5, 1.0, 0.6), "double": true, "emission": 0.6}},
			{&"skin": Color(1.0, 0.88, 0.7), &"hair": Color(1.0, 0.75, 0.2), &"dress": Color(1.0, 0.55, 0.2), &"wing": {"color": Color(1.0, 0.9, 0.5, 0.6), "double": true, "emission": 0.8}},
		],
	},
	{
		"id": &"mandrake", "idle": &"bounce", "height": 1.5, "width": 1.8,
		"names": ["マンドラゴラ", "ドクマンドラゴラ", "ゴールドマンドラゴラ"],
		"names_en": ["MANDRAKE", "POISON MANDRAKE", "GOLD MANDRAKE"],
		"attack": "ひめい",
		"desc": "土からぬけ出した根っこの魔物。さけび声で頭がくらくらする。",
		"palettes": [
			{&"root": Color(0.85, 0.7, 0.5), &"leaf": Color(0.3, 0.7, 0.25), &"flower": Color(1.0, 0.5, 0.6)},
			{&"root": Color(0.55, 0.4, 0.6), &"leaf": Color(0.4, 0.2, 0.5), &"flower": {"color": Color(0.5, 1.0, 0.3), "emission": 0.8}},
			{&"root": {"color": Color(1.0, 0.8, 0.35), "metal": 0.7, "rough": 0.3}, &"leaf": Color(0.2, 0.55, 0.3), &"flower": {"color": Color(1.0, 1.0, 0.8), "emission": 1.0}},
		],
	},
	{
		"id": &"butterfly", "idle": &"hover", "height": 1.8, "width": 2.6,
		"names": ["バタフライ", "ミッドナイトバタフライ", "レインボーバタフライ"],
		"names_en": ["BUTTERFLY", "MIDNIGHT FLY", "RAINBOW FLY"],
		"attack": "りんぷん",
		"desc": "大きなはねのチョウ。はねからまく粉で眠くなる。",
		"palettes": [
			{&"body": Color(0.2, 0.15, 0.2), &"wing": {"color": Color(1.0, 0.6, 0.15), "double": true}, &"wing2": {"color": Color(0.15, 0.1, 0.1), "double": true}},
			{&"body": Color(0.1, 0.1, 0.2), &"wing": {"color": Color(0.2, 0.4, 1.0), "double": true, "emission": 0.4}, &"wing2": {"color": Color(0.9, 0.95, 1.0), "double": true}},
			{&"body": Color(0.95, 0.9, 1.0), &"wing": {"color": Color(1.0, 0.4, 0.8), "double": true, "emission": 0.6}, &"wing2": {"color": Color(0.4, 1.0, 0.9), "double": true, "emission": 0.6}},
		],
	},
]

const BOSS := {
	"id": &"fairy_queen", "idle": &"hover", "height": 3.6, "width": 4.0,
	"names": ["フェアリークイーン", "ダークフェアリークイーン", "ゴッドフェアリー"],
	"names_en": ["FAIRY QUEEN", "DARK FAIRY QUEEN", "GOD FAIRY"],
	"attack": "フラワーストーム",
	"desc": "花園を守る妖精の女王。花びらのあらしをまきおこす。",
	"palettes": [
		{&"skin": Color(1.0, 0.88, 0.8), &"hair": Color(1.0, 0.8, 0.9), &"dress": Color(0.95, 0.5, 0.75), &"wing": {"color": Color(0.9, 0.8, 1.0, 0.55), "double": true, "emission": 0.6}, &"crown": {"color": Color(1.0, 0.8, 0.3), "metal": 0.9, "rough": 0.25}, &"flower": Color(1.0, 0.95, 0.5)},
		{&"skin": Color(0.7, 0.72, 0.9), &"hair": Color(0.15, 0.12, 0.25), &"dress": Color(0.3, 0.1, 0.35), &"wing": {"color": Color(0.5, 0.1, 0.6, 0.6), "double": true, "emission": 0.8}, &"crown": {"color": Color(0.6, 0.6, 0.7), "metal": 0.9, "rough": 0.2}, &"flower": {"color": Color(0.9, 0.2, 0.4), "emission": 1.0}},
		{&"skin": Color(1.0, 0.95, 0.85), &"hair": Color(1.0, 1.0, 0.95), &"dress": Color(1.0, 0.95, 0.8), &"wing": {"color": Color(1.0, 0.95, 0.5, 0.55), "double": true, "emission": 1.2}, &"crown": {"color": Color(1.0, 0.85, 0.35), "metal": 1.0, "rough": 0.1}, &"flower": {"color": Color(0.5, 0.9, 1.0), "emission": 1.2}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"pixie":
			_fairy(k, root, false)
		&"mandrake":
			_mandrake(k, root)
		&"butterfly":
			_butterfly(k, root)
		&"fairy_queen":
			_fairy(k, root, true)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _fairy(k: ModelKit, root: Node3D, queen: bool) -> void:
	var s := 1.6 if queen else 1.0
	var y := 0.7 * s
	# ドレス
	k.cone(root, &"dress", Vector3(0, y, 0), 0.38 * s, 0.9 * s, Vector3.ZERO, 16)
	k.sphere(root, &"dress", Vector3(0, y + 0.45 * s, 0), 0.2 * s, Vector3(1, 1.2, 0.8))
	# 頭
	var head := Vector3(0, y + 0.85 * s, 0)
	k.sphere(root, &"skin", head, 0.26 * s)
	k.sphere(root, &"hair", head + Vector3(0, 0.1 * s, -0.1 * s), 0.28 * s, Vector3(1.05, 0.85, 0.95))
	k.sphere(root, &"hair", head + Vector3(0, -0.15 * s, -0.18 * s), 0.2 * s, Vector3(1.2, 1.4, 0.6))
	k.eyes(root, head + Vector3(0, 0, 0.23 * s), 0.18 * s, 0.06 * s)
	k.sphere(root, &"mouth", head + Vector3(0, -0.12 * s, 0.24 * s), 0.025 * s, Vector3(1.4, 0.7, 0.5))
	for side in [-1.0, 1.0]:
		k.limb(root, &"skin", Vector3(0.18 * side * s, y + 0.5 * s, 0), Vector3(0.38 * side * s, y + 0.25 * s, 0.15 * s), 0.05 * s)
		k.spike(root, &"skin", head + Vector3(0.24 * side * s, 0, 0), head + Vector3(0.4 * side * s, 0.12 * s, -0.05 * s), 0.05 * s)
		# はね（2 枚ずつ）
		var p := k.pivot(root, Vector3(0.1 * side * s, y + 0.5 * s, -0.15 * s))
		k.sphere(p, &"wing", Vector3(0.45 * side * s, 0.3 * s, -0.05), 0.4 * s, Vector3(1.2, 0.8, 0.06), Vector3(0, 0, -25.0 * side))
		k.sphere(p, &"wing", Vector3(0.35 * side * s, -0.2 * s, -0.08), 0.28 * s, Vector3(1.1, 0.8, 0.06), Vector3(0, 0, 30.0 * side))
		k.add_wing(p, side)
	k.parts["wing_speed"] = 0.12
	k.parts["wing_angle"] = 20.0
	if queen:
		for i in 5:
			var a := TAU * i / 5.0
			k.cone(root, &"crown", head + Vector3(sin(a) * 0.2 * s, 0.35 * s, cos(a) * 0.2 * s), 0.05 * s, 0.2 * s, Vector3.ZERO, 6)
		k.torus(root, &"crown", head + Vector3(0, 0.3 * s, 0), 0.19 * s, 0.24 * s)
		# 杖
		var w := k.pivot(root, Vector3(0.45 * s, y + 0.3 * s, 0.2 * s))
		k.limb(w, &"crown", Vector3(0, -0.5 * s, 0), Vector3(0, 0.6 * s, 0), 0.03 * s)
		k.sphere(w, &"flower", Vector3(0, 0.7 * s, 0), 0.1 * s)
		for i in 5:
			var a := TAU * i / 5.0
			k.sphere(w, &"dress", Vector3(sin(a) * 0.1 * s, 0.7 * s, cos(a) * 0.1 * s), 0.07 * s, Vector3(1, 0.5, 1))
		k.parts["weapon"] = w
		for i in 6:
			var a := TAU * i / 6.0
			k.sphere(root, &"flower", Vector3(sin(a) * 0.9 * s, y - 0.55 * s, cos(a) * 0.9 * s), 0.07 * s)
	else:
		k.sphere(root, &"glow", head + Vector3(0.15, 0.3, 0), 0.05)


static func _mandrake(k: ModelKit, root: Node3D) -> void:
	# 根の体
	k.sphere(root, &"root", Vector3(0, 0.55, 0), 0.38, Vector3(1, 1.3, 1))
	for side in [-1.0, 1.0]:
		k.bone(root, &"root", Vector3(0.15 * side, 0.2, 0), Vector3(0.28 * side, 0.02, 0.1), 0.1, 0.03)
		k.bone(root, &"root", Vector3(0.3 * side, 0.65, 0), Vector3(0.6 * side, 0.8, 0.1), 0.08, 0.02)
	# ひげ根
	for i in 4:
		var a := TAU * i / 4.0 + 0.4
		k.bone(root, &"root", Vector3(sin(a) * 0.2, 0.2, cos(a) * 0.2), Vector3(sin(a) * 0.35, 0.0, cos(a) * 0.35), 0.03, 0.01)
	# 顔（さけぶ）
	k.eyes(root, Vector3(0, 0.75, 0.33), 0.22, 0.07, &"dot")
	k.sphere(root, &"mouth", Vector3(0, 0.52, 0.34), 0.1, Vector3(0.9, 1.3, 0.5))
	# 葉っぱと花
	for i in 5:
		var a := TAU * i / 5.0
		k.sphere(root, &"leaf", Vector3(sin(a) * 0.25, 1.15, cos(a) * 0.25), 0.2, Vector3(0.5, 0.12, 1.3), Vector3(30, rad_to_deg(a), 0))
	k.limb(root, &"leaf", Vector3(0, 1.0, 0), Vector3(0.05, 1.35, 0), 0.03)
	k.sphere(root, &"flower", Vector3(0.05, 1.4, 0), 0.1)
	for i in 5:
		var a := TAU * i / 5.0
		k.sphere(root, &"flower", Vector3(0.05 + sin(a) * 0.1, 1.4, cos(a) * 0.1), 0.07, Vector3(1, 0.4, 1))


static func _butterfly(k: ModelKit, root: Node3D) -> void:
	var c := Vector3(0, 1.1, 0)
	k.capsule(root, &"body", c + Vector3(0, -0.1, -0.1), 0.1, 0.8, Vector3(80, 0, 0))
	var head := c + Vector3(0, 0.05, 0.35)
	k.sphere(root, &"body", head, 0.14)
	k.eyes(root, head + Vector3(0, 0.02, 0.1), 0.14, 0.05)
	for side in [-1.0, 1.0]:
		k.limb(root, &"body", head + Vector3(0.04 * side, 0.1, 0), head + Vector3(0.15 * side, 0.4, 0.12), 0.012)
		k.sphere(root, &"body", head + Vector3(0.15 * side, 0.41, 0.12), 0.03)
		var p := k.pivot(root, c + Vector3(0.06 * side, 0.02, 0))
		k.sphere(p, &"wing", Vector3(0.55 * side, 0.3, 0.1), 0.55, Vector3(1.0, 0.9, 0.05), Vector3(0, 0, -20.0 * side))
		k.sphere(p, &"wing2", Vector3(0.62 * side, 0.4, 0.13), 0.18, Vector3(1.0, 1.0, 0.04))
		k.sphere(p, &"wing", Vector3(0.42 * side, -0.3, 0.0), 0.38, Vector3(0.9, 1.0, 0.05), Vector3(0, 0, 25.0 * side))
		k.sphere(p, &"wing2", Vector3(0.45 * side, -0.35, 0.03), 0.12, Vector3(1.0, 1.0, 0.04))
		k.add_wing(p, side)
	k.parts["wing_speed"] = 0.2
	k.parts["wing_angle"] = 35.0
