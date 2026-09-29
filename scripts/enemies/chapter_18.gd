class_name EnemyChapter18
extends RefCounted
## チャプター 18「ほしぞらの宇宙」
## 雑魚: UFO / エイリアン / ほしのかけら　ボス: エイリアンクイーン

const CHAPTER := 18
const AREA := "ほしぞらの宇宙"

const MOBS := [
	{
		"id": &"ufo", "idle": &"hover", "height": 1.4, "width": 2.6,
		"names": ["UFO", "ステルスUFO", "マザーUFO"],
		"names_en": ["UFO", "STEALTH UFO", "MOTHER UFO"],
		"attack": "キャトルビーム",
		"desc": "空とぶ円盤。下からのビームで何でもすいこむ。",
		"palettes": [
			{&"hull": {"color": Color(0.75, 0.78, 0.85), "metal": 0.9, "rough": 0.25}, &"dome": {"color": Color(0.5, 0.9, 1.0, 0.55), "emission": 0.4}, &"light": {"color": Color(1.0, 0.9, 0.3), "emission": 3.0}},
			{&"hull": {"color": Color(0.12, 0.12, 0.16), "metal": 0.8, "rough": 0.2}, &"dome": {"color": Color(0.8, 0.3, 1.0, 0.55), "emission": 0.6}, &"light": {"color": Color(0.8, 0.3, 1.0), "emission": 3.0}},
			{&"hull": {"color": Color(1.0, 0.8, 0.3), "metal": 1.0, "rough": 0.15}, &"dome": {"color": Color(0.4, 1.0, 0.5, 0.55), "emission": 0.6}, &"light": {"color": Color(1.0, 0.3, 0.2), "emission": 3.5}},
		],
	},
	{
		"id": &"alien", "idle": &"bounce", "height": 1.7, "width": 2.0,
		"names": ["エイリアン", "グレイ", "コズミックエイリアン"],
		"names_en": ["ALIEN", "GRAY", "COSMIC ALIEN"],
		"attack": "サイコパワー",
		"desc": "遠い星から来た宇宙人。大きな頭で考えたことが現実になる。",
		"palettes": [
			{&"skin": Color(0.45, 0.9, 0.4), &"suit": {"color": Color(0.75, 0.78, 0.85), "metal": 0.8, "rough": 0.3}, &"eye_black": {"color": Color(0.05, 0.05, 0.08), "rough": 0.05, "clearcoat": 1.0}},
			{&"skin": Color(0.62, 0.64, 0.68), &"suit": {"color": Color(0.2, 0.2, 0.25), "metal": 0.7, "rough": 0.3}, &"eye_black": {"color": Color(0.02, 0.02, 0.03), "rough": 0.05, "clearcoat": 1.0}},
			{&"skin": {"color": Color(0.5, 0.4, 1.0), "emission": 0.3}, &"suit": {"color": Color(1.0, 0.85, 0.35), "metal": 0.9, "rough": 0.2}, &"eye_black": {"color": Color(0.2, 0.8, 1.0), "emission": 1.5}},
		],
	},
	{
		"id": &"star_shard", "idle": &"hover", "height": 1.6, "width": 2.0,
		"names": ["ほしのかけら", "ながれぼし", "いちばんぼし"],
		"names_en": ["STAR SHARD", "SHOOTING STAR", "FIRST STAR"],
		"attack": "スターダスト",
		"desc": "空から落ちてきた星のかけら。キラキラ光ってまぶしい。",
		"palettes": [
			{&"star": {"color": Color(1.0, 0.9, 0.3), "emission": 1.0, "rough": 0.3}, &"star2": {"color": Color(1.0, 1.0, 0.8), "emission": 2.0}},
			{&"star": {"color": Color(0.4, 0.8, 1.0), "emission": 1.0, "rough": 0.3}, &"star2": {"color": Color(0.9, 1.0, 1.0), "emission": 2.0}},
			{&"star": {"color": Color(1.0, 0.45, 0.8), "emission": 1.3, "rough": 0.3}, &"star2": {"color": Color(1.0, 0.9, 1.0), "emission": 2.5}},
		],
	},
]

