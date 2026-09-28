class_name EnemyChapter07
extends RefCounted
## チャプター 7「ほのおの火山」
## 雑魚: ウィスプ / サラマンダー / ファイアタートル　ボス: フェニックス

const CHAPTER := 7
const AREA := "ほのおの火山"

const MOBS := [
	{
		"id": &"wisp", "idle": &"flicker", "height": 1.7, "width": 2.0,
		"names": ["ウィスプ", "ブルーウィスプ", "ダークウィスプ"],
		"names_en": ["WISP", "BLUE WISP", "DARK WISP"],
		"attack": "ひのこ",
		"desc": "火山にただようほのおの精。さわるとやけどする。",
		"palettes": [
			{&"flame": {"color": Color(1.0, 0.45, 0.1), "emission": 2.2}, &"flame2": {"color": Color(1.0, 0.85, 0.3), "emission": 3.0}},
			{&"flame": {"color": Color(0.2, 0.5, 1.0), "emission": 2.2}, &"flame2": {"color": Color(0.6, 0.95, 1.0), "emission": 3.0}},
			{&"flame": {"color": Color(0.5, 0.15, 0.8), "emission": 2.2}, &"flame2": {"color": Color(1.0, 0.4, 0.9), "emission": 3.0}},
		],
	},
	{
		"id": &"salamander", "idle": &"breathe", "height": 1.3, "width": 2.4,
		"names": ["サラマンダー", "マグマサラマンダー", "ゴールドサラマンダー"],
		"names_en": ["SALAMANDER", "MAGMA SALAMANDER", "GOLD SALAMANDER"],
		"attack": "ほのおのいき",
		"desc": "溶岩の中でくらすトカゲ。背中のほのおで体温をたもつ。",
		"palettes": [
			{&"scales": Color(0.9, 0.35, 0.15), &"belly": Color(1.0, 0.78, 0.4), &"flame": {"color": Color(1.0, 0.7, 0.15), "emission": 2.5}},
			{&"scales": {"color": Color(0.14, 0.1, 0.1), "rough": 0.9}, &"belly": {"color": Color(1.0, 0.35, 0.05), "emission": 1.5}, &"flame": {"color": Color(1.0, 0.4, 0.05), "emission": 3.0}},
			{&"scales": {"color": Color(1.0, 0.8, 0.3), "metal": 0.8, "rough": 0.3}, &"belly": Color(1.0, 0.95, 0.8), &"flame": {"color": Color(0.6, 0.85, 1.0), "emission": 3.0}},
		],
	},
	{
		"id": &"fire_turtle", "idle": &"breathe", "height": 1.5, "width": 2.4,
		"names": ["ファイアタートル", "アイアンタートル", "ジェムタートル"],
		"names_en": ["FIRE TURTLE", "IRON TURTLE", "GEM TURTLE"],
		"attack": "ふんかこうら",
		"desc": "こうらに小さな火山をせおったカメ。ときどき噴火する。",
		"palettes": [
			{&"shell": Color(0.35, 0.25, 0.2), &"shell2": Color(0.22, 0.15, 0.12), &"skin": Color(0.45, 0.6, 0.3), &"rock": Color(0.3, 0.26, 0.25), &"flame": {"color": Color(1.0, 0.45, 0.1), "emission": 3.0}},
			{&"shell": {"color": Color(0.55, 0.57, 0.62), "metal": 0.8, "rough": 0.35}, &"shell2": {"color": Color(0.3, 0.32, 0.36), "metal": 0.8}, &"skin": Color(0.45, 0.45, 0.5), &"rock": {"color": Color(0.4, 0.42, 0.46), "metal": 0.6}, &"flame": {"color": Color(0.3, 0.6, 1.0), "emission": 3.0}},
			{&"shell": {"color": Color(0.6, 0.3, 0.85), "rough": 0.1, "emission": 0.35, "clearcoat": 1.0}, &"shell2": {"color": Color(0.35, 0.15, 0.55), "rough": 0.1}, &"skin": Color(0.3, 0.7, 0.65), &"rock": {"color": Color(0.85, 0.5, 1.0), "rough": 0.1, "emission": 0.5}, &"flame": {"color": Color(1.0, 0.5, 0.8), "emission": 3.0}},
		],
	},
]

