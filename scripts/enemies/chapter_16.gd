class_name EnemyChapter16
extends RefCounted
## チャプター 16「こだいの神殿」
## 雑魚: スカラベ / アヌビスせんし / トーテム　ボス: ファラオ

const CHAPTER := 16
const AREA := "こだいの神殿"

const MOBS := [
	{
		"id": &"scarab", "idle": &"breathe", "height": 1.2, "width": 2.4,
		"names": ["スカラベ", "ルビースカラベ", "エメラルドスカラベ"],
		"names_en": ["SCARAB", "RUBY SCARAB", "EMERALD SCARAB"],
		"attack": "かたいつの",
		"desc": "神殿の床をはいまわる聖なるコガネムシ。背中は宝石のようにかがやく。",
		"palettes": [
			{&"shell": {"color": Color(0.1, 0.35, 0.55), "metal": 0.7, "rough": 0.2}, &"body": Color(0.15, 0.12, 0.1), &"sun": {"color": Color(1.0, 0.75, 0.2), "metal": 0.9, "rough": 0.25}},
			{&"shell": {"color": Color(0.75, 0.08, 0.15), "metal": 0.6, "rough": 0.15, "clearcoat": 1.0}, &"body": Color(0.2, 0.08, 0.08), &"sun": {"color": Color(1.0, 0.85, 0.5), "metal": 0.9, "rough": 0.25}},
			{&"shell": {"color": Color(0.1, 0.75, 0.4), "metal": 0.6, "rough": 0.15, "clearcoat": 1.0}, &"body": Color(0.05, 0.2, 0.12), &"sun": {"color": Color(0.8, 0.95, 1.0), "emission": 1.2}},
		],
	},
	{
		"id": &"anubis", "idle": &"sway", "height": 2.0, "width": 2.4,
		"names": ["アヌビスせんし", "ブラックアヌビス", "ゴールドアヌビス"],
		"names_en": ["ANUBIS", "BLACK ANUBIS", "GOLD ANUBIS"],
		"attack": "やりのひとつき",
		"desc": "犬の頭をもつ神殿の戦士。死者の眠りをまもっている。",
		"palettes": [
			{&"fur": Color(0.15, 0.13, 0.15), &"cloth": Color(0.95, 0.92, 0.85), &"trim": {"color": Color(1.0, 0.78, 0.25), "metal": 0.9, "rough": 0.3}, &"eye_glow": {"color": Color(1.0, 0.8, 0.2), "emission": 3.0}},
			{&"fur": Color(0.08, 0.06, 0.1), &"cloth": Color(0.3, 0.1, 0.35), &"trim": {"color": Color(0.7, 0.72, 0.78), "metal": 0.9, "rough": 0.3}, &"eye_glow": {"color": Color(0.7, 0.3, 1.0), "emission": 3.0}},
			{&"fur": {"color": Color(1.0, 0.8, 0.3), "metal": 0.8, "rough": 0.3}, &"cloth": Color(0.15, 0.3, 0.6), &"trim": {"color": Color(0.2, 0.5, 0.9), "metal": 0.6, "rough": 0.3}, &"eye_glow": {"color": Color(0.3, 0.9, 1.0), "emission": 3.5}},
		],
	},
	{
		"id": &"totem", "idle": &"breathe", "height": 2.0, "width": 1.8,
		"names": ["トーテム", "のろいのトーテム", "たいようのトーテム"],
		"names_en": ["TOTEM", "CURSED TOTEM", "SUN TOTEM"],
		"attack": "じならし",
		"desc": "顔がつみかさなった木の柱。3 つの顔が別々にしゃべる。",
		"palettes": [
			{&"wood": Color(0.6, 0.38, 0.2), &"paint": Color(0.85, 0.2, 0.15), &"paint2": Color(0.2, 0.6, 0.7), &"eye_glow": {"color": Color(1.0, 0.9, 0.3), "emission": 2.5}},
			{&"wood": Color(0.3, 0.25, 0.25), &"paint": Color(0.5, 0.15, 0.55), &"paint2": Color(0.2, 0.8, 0.3), &"eye_glow": {"color": Color(0.5, 1.0, 0.3), "emission": 3.0}},
			{&"wood": {"color": Color(1.0, 0.8, 0.3), "metal": 0.7, "rough": 0.3}, &"paint": Color(1.0, 0.45, 0.1), &"paint2": Color(0.95, 0.95, 0.9), &"eye_glow": {"color": Color(1.0, 0.4, 0.2), "emission": 3.5}},
		],
	},
]