const BOSS := {
	"id": &"alien_queen", "idle": &"breathe", "height": 3.6, "width": 4.0,
	"names": ["エイリアンクイーン", "ダークマター", "ギャラクシークイーン"],
	"names_en": ["ALIEN QUEEN", "DARK MATTER", "GALAXY QUEEN"],
	"attack": "ギャラクシービーム",
	"desc": "宇宙人たちの女王。長い頭から銀河のエネルギーをはなつ。",
	"palettes": [
		{&"shell": {"color": Color(0.15, 0.3, 0.2), "rough": 0.2, "clearcoat": 1.0}, &"shell2": Color(0.5, 0.85, 0.35), &"eye_glow": {"color": Color(1.0, 0.3, 0.9), "emission": 3.0}, &"orb": {"color": Color(0.4, 1.0, 0.6), "emission": 2.5}},
		{&"shell": {"color": Color(0.08, 0.06, 0.12), "rough": 0.15, "clearcoat": 1.0}, &"shell2": Color(0.4, 0.15, 0.6), &"eye_glow": {"color": Color(0.4, 0.9, 1.0), "emission": 3.0}, &"orb": {"color": Color(0.6, 0.2, 1.0), "emission": 3.0}},
		{&"shell": {"color": Color(0.2, 0.25, 0.6), "rough": 0.15, "clearcoat": 1.0}, &"shell2": {"color": Color(1.0, 0.85, 0.4), "metal": 0.8, "rough": 0.2}, &"eye_glow": {"color": Color(1.0, 0.9, 0.3), "emission": 3.5}, &"orb": {"color": Color(1.0, 0.6, 1.0), "emission": 3.5}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"ufo":
			_ufo(k, root)
		&"alien":
			_alien(k, root)
		&"star_shard":
			_star(k, root)
		&"alien_queen":
			_queen(k, root)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _ufo(k: ModelKit, root: Node3D) -> void:
	var c := Vector3(0, 1.1, 0)
	k.sphere(root, &"hull", c, 1.0, Vector3(1, 0.22, 1))
	k.cyl(root, &"hull", c + Vector3(0, -0.2, 0), 0.5, 0.35, 0.15, Vector3.ZERO, 20)
	k.dome(root, &"dome", c + Vector3(0, 0.12, 0), 0.45, 0.4)
	# 中の小さな宇宙人
	k.sphere(root, &"eye_white", c + Vector3(0, 0.3, 0.05), 0.18, Vector3(1, 1.1, 1))
	k.sphere(root, &"pupil", c + Vector3(0, 0.3, 0.2), 0.06)
	for i in 8:
		var a := TAU * i / 8.0
		k.sphere(root, &"light", c + Vector3(sin(a) * 0.82, -0.02, cos(a) * 0.82), 0.07)
	k.cone(root, &"dome", c + Vector3(0, -0.7, 0), 0.4, 0.9, Vector3(180, 0, 0), 16)


static func _alien(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.limb(root, &"suit", Vector3(0.12 * side, 0.5, 0), Vector3(0.14 * side, 0.08, 0.03), 0.07)
		k.sphere(root, &"suit", Vector3(0.14 * side, 0.06, 0.08), 0.08, Vector3(1, 0.6, 1.4))
		k.limb(root, &"skin", Vector3(0.22 * side, 0.85, 0), Vector3(0.4 * side, 0.55, 0.15), 0.05)
		k.sphere(root, &"skin", Vector3(0.42 * side, 0.5, 0.18), 0.07)
	k.capsule(root, &"suit", Vector3(0, 0.72, 0), 0.22, 0.6)
	k.cyl(root, &"skin", Vector3(0, 1.0, 0), 0.06, 0.08, 0.15)
	var head := Vector3(0, 1.35, 0.02)
	k.sphere(root, &"skin", head, 0.38, Vector3(1.1, 1.0, 0.95))
	k.sphere(root, &"skin", head + Vector3(0, -0.28, 0.12), 0.18, Vector3(1, 0.8, 0.9))
	for side in [-1.0, 1.0]:
		k.sphere(root, &"eye_black", head + Vector3(0.15 * side, -0.02, 0.3), 0.13, Vector3(0.8, 1.2, 0.5), Vector3(0, 0, -20.0 * side))
		k.sphere(root, &"shine", head + Vector3(0.12 * side, 0.04, 0.36), 0.03)
		k.limb(root, &"skin", head + Vector3(0.1 * side, 0.3, 0), head + Vector3(0.2 * side, 0.6, -0.05), 0.02)
		k.sphere(root, &"eye_black", head + Vector3(0.2 * side, 0.62, -0.05), 0.05)
	k.box(root, &"mouth", head + Vector3(0, -0.3, 0.27), Vector3(0.08, 0.02, 0.02))


static func _star(k: ModelKit, root: Node3D) -> void:
	var c := Vector3(0, 1.0, 0)
	for i in 5:
		var a := TAU * i / 5.0
		k.bone(root, &"star", c, c + Vector3(sin(a) * 0.75, cos(a) * 0.75, 0), 0.28, 0.05)
	k.sphere(root, &"star", c, 0.32, Vector3(1, 1, 0.6))
	k.eyes(root, c + Vector3(0, 0.05, 0.2), 0.22, 0.07)
	k.sphere(root, &"mouth", c + Vector3(0, -0.1, 0.2), 0.04, Vector3(1.5, 0.7, 0.5))
	for i in 6:
		var a := TAU * i / 6.0 + 0.3
		k.sphere(root, &"star2", c + Vector3(sin(a) * 1.0, cos(a) * 0.9, -0.2), 0.05)


static func _queen(k: ModelKit, root: Node3D) -> void:
	# 4 本の脚
	for side in [-1.0, 1.0]:
		for z in [0.3, -0.4]:
			k.limb(root, &"shell", Vector3(0.35 * side, 1.3, z), Vector3(0.9 * side, 0.9, z * 1.4), 0.08)
			k.bone(root, &"shell", Vector3(0.9 * side, 0.9, z * 1.4), Vector3(1.1 * side, 0.0, z * 1.6), 0.07, 0.02)
	k.sphere(root, &"shell", Vector3(0, 1.35, -0.2), 0.55, Vector3(1, 0.8, 1.4))
	k.sphere(root, &"shell2", Vector3(0, 1.1, -0.9), 0.5, Vector3(1, 0.8, 1.2))
	# 上半身
	k.capsule(root, &"shell", Vector3(0, 2.0, 0.2), 0.3, 0.9)
	for i in 3:
		k.torus(root, &"shell2", Vector3(0, 1.75 + i * 0.18, 0.2), 0.24, 0.32)
	for side in [-1.0, 1.0]:
		k.limb(root, &"shell", Vector3(0.28 * side, 2.3, 0.2), Vector3(0.7 * side, 1.9, 0.6), 0.07)
		k.bone(root, &"shell2", Vector3(0.7 * side, 1.9, 0.6), Vector3(0.75 * side, 2.3, 1.0), 0.06, 0.01)
	# 長い頭
	var head := Vector3(0, 2.65, 0.3)
	k.sphere(root, &"shell", head, 0.3, Vector3(1, 1, 1.2))
	k.bone(root, &"shell2", head + Vector3(0, 0.1, -0.1), head + Vector3(0, 0.6, -1.0), 0.28, 0.06)
	for side in [-1.0, 1.0]:
		k.sphere(root, &"eye_glow", head + Vector3(0.12 * side, 0.05, 0.3), 0.06, Vector3(1.3, 0.7, 0.5))
	for i in 4:
		k.spike(root, &"tooth", head + Vector3((i - 1.5) * 0.06, -0.15, 0.3), head + Vector3((i - 1.5) * 0.06, -0.26, 0.32), 0.02)
	k.sphere(root, &"orb", head + Vector3(0, 0.8, -1.05), 0.14)
