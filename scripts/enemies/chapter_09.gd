class_name EnemyChapter09
extends RefCounted
## チャプター 9「魔王城」
## 雑魚: インプ / リビングアーマー / ガーゴイル　ボス: ドラゴン

const CHAPTER := 9
const AREA := "魔王城"

const MOBS := [
	{
		"id": &"imp", "idle": &"hover", "height": 1.7, "width": 2.2,
		"names": ["インプ", "ブルーインプ", "ダークインプ"],
		"names_en": ["IMP", "BLUE IMP", "DARK IMP"],
		"attack": "いたずらフォーク",
		"desc": "魔王城にすみつく小悪魔。いたずらが大好き。",
		"palettes": [
			{&"skin": Color(0.85, 0.2, 0.2), &"wing": {"color": Color(0.35, 0.08, 0.12), "double": true}, &"horn": Color(0.2, 0.15, 0.15)},
			{&"skin": Color(0.25, 0.45, 0.9), &"wing": {"color": Color(0.1, 0.15, 0.4), "double": true}, &"horn": Color(0.95, 0.95, 1.0)},
			{&"skin": Color(0.22, 0.15, 0.28), &"wing": {"color": Color(0.5, 0.1, 0.6), "double": true}, &"horn": {"color": Color(1.0, 0.8, 0.3), "metal": 0.8, "rough": 0.3}, &"eye_white": {"color": Color(1.0, 0.9, 0.3), "emission": 1.5}},
		],
	},
	{
		"id": &"living_armor", "idle": &"sway", "height": 2.2, "width": 2.4,
		"names": ["リビングアーマー", "ブラッドアーマー", "ダークアーマー"],
		"names_en": ["LIVING ARMOR", "BLOOD ARMOR", "DARK ARMOR"],
		"attack": "まっぷたつ",
		"desc": "中身のない動くよろい。魔王城の廊下を見まわっている。",
		"palettes": [
			{&"armor": {"color": Color(0.75, 0.77, 0.82), "metal": 0.9, "rough": 0.25}, &"armor2": {"color": Color(1.0, 0.78, 0.28), "metal": 0.9, "rough": 0.3}, &"cloth": Color(0.2, 0.3, 0.7), &"eye_glow": {"color": Color(0.3, 0.8, 1.0), "emission": 3.0}, &"gem": {"color": Color(0.3, 0.8, 1.0), "emission": 1.2}},
			{&"armor": {"color": Color(0.55, 0.1, 0.12), "metal": 0.8, "rough": 0.3}, &"armor2": {"color": Color(0.15, 0.12, 0.12), "metal": 0.8, "rough": 0.3}, &"cloth": Color(0.12, 0.1, 0.1), &"eye_glow": {"color": Color(1.0, 0.3, 0.1), "emission": 3.0}, &"gem": {"color": Color(1.0, 0.2, 0.1), "emission": 1.2}},
			{&"armor": {"color": Color(0.12, 0.1, 0.15), "metal": 0.8, "rough": 0.25}, &"armor2": {"color": Color(0.55, 0.3, 0.8), "metal": 0.7, "rough": 0.3}, &"cloth": Color(0.35, 0.1, 0.45), &"eye_glow": {"color": Color(0.8, 0.3, 1.0), "emission": 3.5}, &"gem": {"color": Color(0.8, 0.3, 1.0), "emission": 1.5}},
		],
	},
	{
		"id": &"gargoyle", "idle": &"breathe", "height": 2.0, "width": 2.6,
		"names": ["ガーゴイル", "ブロンズガーゴイル", "オブシディアンガーゴイル"],
		"names_en": ["GARGOYLE", "BRONZE GARGOYLE", "OBSIDIAN GARGOYLE"],
		"attack": "いしのツメ",
		"desc": "城の屋根にいる石像の魔物。近づくと動きだす。",
		"palettes": [
			{&"stone": {"color": Color(0.5, 0.5, 0.52), "rough": 0.95}, &"stone2": {"color": Color(0.38, 0.38, 0.4), "rough": 0.95}, &"eye_glow": {"color": Color(1.0, 0.3, 0.1), "emission": 3.0}},
			{&"stone": {"color": Color(0.7, 0.45, 0.25), "metal": 0.8, "rough": 0.35}, &"stone2": {"color": Color(0.35, 0.5, 0.4), "metal": 0.6, "rough": 0.5}, &"eye_glow": {"color": Color(0.3, 1.0, 0.5), "emission": 3.0}},
			{&"stone": {"color": Color(0.08, 0.07, 0.1), "rough": 0.1, "clearcoat": 1.0}, &"stone2": {"color": Color(0.2, 0.12, 0.28), "rough": 0.15}, &"eye_glow": {"color": Color(0.8, 0.3, 1.0), "emission": 3.5}},
		],
	},
]

