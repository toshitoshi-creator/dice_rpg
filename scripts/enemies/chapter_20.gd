class_name EnemyChapter20
extends RefCounted
## チャプター 20「かみがみの領域」（さいごのチャプター）
## 雑魚: エンジェル / ライトスピリット / ゴッドナイト　ボス: オメガ

const CHAPTER := 20
const AREA := "かみがみの領域"

const MOBS := [
	{
		"id": &"angel", "idle": &"hover", "height": 1.9, "width": 2.6,
		"names": ["エンジェル", "アークエンジェル", "だてんし"],
		"names_en": ["ANGEL", "ARCHANGEL", "FALLEN ANGEL"],
		"attack": "ホーリーアロー",
		"desc": "神のつかい。光の弓でとおくからねらってくる。",
		"palettes": [
			{&"skin": Color(1.0, 0.9, 0.82), &"robe": Color(0.98, 0.97, 0.95), &"hair": Color(1.0, 0.85, 0.4), &"wing": {"color": Color(1.0, 1.0, 1.0), "double": true}, &"halo": {"color": Color(1.0, 0.9, 0.4), "emission": 2.5}},
			{&"skin": Color(1.0, 0.9, 0.82), &"robe": Color(0.35, 0.5, 0.95), &"hair": Color(0.95, 0.95, 1.0), &"wing": {"color": Color(0.9, 0.95, 1.0), "double": true, "emission": 0.4}, &"halo": {"color": Color(0.5, 0.9, 1.0), "emission": 3.0}},
			{&"skin": Color(0.8, 0.78, 0.85), &"robe": Color(0.15, 0.1, 0.18), &"hair": Color(0.1, 0.08, 0.12), &"wing": {"color": Color(0.1, 0.08, 0.12), "double": true}, &"halo": {"color": Color(0.9, 0.1, 0.3), "emission": 3.0}},
		],
	},
	{
		"id": &"light_spirit", "idle": &"flicker", "height": 1.6, "width": 2.0,
		"names": ["ライトスピリット", "ダークスピリット", "プリズムスピリット"],
		"names_en": ["LIGHT SPIRIT", "DARK SPIRIT", "PRISM SPIRIT"],
		"attack": "ひかりのうず",
		"desc": "光そのものの精霊。まわりをまわる光のわがまぶしい。",
		"palettes": [
			{&"core": {"color": Color(1.0, 0.98, 0.85), "emission": 2.5, "unshaded": true}, &"ring": {"color": Color(1.0, 0.85, 0.3), "emission": 2.0}, &"aura": {"color": Color(1.0, 0.95, 0.6, 0.35), "emission": 1.0}},
			{&"core": {"color": Color(0.3, 0.1, 0.4), "emission": 1.0}, &"ring": {"color": Color(0.7, 0.2, 1.0), "emission": 2.0}, &"aura": {"color": Color(0.4, 0.1, 0.6, 0.4), "emission": 1.0}},
			{&"core": {"color": Color(0.9, 1.0, 1.0), "emission": 2.5, "unshaded": true}, &"ring": {"color": Color(1.0, 0.4, 0.8), "emission": 2.5}, &"aura": {"color": Color(0.4, 1.0, 0.9, 0.35), "emission": 1.5}},
		],
	},
	{
		"id": &"god_knight", "idle": &"sway", "height": 2.2, "width": 2.4,
		"names": ["ゴッドナイト", "ダークゴッドナイト", "オリハルコンナイト"],
		"names_en": ["GOD KNIGHT", "DARK GOD KNIGHT", "ORICHALCUM KNIGHT"],
		"attack": "しんけんぎり",
		"desc": "神々の城を守る最強の騎士。光の大剣はどんなものも切りさく。",
		"palettes": [
			{&"armor": {"color": Color(1.0, 0.95, 0.85), "metal": 0.8, "rough": 0.2}, &"armor2": {"color": Color(1.0, 0.78, 0.25), "metal": 0.95, "rough": 0.2}, &"blade": {"color": Color(0.8, 0.95, 1.0), "emission": 1.5}, &"eye_glow": {"color": Color(0.5, 0.9, 1.0), "emission": 3.0}},
			{&"armor": {"color": Color(0.12, 0.1, 0.15), "metal": 0.8, "rough": 0.2}, &"armor2": {"color": Color(0.7, 0.1, 0.2), "metal": 0.7, "rough": 0.25}, &"blade": {"color": Color(1.0, 0.2, 0.3), "emission": 2.0}, &"eye_glow": {"color": Color(1.0, 0.2, 0.2), "emission": 3.0}},
			{&"armor": {"color": Color(0.4, 0.95, 0.85), "metal": 0.95, "rough": 0.1}, &"armor2": {"color": Color(1.0, 0.85, 0.35), "metal": 1.0, "rough": 0.1}, &"blade": {"color": Color(1.0, 0.9, 0.5), "emission": 2.5}, &"eye_glow": {"color": Color(1.0, 0.9, 0.3), "emission": 3.5}},
		],
	},
]