const BOSS := {
	"id": &"phoenix", "idle": &"hover", "height": 3.5, "width": 4.4,
	"names": ["フェニックス", "ブルーフェニックス", "ダークフェニックス"],
	"names_en": ["PHOENIX", "BLUE PHOENIX", "DARK PHOENIX"],
	"attack": "ほうおうのほのお",
	"desc": "火山の火口にすむ不死鳥。ほのおの中から何度でもよみがえる。",
	"palettes": [
		{&"plume": {"color": Color(0.95, 0.25, 0.12), "emission": 0.6}, &"plume2": {"color": Color(1.0, 0.65, 0.1), "emission": 2.0}, &"beak": {"color": Color(1.0, 0.8, 0.3), "metal": 0.7, "rough": 0.3}, &"eye_glow": {"color": Color(1.0, 0.95, 0.5), "emission": 3.0}},
		{&"plume": {"color": Color(0.15, 0.4, 0.95), "emission": 0.6}, &"plume2": {"color": Color(0.4, 0.95, 1.0), "emission": 2.0}, &"beak": {"color": Color(0.85, 0.9, 1.0), "metal": 0.7, "rough": 0.25}, &"eye_glow": {"color": Color(1.0, 1.0, 1.0), "emission": 3.0}},
		{&"plume": {"color": Color(0.18, 0.08, 0.22), "emission": 0.2}, &"plume2": {"color": Color(0.8, 0.2, 1.0), "emission": 2.2}, &"beak": {"color": Color(0.3, 0.3, 0.35), "metal": 0.8, "rough": 0.3}, &"eye_glow": {"color": Color(1.0, 0.2, 0.3), "emission": 3.0}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"wisp":
			_wisp(k, root)
		&"salamander":
			_salamander(k, root)
		&"fire_turtle":
			_turtle(k, root)
		&"phoenix":
			_phoenix(k, root)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _wisp(k: ModelKit, root: Node3D) -> void:
	var c := Vector3(0, 0.95, 0)
	k.sphere(root, &"flame", c, 0.45)
	k.spike(root, &"flame", c + Vector3(0, 0.2, -0.05), c + Vector3(0.05, 0.95, -0.2), 0.3)
	for i in 8:
		var az := i * 45.0
		var el := 35.0 if i % 2 == 0 else 10.0
		var p := ModelKit.surface_point(c, Vector3(0.43, 0.43, 0.43), az, el)
		var out := (p - c).normalized()
		k.spike(root, &"flame", p - out * 0.1, p + out * 0.18 + Vector3(0, 0.45, 0) - Vector3(0, 0, 0.1), 0.13)
	for i in 3:
		var a := deg_to_rad(150.0 + i * 30.0)
		k.spike(root, &"flame", c + Vector3(sin(a) * 0.2, -0.25, cos(a) * 0.2), c + Vector3(sin(a) * 0.35, -0.8, cos(a) * 0.5 - 0.2), 0.12)
	k.sphere(root, &"flame2", c + Vector3(0, -0.05, 0.12), 0.34)
	k.eyes(root, c + Vector3(0, 0.08, 0.44), 0.24, 0.07, &"dot")
	k.sphere(root, &"mouth", c + Vector3(0, -0.12, 0.44), 0.07, Vector3(1.3, 1.0, 0.5))
	for p in [Vector3(0.7, 1.4, 0.1), Vector3(-0.65, 0.7, 0.2), Vector3(0.55, 0.45, -0.3), Vector3(-0.5, 1.55, -0.2)]:
		k.sphere(root, &"flame2", p, 0.07)


static func _salamander(k: ModelKit, root: Node3D) -> void:
	k.capsule(root, &"scales", Vector3(0, 0.42, -0.05), 0.28, 1.35, Vector3(90, 0, 0))
	k.sphere(root, &"belly", Vector3(0, 0.3, 0), 0.26, Vector3(1, 0.5, 2.2))
	var head := Vector3(0, 0.52, 0.78)
	k.sphere(root, &"scales", head, 0.27, Vector3(1.1, 0.75, 1.3))
	k.box(root, &"dark", head + Vector3(0, -0.07, 0.25), Vector3(0.36, 0.03, 0.12))
	for side in [-1.0, 1.0]:
		k.sphere(root, &"scales", head + Vector3(0.16 * side, 0.15, 0.05), 0.1)
		k.sphere(root, &"eye_white", head + Vector3(0.17 * side, 0.18, 0.1), 0.075)
		k.sphere(root, &"pupil", head + Vector3(0.18 * side, 0.18, 0.16), 0.035, Vector3(0.5, 1.2, 0.5))
		for z in [0.42, -0.42]:
			var knee := Vector3(0.52 * side, 0.4, z + 0.08)
			k.limb(root, &"scales", Vector3(0.22 * side, 0.4, z), knee, 0.07)
			k.limb(root, &"scales", knee, Vector3(0.58 * side, 0.03, z + 0.15), 0.06)
			for t in 3:
				k.spike(root, &"belly", Vector3(0.58 * side, 0.03, z + 0.15), Vector3((0.58 + (t - 1) * 0.08) * side, 0.02, z + 0.3), 0.025)
	for i in 5:
		var z := 0.45 - i * 0.22
		k.spike(root, &"flame", Vector3(0, 0.62, z), Vector3(0, 0.95 - i * 0.03, z - 0.12), 0.1)
	var tail := k.pivot(root, Vector3(0, 0.42, -0.72))
	k.chain(tail, &"scales", ModelKit.curl_points(Vector3.ZERO, Vector3(0, -0.2, -1), Vector3(1.2, 0.3, 0), 1.2, 5), 0.22, 0.04)
	k.parts["tail"] = tail


static func _turtle(k: ModelKit, root: Node3D) -> void:
	k.sphere(root, &"skin", Vector3(0, 0.38, 0), 0.8, Vector3(1, 0.35, 1.05))
	var shell_c := Vector3(0, 0.38, -0.05)
	k.dome(root, &"shell", shell_c, 0.9, 0.75)
	k.torus(root, &"shell2", shell_c + Vector3(0, 0.02, 0), 0.82, 0.96, Vector3.ZERO, Vector3(1, 0.4, 1))
	var radii := Vector3(0.9, 0.75, 0.9)
	for s in [[0, 80], [0, 40], [60, 40], [120, 40], [180, 40], [240, 40], [300, 40]]:
		k.stud(root, &"shell2", shell_c, radii, s[0], s[1], Vector3(0.24, 0.05, 0.24))
	for s in [[30, 55, 0.55], [150, 50, 0.5], [270, 58, 0.62], [0, 88, 0.7]]:
		var p := ModelKit.surface_point(shell_c, radii, s[0], s[1])
		var top := p + Vector3(0, s[2], 0)
		k.bone(root, &"rock", p - Vector3(0, 0.1, 0), top, 0.2, 0.08, 8)
		k.sphere(root, &"flame", top + Vector3(0, 0.05, 0), 0.1)
		k.spike(root, &"flame", top, top + Vector3(0, 0.3, 0), 0.08)
	k.limb(root, &"skin", Vector3(0, 0.42, 0.7), Vector3(0, 0.55, 0.98), 0.17)
	var head := Vector3(0, 0.6, 1.08)
	k.sphere(root, &"skin", head, 0.26, Vector3(1, 0.9, 1.1))
	k.eyes(root, head + Vector3(0, 0.08, 0.22), 0.24, 0.06, &"angry", &"shell2")
	k.box(root, &"dark", head + Vector3(0, -0.08, 0.25), Vector3(0.2, 0.03, 0.05))
	for p in [Vector3(0.6, 0.18, 0.5), Vector3(-0.6, 0.18, 0.5), Vector3(0.6, 0.18, -0.55), Vector3(-0.6, 0.18, -0.55)]:
		k.cyl(root, &"skin", p, 0.17, 0.19, 0.38)
	k.spike(root, &"skin", Vector3(0, 0.35, -0.85), Vector3(0, 0.25, -1.15), 0.1)


static func _phoenix(k: ModelKit, root: Node3D) -> void:
	var body := Vector3(0, 1.95, 0)
	k.sphere(root, &"plume", body, 0.55, Vector3(1, 1.1, 1.25))
	k.sphere(root, &"plume2", body + Vector3(0, -0.05, 0.35), 0.4, Vector3(1, 1.1, 0.7))
	k.limb(root, &"plume", body + Vector3(0, 0.3, 0.3), Vector3(0, 2.75, 0.62), 0.22)
	var head := Vector3(0, 2.9, 0.72)
	k.sphere(root, &"plume", head, 0.3)
	k.spike(root, &"beak", head + Vector3(0, -0.02, 0.24), head + Vector3(0, -0.2, 0.62), 0.1)
	k.eyes(root, head + Vector3(0, 0.08, 0.22), 0.3, 0.06, &"glow")
	for i in 3:
		var pts := ModelKit.curl_points(head + Vector3((i - 1) * 0.08, 0.25, -0.05), Vector3((i - 1) * 0.3, 1, -0.3), Vector3(0, -0.6, -1.2), 0.75 + i % 2 * 0.2, 3)
		k.chain(root, &"plume2", pts, 0.07, 0.02)
	for side in [-1.0, 1.0]:
		var p := k.pivot(root, body + Vector3(0.4 * side, 0.2, -0.1))
		for j in 6:
			var a := deg_to_rad(8.0 + j * 14.0)
			var length := 1.7 - j * 0.14
			var mid := Vector3(cos(a) * length * 0.5 * side, sin(a) * length * 0.5, -0.06 * j)
			k.sphere(p, &"plume2" if j % 2 == 0 else &"plume", mid, length * 0.5, Vector3(1, 0.16, 0.05), Vector3(0, 0, rad_to_deg(a) * side))
		k.add_wing(p, side)
		var foot := body + Vector3(0.18 * side, -0.95, 0.15)
		k.limb(root, &"beak", body + Vector3(0.18 * side, -0.4, 0.05), foot, 0.05)
		for t in 3:
			k.spike(root, &"beak", foot, foot + Vector3((t - 1) * 0.1, -0.08, 0.15), 0.03)
	for i in 5:
		var a := deg_to_rad(-40.0 + i * 20.0)
		var pts := ModelKit.curl_points(body + Vector3(0, -0.25, -0.55), Vector3(sin(a) * 0.4, -0.6, -1), Vector3(sin(a) * 0.3, 1.4, 0), 1.3 + (2 - absi(i - 2)) * 0.25, 4)
		k.chain(root, &"plume2" if i % 2 == 0 else &"plume", pts, 0.1, 0.03)
	k.parts["wing_speed"] = 0.45
	k.parts["wing_angle"] = 22.0