const BOSS := {
	"id": &"pharaoh", "idle": &"hover", "height": 3.6, "width": 3.8,
	"names": ["ファラオ", "やみのファラオ", "たいようのファラオ"],
	"names_en": ["PHARAOH", "DARK PHARAOH", "SUN PHARAOH"],
	"attack": "ピラミッドのろい",
	"desc": "神殿のおくで目ざめた古代の王。黄金のつえで砂嵐をよぶ。",
	"palettes": [
		{&"wrap": Color(0.9, 0.85, 0.72), &"gold": {"color": Color(1.0, 0.78, 0.25), "metal": 0.95, "rough": 0.25}, &"stripe": Color(0.15, 0.3, 0.75), &"cloth": Color(0.95, 0.95, 0.9), &"eye_glow": {"color": Color(0.3, 1.0, 0.7), "emission": 3.0}},
		{&"wrap": Color(0.25, 0.22, 0.25), &"gold": {"color": Color(0.7, 0.7, 0.75), "metal": 0.95, "rough": 0.2}, &"stripe": Color(0.5, 0.1, 0.5), &"cloth": Color(0.15, 0.1, 0.18), &"eye_glow": {"color": Color(1.0, 0.2, 0.4), "emission": 3.0}},
		{&"wrap": Color(1.0, 0.95, 0.85), &"gold": {"color": Color(1.0, 0.85, 0.35), "metal": 1.0, "rough": 0.1}, &"stripe": Color(0.9, 0.2, 0.15), &"cloth": Color(1.0, 0.9, 0.6), &"eye_glow": {"color": Color(1.0, 0.9, 0.3), "emission": 3.5}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"scarab":
			_scarab(k, root)
		&"anubis":
			_anubis(k, root)
		&"totem":
			_totem(k, root)
		&"pharaoh":
			_pharaoh(k, root)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _scarab(k: ModelKit, root: Node3D) -> void:
	k.sphere(root, &"body", Vector3(0, 0.35, 0.05), 0.4, Vector3(1.1, 0.6, 1.2))
	for side in [-1.0, 1.0]:
		k.sphere(root, &"shell", Vector3(0.24 * side, 0.55, -0.1), 0.42, Vector3(0.62, 0.6, 1.25), Vector3(0, 0, -8.0 * side))
		for i in 3:
			var z := 0.35 - i * 0.3
			k.limb(root, &"body", Vector3(0.35 * side, 0.3, z), Vector3(0.65 * side, 0.02, z + 0.1), 0.04)
	k.box(root, &"dark", Vector3(0, 0.78, -0.1), Vector3(0.02, 0.1, 1.0))
	var head := Vector3(0, 0.45, 0.6)
	k.sphere(root, &"body", head, 0.24, Vector3(1.3, 0.8, 1))
	k.eyes(root, head + Vector3(0, 0.06, 0.18), 0.3, 0.06, &"glow")
	k.bone(root, &"shell", head + Vector3(0, 0.1, 0.1), head + Vector3(0, 0.5, 0.35), 0.08, 0.02)
	# 背中の太陽の紋章
	k.cyl(root, &"sun", Vector3(0, 0.83, -0.05), 0.18, 0.18, 0.04, Vector3.ZERO, 16)
	for i in 8:
		var a := TAU * i / 8.0
		k.box(root, &"sun", Vector3(sin(a) * 0.25, 0.83, cos(a) * 0.25 - 0.05), Vector3(0.05, 0.03, 0.1), Vector3(0, rad_to_deg(a), 0))


static func _anubis(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.limb(root, &"fur", Vector3(0.16 * side, 0.8, 0), Vector3(0.18 * side, 0.1, 0.05), 0.08)
		k.box(root, &"trim", Vector3(0.18 * side, 0.05, 0.08), Vector3(0.16, 0.08, 0.28))
	k.cone(root, &"cloth", Vector3(0, 0.75, 0), 0.25, 0.45, Vector3(180, 0, 0))
	k.box(root, &"trim", Vector3(0, 0.9, 0.2), Vector3(0.12, 0.4, 0.04))
	k.cyl(root, &"fur", Vector3(0, 1.2, 0), 0.28, 0.22, 0.6)
	k.torus(root, &"trim", Vector3(0, 1.45, 0), 0.22, 0.34, Vector3.ZERO, Vector3(1, 0.5, 1))
	var head := Vector3(0, 1.72, 0.05)
	k.sphere(root, &"fur", head, 0.22)
	k.bone(root, &"fur", head + Vector3(0, -0.05, 0.12), head + Vector3(0, -0.1, 0.45), 0.12, 0.05)
	k.sphere(root, &"dark", head + Vector3(0, -0.08, 0.48), 0.04)
	for side in [-1.0, 1.0]:
		k.spike(root, &"fur", head + Vector3(0.12 * side, 0.15, -0.03), head + Vector3(0.18 * side, 0.55, -0.1), 0.07)
		k.sphere(root, &"eye_glow", head + Vector3(0.1 * side, 0.05, 0.18), 0.04)
	k.limb(root, &"fur", Vector3(-0.3, 1.4, 0), Vector3(-0.42, 1.0, 0.15), 0.06)
	var w := k.pivot(root, Vector3(0.3, 1.4, 0))
	k.limb(w, &"fur", Vector3.ZERO, Vector3(0.1, -0.35, 0.15), 0.06)
	k.limb(w, &"wood", Vector3(0.1, -0.9, 0.2), Vector3(0.1, 0.6, 0.2), 0.03)
	k.bone(w, &"trim", Vector3(0.1, 0.55, 0.2), Vector3(0.1, 0.9, 0.2), 0.07, 0.01)
	k.parts["weapon"] = w


static func _totem(k: ModelKit, root: Node3D) -> void:
	var faces := [[0.35, &"paint"], [0.95, &"paint2"], [1.55, &"paint"]]
	for f in faces:
		var y: float = f[0]
		k.cyl(root, &"wood", Vector3(0, y, 0), 0.4, 0.42, 0.58, Vector3.ZERO, 12)
		k.box(root, f[1], Vector3(0, y + 0.12, 0.38), Vector3(0.5, 0.08, 0.06))
		for side in [-1.0, 1.0]:
			k.sphere(root, &"dark", Vector3(0.14 * side, y + 0.02, 0.38), 0.08, Vector3(1, 0.8, 0.5))
			k.sphere(root, &"eye_glow", Vector3(0.14 * side, y + 0.02, 0.42), 0.04)
		k.box(root, &"mouth", Vector3(0, y - 0.16, 0.39), Vector3(0.24, 0.07, 0.04))
	# つばさ・くちばし（いちばん上）
	k.bone(root, &"paint2", Vector3(0, 1.55, 0.35), Vector3(0, 1.45, 0.65), 0.1, 0.02)
	for side in [-1.0, 1.0]:
		k.box(root, &"paint", Vector3(0.6 * side, 1.7, 0), Vector3(0.5, 0.15, 0.1), Vector3(0, 0, 15.0 * side))
		k.box(root, &"paint2", Vector3(0.75 * side, 1.62, 0.02), Vector3(0.25, 0.1, 0.1), Vector3(0, 0, 15.0 * side))


static func _pharaoh(k: ModelKit, root: Node3D) -> void:
	# 下半身はミイラの布（浮かんでいる）
	k.cone(root, &"wrap", Vector3(0, 0.8, 0), 0.5, 1.2, Vector3(180, 0, 0), 14)
	for i in 4:
		k.torus(root, &"wrap", Vector3(0, 0.45 + i * 0.25, 0), 0.25 + i * 0.05, 0.32 + i * 0.05, Vector3(0, 0, 8.0 * (1 if i % 2 == 0 else -1)))
	k.cyl(root, &"cloth", Vector3(0, 1.75, 0), 0.5, 0.55, 0.9)
	k.cyl(root, &"gold", Vector3(0, 2.15, 0), 0.62, 0.55, 0.18)
	# むねかざり
	for i in 3:
		k.torus(root, &"gold" if i % 2 == 0 else &"stripe", Vector3(0, 2.1 - i * 0.08, 0.1), 0.4 - i * 0.03, 0.48 - i * 0.03, Vector3(-60, 0, 0), Vector3(1, 1, 0.5))
	# 頭とネメス（しま模様のずきん）
	var head := Vector3(0, 2.6, 0.05)
	k.sphere(root, &"wrap", head, 0.34)
	for i in 5:
		var role := &"gold" if i % 2 == 0 else &"stripe"
		k.box(root, role, head + Vector3(0, 0.3 - i * 0.12, -0.12), Vector3(0.78 - i * 0.02, 0.11, 0.45))
	for side in [-1.0, 1.0]:
		k.box(root, &"stripe", head + Vector3(0.36 * side, -0.3, 0.1), Vector3(0.14, 0.5, 0.12))
		k.sphere(root, &"dark", head + Vector3(0.12 * side, 0.02, 0.28), 0.07, Vector3(1.3, 0.8, 0.5))
		k.sphere(root, &"eye_glow", head + Vector3(0.12 * side, 0.02, 0.31), 0.04)
	k.cone(root, &"gold", head + Vector3(0, 0.42, 0.25), 0.06, 0.18)
	k.bone(root, &"gold", head + Vector3(0, -0.3, 0.25), head + Vector3(0, -0.6, 0.28), 0.05, 0.03)
	# つえ
	k.limb(root, &"wrap", Vector3(-0.55, 2.0, 0), Vector3(-0.8, 1.6, 0.3), 0.1)
	var w := k.pivot(root, Vector3(0.55, 2.0, 0))
	k.limb(w, &"wrap", Vector3.ZERO, Vector3(0.25, -0.4, 0.3), 0.1)
	k.limb(w, &"gold", Vector3(0.25, -1.2, 0.35), Vector3(0.25, 0.6, 0.35), 0.05)
	k.torus(w, &"gold", Vector3(0.25, 0.8, 0.35), 0.12, 0.18, Vector3(90, 0, 0))
	k.sphere(w, &"eye_glow", Vector3(0.25, 0.8, 0.35), 0.08)
	k.parts["weapon"] = w
