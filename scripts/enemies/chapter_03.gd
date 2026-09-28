class_name EnemyChapter03
extends RefCounted
## チャプター 3「灼熱の砂漠」
## 雑魚: スコーピオン / カクタス / マミー　ボス: サンドワーム

const CHAPTER := 3
const AREA := "灼熱の砂漠"

const MOBS := [
	{
		"id": &"scorpion", "idle": &"breathe", "height": 1.4, "width": 2.5,
		"names": ["サンドスコーピオン", "ブラックスコーピオン", "エンペラースコーピオン"],
		"names_en": ["SAND SCORPION", "BLACK SCORPION", "EMPEROR SCORPION"],
		"attack": "どくのしっぽ",
		"desc": "砂の中にひそむサソリ。しっぽの毒針はとても危険。",
		"palettes": [
			{&"shell": {"color": Color(0.85, 0.65, 0.35), "rough": 0.4}, &"shell2": Color(0.65, 0.45, 0.22), &"glow": {"color": Color(0.6, 1.0, 0.3), "emission": 1.5}},
			{&"shell": {"color": Color(0.12, 0.1, 0.12), "rough": 0.25, "clearcoat": 0.6}, &"shell2": Color(0.3, 0.08, 0.1), &"glow": {"color": Color(1.0, 0.2, 0.1), "emission": 2.5}, &"eye_glow": {"color": Color(1.0, 0.2, 0.1), "emission": 3.0}},
			{&"shell": {"color": Color(0.45, 0.2, 0.6), "rough": 0.3, "clearcoat": 0.6}, &"shell2": {"color": Color(1.0, 0.78, 0.28), "metal": 0.8, "rough": 0.3}, &"glow": {"color": Color(0.4, 0.9, 1.0), "emission": 2.5}},
		],
	},
	{
		"id": &"cactus", "idle": &"bounce", "height": 1.9, "width": 2.0,
		"names": ["カクタス", "フラワーカクタス", "ゴールドカクタス"],
		"names_en": ["CACTUS", "FLOWER CACTUS", "GOLD CACTUS"],
		"attack": "トゲミサイル",
		"desc": "砂漠を歩きまわるサボテン。全身のトゲを飛ばしてくる。",
		"palettes": [
			{&"plant": Color(0.3, 0.62, 0.3), &"plant2": Color(0.22, 0.48, 0.24), &"needle": Color(1.0, 0.97, 0.85), &"flower": Color(1.0, 0.45, 0.7), &"flower2": Color(1.0, 0.9, 0.3)},
			{&"plant": Color(0.2, 0.55, 0.5), &"plant2": Color(0.15, 0.42, 0.4), &"needle": Color(1.0, 0.9, 0.7), &"flower": Color(1.0, 0.35, 0.15), &"flower2": Color(1.0, 0.95, 0.4)},
			{&"plant": {"color": Color(1.0, 0.8, 0.3), "metal": 0.7, "rough": 0.3}, &"plant2": {"color": Color(0.8, 0.6, 0.2), "metal": 0.7}, &"needle": Color(1, 1, 1), &"flower": Color(1, 1, 1), &"flower2": Color(1.0, 0.4, 0.4)},
		],
	},
	{
		"id": &"mummy", "idle": &"sway", "height": 1.95, "width": 2.2,
		"names": ["マミー", "ブラックマミー", "ファラオマミー"],
		"names_en": ["MUMMY", "BLACK MUMMY", "PHARAOH MUMMY"],
		"attack": "ほうたいしめつけ",
		"desc": "ピラミッドからさまよい出たミイラ。ほうたいでしめつける。",
		"palettes": [
			{&"wrap": Color(0.9, 0.85, 0.7), &"wrap2": Color(0.75, 0.68, 0.52), &"eye_glow": {"color": Color(1.0, 0.3, 0.2), "emission": 3.0}},
			{&"wrap": Color(0.3, 0.28, 0.3), &"wrap2": Color(0.18, 0.16, 0.18), &"eye_glow": {"color": Color(0.8, 0.3, 1.0), "emission": 3.0}},
			{&"wrap": {"color": Color(1.0, 0.8, 0.3), "metal": 0.6, "rough": 0.35}, &"wrap2": Color(0.15, 0.3, 0.75), &"eye_glow": {"color": Color(0.3, 1.0, 0.8), "emission": 3.0}},
		],
	},
]