const BOSS := {
	"id": &"omega", "idle": &"hover", "height": 4.0, "width": 4.4,
	"names": ["オメガ", "カオスオメガ", "しんオメガ"],
	"names_en": ["OMEGA", "CHAOS OMEGA", "TRUE OMEGA"],
	"attack": "オメガフレア",
	"desc": "かみがみの領域の奥にいる、すべてのサイコロを作ったといわれる存在。",
	"palettes": [
		{&"armor": {"color": Color(0.95, 0.95, 1.0), "metal": 0.8, "rough": 0.15}, &"armor2": {"color": Color(1.0, 0.8, 0.3), "metal": 1.0, "rough": 0.15}, &"core": {"color": Color(0.5, 0.9, 1.0), "emission": 3.0}, &"wing": {"color": Color(1.0, 1.0, 1.0, 0.8), "double": true, "emission": 0.6}, &"eye_glow": {"color": Color(1.0, 0.9, 0.4), "emission": 3.5}},
		{&"armor": {"color": Color(0.1, 0.08, 0.14), "metal": 0.8, "rough": 0.15}, &"armor2": {"color": Color(0.6, 0.1, 0.8), "metal": 0.8, "rough": 0.2}, &"core": {"color": Color(1.0, 0.2, 0.4), "emission": 3.5}, &"wing": {"color": Color(0.3, 0.05, 0.4, 0.85), "double": true, "emission": 0.8}, &"eye_glow": {"color": Color(1.0, 0.2, 0.3), "emission": 3.5}},
		{&"armor": {"color": Color(1.0, 0.85, 0.35), "metal": 1.0, "rough": 0.1}, &"armor2": {"color": Color(0.9, 0.95, 1.0), "metal": 1.0, "rough": 0.05}, &"core": {"color": Color(1.0, 1.0, 1.0), "emission": 4.0, "unshaded": true}, &"wing": {"color": Color(1.0, 0.8, 0.4, 0.8), "double": true, "emission": 1.2}, &"eye_glow": {"color": Color(0.4, 1.0, 0.7), "emission": 4.0}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"angel":
			_angel(k, root)
		&"light_spirit":
			_spirit(k, root)
		&"god_knight":
			_god_knight(k, root)
		&"omega":
			_omega(k, root)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _angel(k: ModelKit, root: Node3D) -> void:
	k.cone(root, &"robe", Vector3(0, 0.75, 0), 0.4, 1.0, Vector3.ZERO, 16)
	k.sphere(root, &"robe", Vector3(0, 1.25, 0), 0.22, Vector3(1, 1.2, 0.8))
	var head := Vector3(0, 1.65, 0.02)
	k.sphere(root, &"skin", head, 0.24)
	k.sphere(root, &"hair", head + Vector3(0, 0.08, -0.08), 0.26, Vector3(1.05, 0.9, 0.95))
	k.eyes(root, head + Vector3(0, 0, 0.21), 0.16, 0.05)
	k.torus(root, &"halo", head + Vector3(0, 0.38, -0.05), 0.16, 0.22)
	for side in [-1.0, 1.0]:
		var p := k.pivot(root, Vector3(0.12 * side, 1.35, -0.2))
		k.sphere(p, &"wing", Vector3(0.45 * side, 0.2, -0.1), 0.5, Vector3(1.1, 0.12, 0.55), Vector3(0, 0, -35.0 * side))
		k.sphere(p, &"wing", Vector3(0.75 * side, 0.45, -0.12), 0.3, Vector3(1.2, 0.1, 0.5), Vector3(0, 0, -45.0 * side))
		k.add_wing(p, side)
	k.parts["wing_speed"] = 0.35
	k.parts["wing_angle"] = 18.0
	# 弓
	k.limb(root, &"skin", Vector3(-0.22, 1.35, 0), Vector3(-0.45, 1.25, 0.3), 0.05)
	var w := k.pivot(root, Vector3(0.22, 1.35, 0))
	k.limb(w, &"skin", Vector3.ZERO, Vector3(0.2, -0.1, 0.3), 0.05)
	k.torus(w, &"halo", Vector3(0.25, -0.1, 0.35), 0.4, 0.45, Vector3(0, 90, 0), Vector3(1, 1, 0.3))
	k.parts["weapon"] = w


static func _spirit(k: ModelKit, root: Node3D) -> void:
	var c := Vector3(0, 1.0, 0)
	k.sphere(root, &"aura", c, 0.65)
	k.sphere(root, &"core", c, 0.35)
	k.eyes(root, c + Vector3(0, 0.05, 0.3), 0.2, 0.06, &"dot")
	k.torus(root, &"ring", c, 0.5, 0.56, Vector3(70, 0, 20))
	k.torus(root, &"ring", c, 0.6, 0.65, Vector3(-60, 0, -30))
	for i in 6:
		var a := TAU * i / 6.0
		k.sphere(root, &"ring", c + Vector3(sin(a) * 0.85, cos(a) * 0.3, cos(a) * 0.5), 0.06)


static func _god_knight(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.limb(root, &"armor", Vector3(0.2 * side, 0.9, 0), Vector3(0.22 * side, 0.12, 0.05), 0.12)
		k.box(root, &"armor2", Vector3(0.22 * side, 0.06, 0.08), Vector3(0.24, 0.12, 0.36))
		k.sphere(root, &"armor2", Vector3(0.22 * side, 0.5, 0.1), 0.1)
		k.sphere(root, &"armor", Vector3(0.45 * side, 1.65, 0), 0.22, Vector3(1.2, 0.8, 1))
		k.spike(root, &"armor2", Vector3(0.45 * side, 1.8, 0), Vector3(0.6 * side, 2.05, -0.05), 0.06)
	k.cyl(root, &"armor", Vector3(0, 1.3, 0), 0.4, 0.3, 0.9)
	k.sphere(root, &"eye_glow", Vector3(0, 1.45, 0.38), 0.08)
	k.box(root, &"armor2", Vector3(0, 0.9, 0.3), Vector3(0.4, 0.12, 0.05))
	# マント
	k.box(root, &"armor2", Vector3(0, 1.1, -0.35), Vector3(0.8, 1.2, 0.05), Vector3(-10, 0, 0))
	var head := Vector3(0, 1.95, 0.02)
	k.sphere(root, &"armor", head, 0.25)
	k.box(root, &"dark", head + Vector3(0, 0, 0.21), Vector3(0.3, 0.06, 0.06))
	k.box(root, &"eye_glow", head + Vector3(0, 0, 0.24), Vector3(0.24, 0.025, 0.02))
	for side in [-1.0, 1.0]:
		k.bone(root, &"armor2", head + Vector3(0.18 * side, 0.12, 0), head + Vector3(0.35 * side, 0.5, -0.1), 0.06, 0.01)
	k.limb(root, &"armor", Vector3(-0.45, 1.55, 0), Vector3(-0.55, 1.1, 0.2), 0.09)
	var w := k.pivot(root, Vector3(0.45, 1.55, 0))
	k.limb(w, &"armor", Vector3.ZERO, Vector3(0.1, -0.4, 0.2), 0.09)
	k.box(w, &"armor2", Vector3(0.1, -0.45, 0.28), Vector3(0.35, 0.06, 0.1))
	k.bone(w, &"blade", Vector3(0.1, -0.45, 0.32), Vector3(0.1, -0.2, 1.5), 0.1, 0.02)
	k.parts["weapon"] = w


static func _omega(k: ModelKit, root: Node3D) -> void:
	var c := Vector3(0, 2.0, 0)
	# 下半身は光のうず
	k.cone(root, &"core", Vector3(0, 0.9, 0), 0.25, 1.2, Vector3(180, 0, 0), 12)
	for i in 3:
		k.torus(root, &"armor2", Vector3(0, 0.5 + i * 0.35, 0), 0.3 + i * 0.12, 0.36 + i * 0.12, Vector3(10.0 * (i - 1), 0, 0))
	k.sphere(root, &"armor", c, 0.6, Vector3(1.2, 1.1, 0.9))
	k.sphere(root, &"core", c + Vector3(0, 0, 0.5), 0.22)
	k.torus(root, &"armor2", c + Vector3(0, 0, 0.5), 0.24, 0.32, Vector3(90, 0, 0))
	# サイコロのかたちの肩（6 の目）
	for side in [-1.0, 1.0]:
		var sh := c + Vector3(0.85 * side, 0.3, 0)
		k.box(root, &"armor2", sh, Vector3(0.45, 0.45, 0.45), Vector3(15, 30.0 * side, 10))
		for i in 6:
			k.sphere(root, &"dark", sh + Vector3((i % 2) * 0.14 - 0.07, (i / 2) * 0.12 - 0.12, 0.24), 0.035)
		k.limb(root, &"armor", sh + Vector3(0, -0.2, 0.1), c + Vector3(1.1 * side, -0.6, 0.5), 0.14)
		k.sphere(root, &"core", c + Vector3(1.1 * side, -0.68, 0.55), 0.16)
		var p := k.pivot(root, c + Vector3(0.4 * side, 0.5, -0.4))
		k.sphere(p, &"wing", Vector3(0.9 * side, 0.5, -0.1), 0.85, Vector3(1.2, 0.1, 0.5), Vector3(0, 0, -35.0 * side))
		k.sphere(p, &"wing", Vector3(1.3 * side, 1.1, -0.15), 0.5, Vector3(1.2, 0.1, 0.45), Vector3(0, 0, -50.0 * side))
		k.sphere(p, &"wing", Vector3(0.8 * side, -0.2, -0.12), 0.55, Vector3(1.2, 0.1, 0.45), Vector3(0, 0, -10.0 * side))
		k.add_wing(p, side)
	k.parts["wing_speed"] = 0.5
	k.parts["wing_angle"] = 12.0
	# 頭と冠
	var head := c + Vector3(0, 0.95, 0.05)
	k.sphere(root, &"armor", head, 0.35, Vector3(1, 1.1, 1))
	k.box(root, &"dark", head + Vector3(0, 0.02, 0.3), Vector3(0.42, 0.1, 0.06))
	k.box(root, &"eye_glow", head + Vector3(0, 0.02, 0.33), Vector3(0.36, 0.04, 0.02))
	for i in 7:
		var a := (i - 3) * 0.35
		k.bone(root, &"armor2", head + Vector3(sin(a) * 0.25, 0.25, -0.05), head + Vector3(sin(a) * 0.55, 0.8 - absf(i - 3) * 0.1, -0.2), 0.06, 0.01)
	k.torus(root, &"core", head + Vector3(0, 0.55, -0.3), 0.45, 0.5, Vector3(-20, 0, 0))