const BOSS := {
	"id": &"dragon", "idle": &"breathe", "height": 3.5, "width": 4.4,
	"names": ["ドラゴン", "アイスドラゴン", "ダークドラゴン"],
	"names_en": ["DRAGON", "ICE DRAGON", "DARK DRAGON"],
	"attack": "ほのおのツメ",
	"desc": "魔王につかえる伝説の竜。そのほのおは鉄をもとかす。",
	"palettes": [
		{&"scales": {"color": Color(0.62, 0.12, 0.2), "rough": 0.45, "rim": 0.4}, &"belly": Color(0.95, 0.72, 0.4), &"membrane": {"color": Color(0.38, 0.07, 0.12), "double": true}, &"horn": Color(0.95, 0.9, 0.78), &"eye_glow": {"color": Color(1.0, 0.85, 0.1), "emission": 3.0}},
		{&"scales": {"color": Color(0.45, 0.7, 0.95), "rough": 0.3, "rim": 0.5}, &"belly": Color(0.9, 0.97, 1.0), &"membrane": {"color": Color(0.25, 0.45, 0.75), "double": true}, &"horn": Color(0.85, 0.95, 1.0), &"eye_glow": {"color": Color(0.4, 1.0, 1.0), "emission": 3.0}},
		{&"scales": {"color": Color(0.1, 0.08, 0.12), "rough": 0.3, "rim": 0.4}, &"belly": {"color": Color(1.0, 0.78, 0.28), "metal": 0.7, "rough": 0.3}, &"membrane": {"color": Color(0.35, 0.05, 0.3), "double": true}, &"horn": {"color": Color(1.0, 0.8, 0.3), "metal": 0.8, "rough": 0.3}, &"eye_glow": {"color": Color(1.0, 0.2, 0.3), "emission": 3.5}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"imp":
			_imp(k, root)
		&"living_armor":
			_armor(k, root)
		&"gargoyle":
			_gargoyle(k, root)
		&"dragon":
			_dragon(k, root)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _imp(k: ModelKit, root: Node3D) -> void:
	var body := Vector3(0, 0.95, 0)
	k.sphere(root, &"skin", body, 0.28, Vector3(1, 1.15, 0.9))
	for side in [-1.0, 1.0]:
		k.limb(root, &"skin", body + Vector3(0.12 * side, -0.25, 0), body + Vector3(0.16 * side, -0.55, 0.08), 0.06)
		k.spike(root, &"horn", body + Vector3(0.16 * side, -0.55, 0.08), body + Vector3(0.16 * side, -0.58, 0.25), 0.05)
	var head := Vector3(0, 1.42, 0.05)
	k.sphere(root, &"skin", head, 0.32)
	k.eyes(root, head + Vector3(0, 0.05, 0.28), 0.22, 0.075, &"angry", &"horn")
	k.sphere(root, &"mouth", head + Vector3(0, -0.14, 0.28), 0.08, Vector3(1.8, 0.5, 0.5))
	for side in [-1.0, 1.0]:
		k.spike(root, &"tooth", head + Vector3(0.07 * side, -0.14, 0.31), head + Vector3(0.07 * side, -0.22, 0.32), 0.025)
		k.chain(root, &"horn", [head + Vector3(0.14 * side, 0.22, 0), head + Vector3(0.26 * side, 0.4, -0.04), head + Vector3(0.24 * side, 0.58, -0.16)], 0.07, 0.01)
		k.spike(root, &"skin", head + Vector3(0.28 * side, 0.02, 0), head + Vector3(0.52 * side, 0.12, -0.05), 0.07)
		var p := k.pivot(root, body + Vector3(0.18 * side, 0.15, -0.2))
		var tip := Vector3(0.75 * side, 0.4, -0.15)
		k.limb(p, &"horn", Vector3.ZERO, tip, 0.025)
		k.sphere(p, &"wing", Vector3(0.42 * side, 0.1, -0.1), 0.42, Vector3(1.0, 0.6, 0.04), Vector3(0, 0, 20.0 * side))
		k.add_wing(p, side)
	var tail := k.pivot(root, body + Vector3(0, -0.2, -0.22))
	var pts := ModelKit.curl_points(Vector3.ZERO, Vector3(0, -0.5, -1), Vector3(0, 2.5, 0.5), 0.8, 4)
	k.chain(tail, &"skin", pts, 0.04, 0.03)
	var end: Vector3 = pts[pts.size() - 1]
	k.sphere(tail, &"horn", end + Vector3(0, 0.05, 0), 0.07, Vector3(1, 1.4, 0.4))
	k.parts["tail"] = tail
	var w := k.pivot(root, body + Vector3(0.3, 0.1, 0.1))
	k.limb(w, &"skin", Vector3.ZERO, Vector3(0.1, -0.15, 0.15), 0.055)
	k.limb(w, &"metal", Vector3(0.1, -0.6, 0.2), Vector3(0.1, 0.55, 0.25), 0.025)
	for x in [-0.08, 0.0, 0.08]:
		k.spike(w, &"metal", Vector3(0.1 + x, 0.55, 0.25), Vector3(0.1 + x * 1.3, 0.78, 0.26), 0.025)
	k.parts["weapon"] = w
	k.parts["wing_speed"] = 0.12
	k.parts["wing_angle"] = 30.0


static func _armor(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.cyl(root, &"armor", Vector3(0.18 * side, 0.3, 0.02), 0.13, 0.15, 0.55)
		k.box(root, &"armor", Vector3(0.18 * side, 0.05, 0.08), Vector3(0.2, 0.1, 0.34))
		k.sphere(root, &"armor2", Vector3(0.18 * side, 0.6, 0.06), 0.1)
		k.cyl(root, &"armor", Vector3(0.18 * side, 0.82, 0), 0.15, 0.13, 0.38)
	for i in 5:
		var a := deg_to_rad(-60.0 + i * 30.0)
		k.box(root, &"armor2" if i % 2 == 0 else &"armor", Vector3(sin(a) * 0.3, 0.98, cos(a) * 0.28), Vector3(0.2, 0.35, 0.04), Vector3(-12, rad_to_deg(a), 0))
	k.sphere(root, &"dark", Vector3(0, 1.2, 0), 0.26)
	k.sphere(root, &"armor", Vector3(0, 1.45, 0.02), 0.42, Vector3(1.1, 1.05, 0.78))
	k.box(root, &"armor2", Vector3(0, 1.45, 0.34), Vector3(0.08, 0.5, 0.04))
	k.box(root, &"armor2", Vector3(0, 1.55, 0.33), Vector3(0.35, 0.07, 0.04))
	k.sphere(root, &"gem", Vector3(0, 1.55, 0.36), 0.05)
	k.sphere(root, &"dark", Vector3(0, 1.85, 0), 0.14)
	var head := Vector3(0, 2.05, 0.02)
	k.cyl(root, &"armor", head, 0.22, 0.24, 0.42, Vector3.ZERO, 16)
	k.dome(root, &"armor", head + Vector3(0, 0.2, 0), 0.22, 0.14)
	k.box(root, &"dark", head + Vector3(0, 0.02, 0.22), Vector3(0.3, 0.07, 0.04))
	k.box(root, &"eye_glow", head + Vector3(0, 0.02, 0.235), Vector3(0.22, 0.03, 0.02))
	k.box(root, &"armor2", head + Vector3(0, 0.02, 0.23), Vector3(0.04, 0.3, 0.03))
	k.chain(root, &"cloth", [head + Vector3(0, 0.33, 0), head + Vector3(0, 0.45, -0.2), head + Vector3(0, 0.35, -0.45)], 0.07, 0.04)
	for side in [-1.0, 1.0]:
		k.sphere(root, &"armor", Vector3(0.52 * side, 1.78, 0), 0.24, Vector3(1.15, 0.8, 1))
		k.torus(root, &"armor2", Vector3(0.52 * side, 1.7, 0), 0.2, 0.26, Vector3(0, 0, 20.0 * side), Vector3(1, 0.5, 1))
		k.spike(root, &"armor2", Vector3(0.55 * side, 1.92, 0), Vector3(0.7 * side, 2.2, 0), 0.06)
	k.limb(root, &"armor", Vector3(-0.55, 1.6, 0), Vector3(-0.6, 1.15, 0.25), 0.09)
	k.cyl(root, &"armor", Vector3(-0.62, 1.1, 0.42), 0.32, 0.32, 0.06, Vector3(80, 0, 0), 6)
	k.sphere(root, &"gem", Vector3(-0.62, 1.12, 0.47), 0.08)
	var w := k.pivot(root, Vector3(0.55, 1.6, 0.02), Vector3(20, 0, 0))
	k.limb(w, &"armor", Vector3.ZERO, Vector3(0.05, -0.48, 0.1), 0.09)
	k.sphere(w, &"armor", Vector3(0.05, -0.55, 0.12), 0.1)
	k.box(w, &"armor2", Vector3(0.05, -0.55, 0.25), Vector3(0.3, 0.05, 0.08), Vector3(-70, 0, 0))
	k.box(w, &"metal", Vector3(0.05, -0.42, 0.75), Vector3(0.1, 1.0, 0.025), Vector3(-70, 0, 0))
	k.parts["weapon"] = w


static func _gargoyle(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.sphere(root, &"stone", Vector3(0.3 * side, 0.45, -0.2), 0.32, Vector3(1, 1.1, 1.2))
		k.limb(root, &"stone", Vector3(0.32 * side, 0.3, 0.0), Vector3(0.34 * side, 0.08, 0.2), 0.1)
		for t in 3:
			k.spike(root, &"stone2", Vector3(0.34 * side, 0.06, 0.25), Vector3((0.34 + (t - 1) * 0.08) * side, 0.02, 0.45), 0.04)
	var torso := Vector3(0, 1.05, 0.05)
	k.sphere(root, &"stone", torso, 0.45, Vector3(1.05, 1.2, 0.9), Vector3(20, 0, 0))
	var head := Vector3(0, 1.62, 0.38)
	k.sphere(root, &"stone", head, 0.3)
	k.box(root, &"stone", head + Vector3(0, -0.1, 0.25), Vector3(0.26, 0.2, 0.25))
	k.eyes(root, head + Vector3(0, 0.08, 0.26), 0.22, 0.055, &"glow")
	k.box(root, &"stone2", head + Vector3(0, 0.15, 0.26), Vector3(0.36, 0.06, 0.08), Vector3(-10, 0, 0))
	for side in [-1.0, 1.0]:
		k.spike(root, &"tooth", head + Vector3(0.08 * side, -0.2, 0.37), head + Vector3(0.08 * side, -0.3, 0.38), 0.025)
		k.chain(root, &"stone2", [head + Vector3(0.18 * side, 0.22, -0.05), head + Vector3(0.3 * side, 0.4, -0.2), head + Vector3(0.28 * side, 0.5, -0.45)], 0.07, 0.01)
		var elbow := Vector3(0.5 * side, 0.75, 0.45)
		k.limb(root, &"stone", Vector3(0.4 * side, 1.3, 0.15), elbow, 0.1)
		k.limb(root, &"stone", elbow, Vector3(0.45 * side, 0.12, 0.6), 0.09)
		k.sphere(root, &"stone", Vector3(0.45 * side, 0.1, 0.62), 0.12, Vector3(1, 0.6, 1.2))
		var p := k.pivot(root, Vector3(0.28 * side, 1.4, -0.25))
		var tip := Vector3(1.15 * side, 0.7, -0.3)
		k.limb(p, &"stone2", Vector3.ZERO, tip, 0.04)
		for j in 2:
			k.limb(p, &"stone2", tip * (0.5 + j * 0.25), Vector3((0.6 + j * 0.3) * side, -0.3 + j * 0.2, -0.25), 0.025)
		k.sphere(p, &"stone2", Vector3(0.62 * side, 0.2, -0.27), 0.62, Vector3(1.0, 0.72, 0.04), Vector3(0, 0, 32.0 * side))
		k.add_wing(p, side)
	var tail := k.pivot(root, Vector3(0, 0.45, -0.5))
	var pts := ModelKit.curl_points(Vector3.ZERO, Vector3(0, -0.3, -1), Vector3(0.8, 1.2, 0), 0.9, 4)
	k.chain(tail, &"stone", pts, 0.08, 0.03)
	k.spike(tail, &"stone2", pts[pts.size() - 1], pts[pts.size() - 1] + Vector3(0.1, 0.12, -0.12), 0.07)
	k.parts["tail"] = tail
	k.parts["wing_speed"] = 1.0
	k.parts["wing_angle"] = 10.0


static func _dragon(k: ModelKit, root: Node3D) -> void:
	var body := k.sphere(root, &"scales", Vector3(0, 1.25, -0.3), 1.0, Vector3(1.0, 0.85, 1.25))
	body.name = "Torso"
	k.sphere(root, &"belly", Vector3(0, 1.15, 0.45), 0.72, Vector3(0.95, 0.9, 0.55))
	for side in [-1.0, 1.0]:
		for z in [0.35, -0.95]:
			k.capsule(root, &"scales", Vector3(0.62 * side, 0.45, z), 0.26, 0.95)
			for c in 3:
				k.spike(root, &"dark", Vector3(0.62 * side + (c - 1) * 0.1, 0.05, z + 0.22), Vector3(0.62 * side + (c - 1) * 0.12, 0.03, z + 0.4), 0.05)
	k.capsule(root, &"scales", Vector3(0, 2.15, 0.55), 0.34, 1.35, Vector3(30, 0, 0))
	var head := Vector3(0, 2.85, 0.95)
	k.box(root, &"scales", head, Vector3(0.72, 0.58, 0.8))
	k.box(root, &"scales", head + Vector3(0, -0.13, 0.55), Vector3(0.52, 0.34, 0.6))
	k.box(root, &"belly", head + Vector3(0, -0.29, 0.53), Vector3(0.48, 0.1, 0.5))
	for side in [-1.0, 1.0]:
		k.spike(root, &"horn", head + Vector3(0.24 * side, 0.25, -0.15), head + Vector3(0.42 * side, 0.75, -0.55), 0.1)
		k.sphere(root, &"eye_glow", head + Vector3(0.26 * side, 0.13, 0.35), 0.08)
		k.spike(root, &"tooth", head + Vector3(0.18 * side, -0.33, 0.77), head + Vector3(0.18 * side, -0.45, 0.78), 0.035)
		k.sphere(root, &"dark", head + Vector3(0.12 * side, -0.03, 0.85), 0.04)
	for i in 4:
		k.spike(root, &"horn", Vector3(0, 2.15 - i * 0.08, -0.1 - i * 0.45), Vector3(0, 2.5 - i * 0.1, -0.3 - i * 0.45), 0.14)
	k.bone(root, &"scales", Vector3(0, 0.9, -1.35), Vector3(0, 0.45, -2.8), 0.42, 0.12)
	k.spike(root, &"horn", Vector3(0, 0.45, -2.75), Vector3(0, 0.4, -3.2), 0.2)
	for side in [-1.0, 1.0]:
		var p := k.pivot(root, Vector3(0.55 * side, 2.0, -0.35))
		var tip := Vector3(1.9 * side, 1.1, -0.1)
		k.bone(p, &"scales", Vector3.ZERO, tip, 0.1, 0.05)
		for j in 3:
			k.limb(p, &"scales", tip * (0.45 + j * 0.2), Vector3((0.7 + j * 0.5) * side, -0.35 + j * 0.15, -0.4 - j * 0.15), 0.035)
		k.sphere(p, &"membrane", Vector3(1.0 * side, 0.35, -0.3), 1.05, Vector3(1.0, 0.62, 0.04), Vector3(0, 0, 26.0 * side))
		k.add_wing(p, side)
	k.parts["wing_speed"] = 0.7
	k.parts["wing_angle"] = 18.0