const BOSS := {
	"id": &"sandworm", "idle": &"breathe", "height": 3.4, "width": 3.8,
	"names": ["サンドワーム", "ブラッドワーム", "アビスワーム"],
	"names_en": ["SANDWORM", "BLOOD WORM", "ABYSS WORM"],
	"attack": "まるのみ",
	"desc": "砂漠の底からあらわれる大ミミズ。なんでも丸のみにする。",
	"palettes": [
		{&"body": Color(0.8, 0.6, 0.45), &"body2": Color(0.6, 0.42, 0.3), &"sand": Color(0.92, 0.8, 0.55), &"lip": Color(0.75, 0.3, 0.3), &"eye_glow": {"color": Color(1.0, 0.8, 0.2), "emission": 2.5}},
		{&"body": Color(0.7, 0.2, 0.2), &"body2": Color(0.45, 0.1, 0.12), &"sand": Color(0.85, 0.7, 0.5), &"lip": Color(0.3, 0.05, 0.08), &"eye_glow": {"color": Color(1.0, 0.95, 0.4), "emission": 3.0}},
		{&"body": Color(0.3, 0.2, 0.45), &"body2": {"color": Color(0.2, 0.8, 0.9), "emission": 0.8}, &"sand": Color(0.35, 0.3, 0.4), &"lip": Color(0.15, 0.08, 0.2), &"eye_glow": {"color": Color(0.3, 1.0, 1.0), "emission": 3.0}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"scorpion":
			_scorpion(k, root)
		&"cactus":
			_cactus(k, root)
		&"mummy":
			_mummy(k, root)
		&"sandworm":
			_sandworm(k, root)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _scorpion(k: ModelKit, root: Node3D) -> void:
	k.sphere(root, &"shell", Vector3(0, 0.38, 0.3), 0.32, Vector3(1.25, 0.6, 1.0))
	k.sphere(root, &"shell", Vector3(0, 0.38, -0.05), 0.3, Vector3(1.2, 0.6, 1.0))
	k.sphere(root, &"shell2", Vector3(0, 0.38, -0.35), 0.26, Vector3(1.1, 0.6, 1.0))
	var head := Vector3(0, 0.42, 0.58)
	k.sphere(root, &"shell", head, 0.22, Vector3(1.1, 0.75, 1))
	k.eyes(root, head + Vector3(0, 0.1, 0.16), 0.16, 0.045, &"glow")
	for side in [-1.0, 1.0]:
		var elbow := Vector3(0.62 * side, 0.4, 0.85)
		k.limb(root, &"shell", Vector3(0.28 * side, 0.38, 0.55), elbow, 0.08)
		k.limb(root, &"shell", elbow, Vector3(0.55 * side, 0.45, 1.15), 0.08)
		var claw := Vector3(0.55 * side, 0.48, 1.25)
		k.sphere(root, &"shell2", claw, 0.19, Vector3(1.0, 0.7, 1.3))
		k.spike(root, &"shell2", claw + Vector3(0.04 * side, 0.05, 0.12), claw + Vector3(0.0, 0.1, 0.48), 0.08)
		k.spike(root, &"shell2", claw + Vector3(-0.06 * side, -0.04, 0.12), claw + Vector3(-0.1 * side, -0.02, 0.4), 0.06)
		for z in [0.2, -0.05, -0.3]:
			var knee := Vector3(0.62 * side, 0.52, z - 0.02)
			k.limb(root, &"shell2", Vector3(0.3 * side, 0.36, z), knee, 0.045)
			k.limb(root, &"shell2", knee, Vector3(0.82 * side, 0.02, z - 0.08), 0.04)
	var pts := ModelKit.curl_points(Vector3(0, 0.42, -0.55), Vector3(0, 0.35, -1), Vector3(0, 3.0, 5.2), 1.6, 7)
	k.chain(root, &"shell", pts, 0.16, 0.11)
	var last: Vector3 = pts[pts.size() - 1]
	k.sphere(root, &"shell2", last, 0.13)
	k.spike(root, &"glow", last + Vector3(0, 0, 0.05), last + Vector3(0, -0.2, 0.35), 0.07)


static func _cactus(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.sphere(root, &"plant2", Vector3(0.18 * side, 0.08, 0.05), 0.14, Vector3(1, 0.6, 1.3))
	var c := Vector3(0, 0.85, 0)
	k.capsule(root, &"plant", c, 0.36, 1.55)
	for i in 8:
		var a := TAU * i / 8.0
		k.capsule(root, &"plant2", c + Vector3(sin(a) * 0.3, 0, cos(a) * 0.3), 0.07, 1.35)
	# 腕
	k.limb(root, &"plant", Vector3(0.3, 0.85, 0), Vector3(0.62, 0.9, 0), 0.15)
	k.limb(root, &"plant", Vector3(0.62, 0.9, 0), Vector3(0.64, 1.3, 0), 0.15)
	k.limb(root, &"plant", Vector3(-0.3, 0.62, 0), Vector3(-0.6, 0.64, 0), 0.14)
	k.limb(root, &"plant", Vector3(-0.6, 0.64, 0), Vector3(-0.62, 0.98, 0), 0.14)
	# トゲ
	for el in [-40.0, -10.0, 20.0, 50.0]:
		for az in [-150.0, -100.0, -45.0, 45.0, 100.0, 150.0, 0.0, 180.0]:
			if az == 0.0 and el > -20.0 and el < 40.0:
				continue
			k.spike_out(root, &"needle", c, Vector3(0.36, 0.78, 0.36), az + el * 0.5, el, 0.12, 0.02)
	# 顔
	k.eyes(root, Vector3(0, 1.1, 0.34), 0.26, 0.055, &"dot")
	k.sphere(root, &"mouth", Vector3(0, 0.92, 0.35), 0.07, Vector3(1.2, 1.0, 0.5))
	for x in [-0.2, 0.2]:
		k.sphere(root, &"blush", Vector3(x, 1.0, 0.31), 0.05, Vector3(1.2, 0.6, 0.4))
	# 花
	var top := Vector3(0, 1.62, 0)
	for i in 6:
		var a := TAU * i / 6.0
		k.sphere(root, &"flower", top + Vector3(sin(a) * 0.14, 0.02, cos(a) * 0.14), 0.1, Vector3(1, 0.4, 1))
	k.sphere(root, &"flower2", top + Vector3(0, 0.05, 0), 0.08)
	k.sphere(root, &"flower", Vector3(0.64, 1.47, 0), 0.07, Vector3(1, 0.5, 1))


static func _mummy(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.limb(root, &"wrap", Vector3(0.14 * side, 0.85, 0), Vector3(0.15 * side, 0.08, 0.03), 0.11)
		for y in [0.25, 0.5, 0.72]:
			k.torus(root, &"wrap2", Vector3(0.145 * side, y, 0.015), 0.09, 0.135, Vector3(0, 0, 10.0 * side), Vector3(1, 0.5, 1))
	k.capsule(root, &"wrap", Vector3(0, 1.2, 0), 0.31, 0.95)
	for i in 5:
		var y := 0.88 + i * 0.15
		k.torus(root, &"wrap2", Vector3(0, y, 0), 0.26, 0.345, Vector3(0, 0, 8.0 if i % 2 == 0 else -8.0), Vector3(1, 0.45, 1))
	var head := Vector3(0, 1.82, 0.02)
	k.sphere(root, &"wrap", head, 0.25)
	for i in 3:
		k.torus(root, &"wrap2", head + Vector3(0, -0.1 + i * 0.1, 0), 0.2, 0.27, Vector3(0, 0, 12.0 - i * 12.0), Vector3(1, 0.45, 1))
	k.sphere(root, &"dark", head + Vector3(0.09, 0.03, 0.2), 0.06, Vector3(1, 0.7, 0.6))
	k.sphere(root, &"eye_glow", head + Vector3(0.09, 0.03, 0.23), 0.04)
	k.sphere(root, &"dark", head + Vector3(-0.08, -0.1, 0.21), 0.04, Vector3(1.4, 0.6, 0.6))
	for side in [-1.0, 1.0]:
		k.limb(root, &"wrap", Vector3(0.36 * side, 1.5, 0), Vector3(0.36 * side, 1.4, 0.6), 0.08)
		k.sphere(root, &"wrap", Vector3(0.36 * side, 1.4, 0.68), 0.09)
		k.box(root, &"wrap2", Vector3(0.36 * side, 1.25, 0.35), Vector3(0.06, 0.3, 0.02), Vector3(0, 0, 8.0 * side))


static func _sandworm(k: ModelKit, root: Node3D) -> void:
	k.sphere(root, &"sand", Vector3(0, 0, -0.2), 1.3, Vector3(1.2, 0.28, 1.1))
	for p in [Vector3(1.1, 0.05, 0.5), Vector3(-1.2, 0.05, 0.1), Vector3(0.6, 0.05, -1.2)]:
		k.sphere(root, &"sand", p, 0.3, Vector3(1, 0.4, 1))
	var pts := [Vector3(0, 0.1, -0.5), Vector3(0, 0.8, -0.58), Vector3(0, 1.5, -0.5), Vector3(0, 2.15, -0.25), Vector3(0, 2.6, 0.18), Vector3(0, 2.75, 0.6)]
	var radii := [0.78, 0.74, 0.7, 0.66, 0.63, 0.6]
	for i in pts.size():
		k.sphere(root, &"body", pts[i], radii[i])
		if i > 0:
			var mid: Vector3 = (pts[i] + pts[i - 1]) * 0.5
			var dir: Vector3 = pts[i] - pts[i - 1]
			var ring := k.torus(root, &"body2", mid, radii[i] * 0.85, radii[i] * 1.02)
			ring.basis = ModelKit.basis_from_up(dir) * Basis.from_scale(Vector3(1, 0.5, 1))
		k.spike(root, &"body2", pts[i] + Vector3(0, radii[i] * 0.3, -radii[i] * 0.85), pts[i] + Vector3(0, radii[i] * 0.6, -radii[i] * 1.35), 0.12)
	var mouth := Vector3(0, 2.72, 1.12)
	var lip := k.torus(root, &"lip", mouth, 0.34, 0.6, Vector3(90, 0, 0))
	lip.scale = Vector3(1, 0.6, 1)
	k.sphere(root, &"mouth", mouth + Vector3(0, 0, -0.05), 0.42, Vector3(1, 1, 0.3))
	for i in 12:
		var a := TAU * i / 12.0
		var ring := Vector3(sin(a), cos(a), 0)
		k.spike(root, &"tooth", mouth + ring * 0.44 + Vector3(0, 0, 0.04), mouth + ring * 0.2 + Vector3(0, 0, 0.12), 0.06)
	for i in 4:
		var a := deg_to_rad(-50.0 + i * 33.0)
		k.sphere(root, &"eye_glow", mouth + Vector3(sin(a) * 0.72, cos(a) * 0.62, -0.12), 0.07)
