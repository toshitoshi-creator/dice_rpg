class_name EnemyChapter15
extends RefCounted
## チャプター 15「てんくうの城」
## 雑魚: グリフォン / クラウドン / てんくうナイト　ボス: サンダーバード

const CHAPTER := 15
const AREA := "てんくうの城"

const MOBS := [
	{
		"id": &"griffin", "idle": &"hover", "height": 1.8, "width": 2.6,
		"names": ["グリフォン", "ストームグリフォン", "ロイヤルグリフォン"],
		"names_en": ["GRIFFIN", "STORM GRIFFIN", "ROYAL GRIFFIN"],
		"attack": "かぎづめアタック",
		"desc": "ワシの頭とライオンの体をもつ空の番人。",
		"palettes": [
			{&"fur": Color(0.85, 0.65, 0.35), &"feather": Color(0.95, 0.95, 0.92), &"beak": Color(1.0, 0.8, 0.2), &"wing": {"color": Color(0.7, 0.5, 0.3), "double": true}},
			{&"fur": Color(0.35, 0.38, 0.5), &"feather": Color(0.2, 0.22, 0.3), &"beak": Color(0.6, 0.7, 0.8), &"wing": {"color": Color(0.25, 0.3, 0.5), "double": true}},
			{&"fur": {"color": Color(1.0, 0.82, 0.35), "metal": 0.6, "rough": 0.35}, &"feather": Color(1.0, 1.0, 0.95), &"beak": Color(0.9, 0.3, 0.2), &"wing": {"color": Color(1.0, 0.95, 0.8), "double": true, "emission": 0.3}},
		],
	},
	{
		"id": &"cloud", "idle": &"hover", "height": 1.4, "width": 2.4,
		"names": ["クラウドン", "あまぐもクラウドン", "かみなりクラウドン"],
		"names_en": ["CLOUDON", "RAIN CLOUDON", "THUNDER CLOUDON"],
		"attack": "かみなり",
		"desc": "ふわふわの雲の魔物。おこると雨やかみなりをふらせる。",
		"palettes": [
			{&"cloud": {"color": Color(0.98, 0.98, 1.0), "rough": 0.9}, &"drop": {"color": Color(0.5, 0.8, 1.0), "emission": 0.5}},
			{&"cloud": {"color": Color(0.5, 0.55, 0.65), "rough": 0.9}, &"drop": {"color": Color(0.3, 0.6, 1.0), "emission": 0.8}},
			{&"cloud": {"color": Color(0.25, 0.22, 0.35), "rough": 0.9}, &"drop": {"color": Color(1.0, 0.95, 0.3), "emission": 3.0}},
		],
	},
	{
		"id": &"sky_knight", "idle": &"sway", "height": 2.0, "width": 2.4,
		"names": ["てんくうナイト", "シルバーナイト", "ホーリーナイト"],
		"names_en": ["SKY KNIGHT", "SILVER KNIGHT", "HOLY KNIGHT"],
		"attack": "ランスチャージ",
		"desc": "天空の城を守るつばさの騎士。ランスの一撃は雲をつらぬく。",
		"palettes": [
			{&"armor": {"color": Color(0.35, 0.55, 0.9), "metal": 0.7, "rough": 0.3}, &"armor2": {"color": Color(0.95, 0.95, 1.0), "metal": 0.6, "rough": 0.3}, &"wing": {"color": Color(1.0, 1.0, 1.0), "double": true}, &"eye_glow": {"color": Color(0.5, 0.9, 1.0), "emission": 3.0}},
			{&"armor": {"color": Color(0.75, 0.78, 0.82), "metal": 0.95, "rough": 0.2}, &"armor2": {"color": Color(0.3, 0.3, 0.35), "metal": 0.8, "rough": 0.3}, &"wing": {"color": Color(0.8, 0.85, 0.9), "double": true}, &"eye_glow": {"color": Color(1.0, 0.3, 0.3), "emission": 3.0}},
			{&"armor": {"color": Color(1.0, 0.95, 0.85), "metal": 0.7, "rough": 0.2}, &"armor2": {"color": Color(1.0, 0.8, 0.3), "metal": 0.95, "rough": 0.2}, &"wing": {"color": Color(1.0, 0.95, 0.7), "double": true, "emission": 0.5}, &"eye_glow": {"color": Color(1.0, 0.9, 0.4), "emission": 3.5}},
		],
	},
]

const BOSS := {
	"id": &"thunderbird", "idle": &"hover", "height": 3.4, "width": 4.2,
	"names": ["サンダーバード", "ブリザードバード", "ゴッドバード"],
	"names_en": ["THUNDERBIRD", "BLIZZARD BIRD", "GOD BIRD"],
	"attack": "いなずまのつばさ",
	"desc": "天空の城の主。つばさをひろげると空がかみなりでみたされる。",
	"palettes": [
		{&"feather": Color(0.2, 0.3, 0.75), &"feather2": Color(1.0, 0.85, 0.2), &"beak": Color(0.95, 0.75, 0.2), &"bolt": {"color": Color(1.0, 0.95, 0.4), "emission": 3.0}, &"wing": {"color": Color(0.25, 0.35, 0.85), "double": true}},
		{&"feather": Color(0.8, 0.92, 1.0), &"feather2": Color(0.4, 0.75, 1.0), &"beak": Color(0.6, 0.7, 0.8), &"bolt": {"color": Color(0.6, 0.95, 1.0), "emission": 3.0}, &"wing": {"color": Color(0.85, 0.95, 1.0), "double": true}},
		{&"feather": Color(0.95, 0.3, 0.15), &"feather2": Color(1.0, 0.95, 0.8), &"beak": Color(1.0, 0.85, 0.3), &"bolt": {"color": Color(1.0, 0.5, 0.9), "emission": 3.5}, &"wing": {"color": Color(1.0, 0.45, 0.2), "double": true, "emission": 0.3}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"griffin":
			_griffin(k, root)
		&"cloud":
			_cloud(k, root)
		&"sky_knight":
			_knight(k, root)
		&"thunderbird":
			_thunderbird(k, root)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _griffin(k: ModelKit, root: Node3D) -> void:
	k.capsule(root, &"fur", Vector3(0, 0.85, -0.1), 0.32, 1.1, Vector3(90, 0, 0))
	for side in [-1.0, 1.0]:
		for z in [0.25, -0.45]:
			var role := &"feather" if z > 0 else &"fur"
			k.limb(root, role, Vector3(0.2 * side, 0.75, z), Vector3(0.22 * side, 0.1, z + 0.05), 0.08)
			k.sphere(root, &"beak" if z > 0 else &"fur", Vector3(0.22 * side, 0.07, z + 0.1), 0.09, Vector3(1, 0.6, 1.3))
		var p := k.pivot(root, Vector3(0.25 * side, 1.1, 0.05))
		k.sphere(p, &"wing", Vector3(0.55 * side, 0.2, -0.15), 0.55, Vector3(1.3, 0.12, 0.7), Vector3(0, 0, -20.0 * side))
		k.sphere(p, &"feather", Vector3(0.85 * side, 0.3, -0.2), 0.3, Vector3(1.3, 0.1, 0.6), Vector3(0, 0, -20.0 * side))
		k.add_wing(p, side)
	k.parts["wing_speed"] = 0.25
	k.parts["wing_angle"] = 25.0
	var head := Vector3(0, 1.35, 0.45)
	k.sphere(root, &"feather", head + Vector3(0, -0.2, -0.1), 0.28)
	k.sphere(root, &"feather", head, 0.24)
	k.eyes(root, head + Vector3(0, 0.05, 0.18), 0.22, 0.06, &"angry")
	k.bone(root, &"beak", head + Vector3(0, -0.02, 0.18), head + Vector3(0, -0.15, 0.42), 0.09, 0.02)
	var tail := k.pivot(root, Vector3(0, 0.95, -0.7))
	k.chain(tail, &"fur", ModelKit.curl_points(Vector3.ZERO, Vector3(0, -0.3, -1), Vector3(0, 1, 0), 0.6, 4), 0.05, 0.03)
	k.sphere(tail, &"fur", Vector3(0, 0.05, -0.6), 0.1)
	k.parts["tail"] = tail


static func _cloud(k: ModelKit, root: Node3D) -> void:
	var c := Vector3(0, 1.1, 0)
	for p in [[Vector3(0, 0, 0), 0.5], [Vector3(-0.45, -0.05, 0), 0.38], [Vector3(0.45, -0.05, 0), 0.38], [Vector3(-0.2, 0.3, -0.05), 0.35], [Vector3(0.22, 0.28, -0.05), 0.33], [Vector3(0, -0.15, -0.2), 0.4]]:
		k.sphere(root, &"cloud", c + p[0], p[1])
	k.eyes(root, c + Vector3(0, 0.05, 0.45), 0.3, 0.09, &"angry")
	k.sphere(root, &"mouth", c + Vector3(0, -0.15, 0.46), 0.06, Vector3(1.6, 0.6, 0.5))
	for i in 5:
		var x := -0.4 + i * 0.2
		k.sphere(root, &"drop", c + Vector3(x, -0.6 - (i % 2) * 0.2, 0), 0.06, Vector3(0.7, 1.3, 0.7))


static func _knight(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.limb(root, &"armor", Vector3(0.18 * side, 0.8, 0), Vector3(0.2 * side, 0.12, 0.05), 0.1)
		k.box(root, &"armor2", Vector3(0.2 * side, 0.06, 0.08), Vector3(0.2, 0.12, 0.32))
		var p := k.pivot(root, Vector3(0.2 * side, 1.35, -0.25))
		k.sphere(p, &"wing", Vector3(0.45 * side, 0.2, -0.1), 0.45, Vector3(1.2, 0.1, 0.6), Vector3(0, 0, -30.0 * side))
		k.add_wing(p, side)
	k.parts["wing_speed"] = 0.4
	k.parts["wing_angle"] = 15.0
	k.cyl(root, &"armor", Vector3(0, 1.15, 0), 0.34, 0.28, 0.75)
	k.box(root, &"armor2", Vector3(0, 1.2, 0.28), Vector3(0.3, 0.4, 0.05))
	var head := Vector3(0, 1.75, 0.02)
	k.sphere(root, &"armor", head, 0.26)
	k.box(root, &"dark", head + Vector3(0, 0, 0.22), Vector3(0.32, 0.07, 0.06))
	k.box(root, &"eye_glow", head + Vector3(0, 0, 0.25), Vector3(0.26, 0.03, 0.02))
	k.cone(root, &"armor2", head + Vector3(0, 0.32, -0.05), 0.08, 0.3)
	for side in [-1.0, 1.0]:
		k.sphere(root, &"wing", head + Vector3(0.24 * side, 0.12, -0.05), 0.12, Vector3(0.4, 0.8, 1.2))
	# 盾
	k.limb(root, &"armor", Vector3(-0.36, 1.4, 0), Vector3(-0.5, 1.05, 0.2), 0.08)
	k.sphere(root, &"armor2", Vector3(-0.55, 1.0, 0.3), 0.3, Vector3(1, 1.2, 0.2))
	# ランス
	var w := k.pivot(root, Vector3(0.36, 1.4, 0))
	k.limb(w, &"armor", Vector3.ZERO, Vector3(0.1, -0.35, 0.15), 0.08)
	k.bone(w, &"armor2", Vector3(0.1, -0.38, 0.0), Vector3(0.12, -0.3, 1.2), 0.1, 0.01)
	k.parts["weapon"] = w


static func _thunderbird(k: ModelKit, root: Node3D) -> void:
	var c := Vector3(0, 1.7, 0)
	k.sphere(root, &"feather", c, 0.65, Vector3(1, 1.2, 1))
	k.sphere(root, &"feather2", c + Vector3(0, -0.1, 0.4), 0.4, Vector3(1, 1.3, 0.5))
	for i in 5:
		k.bone(root, &"bolt", c + Vector3(-0.15 + i * 0.075, -0.2 - i * 0.05, 0.62), c + Vector3(-0.1 + i * 0.07, -0.35 - i * 0.05, 0.64), 0.04, 0.02)
	var head := c + Vector3(0, 0.85, 0.15)
	k.sphere(root, &"feather", head, 0.38)
	k.eyes(root, head + Vector3(0, 0.08, 0.3), 0.3, 0.09, &"angry")
	k.bone(root, &"beak", head + Vector3(0, -0.05, 0.3), head + Vector3(0, -0.3, 0.7), 0.14, 0.02)
	for i in 5:
		var a := (i - 2) * 0.25
		k.bone(root, &"feather2", head + Vector3(sin(a) * 0.15, 0.3, -0.1), head + Vector3(sin(a) * 0.5, 0.85, -0.35), 0.07, 0.01)
	for side in [-1.0, 1.0]:
		k.limb(root, &"beak", c + Vector3(0.25 * side, -0.7, 0.1), c + Vector3(0.3 * side, -1.6, 0.2), 0.06)
		for f in 3:
			k.spike(root, &"beak", c + Vector3(0.3 * side, -1.6, 0.2), c + Vector3(0.3 * side + (f - 1) * 0.12, -1.68, 0.45), 0.04)
		var p := k.pivot(root, c + Vector3(0.5 * side, 0.3, 0))
		k.sphere(p, &"wing", Vector3(0.9 * side, 0.3, -0.1), 0.9, Vector3(1.3, 0.12, 0.6), Vector3(0, 0, -20.0 * side))
		k.sphere(p, &"feather2", Vector3(1.5 * side, 0.5, -0.12), 0.45, Vector3(1.3, 0.1, 0.5), Vector3(0, 0, -20.0 * side))
		k.bone(p, &"bolt", Vector3(1.1 * side, 0.45, 0.05), Vector3(1.7 * side, 0.1, 0.1), 0.05, 0.02)
		k.add_wing(p, side)
	k.parts["wing_speed"] = 0.3
	k.parts["wing_angle"] = 25.0
	var tail := k.pivot(root, c + Vector3(0, -0.4, -0.5))
	for i in 3:
		k.bone(tail, &"feather2" if i == 1 else &"feather", Vector3((i - 1) * 0.1, 0, 0), Vector3((i - 1) * 0.3, -0.6, -0.8), 0.12, 0.02)
	k.parts["tail"] = tail
