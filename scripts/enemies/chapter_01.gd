class_name EnemyChapter01
extends RefCounted
## チャプター 1「はじまりの草原」（チュートリアル）
## 雑魚: スライム / マッシュ / ハニービー　ボス: スライムキング

const CHAPTER := 1
const AREA := "はじまりの草原"

const MOBS := [
	{
		"id": &"slime", "idle": &"bounce", "height": 1.3, "width": 2.2,
		"names": ["スライム", "ベリースライム", "ゴールドスライム"],
		"names_en": ["SLIME", "BERRY SLIME", "GOLD SLIME"],
		"attack": "たいあたり",
		"desc": "草原のどこにでもいる、ぷるぷるの魔物。",
		"palettes": [
			{&"body": {"color": Color(0.3, 0.85, 0.45), "rough": 0.15, "rim": 0.6, "clearcoat": 0.8}, &"body2": Color(0.2, 0.55, 0.3)},
			{&"body": {"color": Color(0.85, 0.3, 0.6), "rough": 0.15, "rim": 0.6, "clearcoat": 0.8}, &"body2": Color(0.55, 0.18, 0.4)},
			{&"body": {"color": Color(1.0, 0.8, 0.3), "rough": 0.2, "metal": 0.8}, &"body2": {"color": Color(0.7, 0.5, 0.15), "metal": 0.7}},
		],
	},
	{
		"id": &"mushroom", "idle": &"bounce", "height": 1.5, "width": 2.0,
		"names": ["マッシュ", "ドクマッシュ", "ゴールドマッシュ"],
		"names_en": ["MUSH", "POISON MUSH", "GOLD MUSH"],
		"attack": "ほうしアタック",
		"desc": "木かげで昼寝をしているキノコ。ふまれると怒る。",
		"palettes": [
			{&"cap": Color(0.85, 0.35, 0.2), &"spot": Color(1.0, 0.95, 0.85), &"stem": Color(0.98, 0.9, 0.75), &"gill": Color(0.85, 0.72, 0.58)},
			{&"cap": Color(0.55, 0.2, 0.75), &"spot": Color(0.6, 1.0, 0.4), &"stem": Color(0.85, 0.85, 0.7), &"gill": Color(0.55, 0.5, 0.45)},
			{&"cap": {"color": Color(1.0, 0.78, 0.25), "metal": 0.6, "rough": 0.3}, &"spot": Color(1, 1, 1), &"stem": Color(1.0, 0.95, 0.85), &"gill": Color(0.9, 0.75, 0.45)},
		],
	},
	{
		"id": &"bee", "idle": &"hover", "height": 2.1, "width": 2.6,
		"names": ["ハニービー", "ホーネット", "ロイヤルビー"],
		"names_en": ["HONEY BEE", "HORNET", "ROYAL BEE"],
		"attack": "どくばり",
		"desc": "花畑を守るハチ。おしりの針に注意。",
		"palettes": [
			{&"body": Color(1.0, 0.8, 0.15), &"stripe": Color(0.15, 0.1, 0.08), &"wing": Color(0.85, 0.95, 1.0, 0.55)},
			{&"body": Color(0.95, 0.28, 0.08), &"stripe": Color(0.08, 0.05, 0.05), &"wing": Color(1.0, 0.85, 0.75, 0.55)},
			{&"body": Color(0.65, 0.35, 0.95), &"stripe": {"color": Color(1.0, 0.8, 0.3), "metal": 0.7, "rough": 0.3}, &"wing": Color(1.0, 0.85, 1.0, 0.6)},
		],
	},
]

const BOSS := {
	"id": &"king_slime", "idle": &"bounce", "height": 2.8, "width": 3.6,
	"names": ["スライムキング", "クリムゾンキング", "ダークキング"],
	"names_en": ["SLIME KING", "CRIMSON KING", "DARK KING"],
	"attack": "のしかかり",
	"desc": "スライムたちの王様。大きな体でのしかかってくる。",
	"palettes": [
		{&"body": {"color": Color(0.3, 0.6, 1.0), "rough": 0.15, "rim": 0.6, "clearcoat": 0.8}, &"body2": Color(0.2, 0.38, 0.7), &"crown": {"color": Color(1.0, 0.8, 0.25), "metal": 0.9, "rough": 0.25}, &"gem": {"color": Color(1.0, 0.2, 0.3), "emission": 0.8, "rough": 0.1}},
		{&"body": {"color": Color(0.9, 0.2, 0.25), "rough": 0.15, "rim": 0.6, "clearcoat": 0.8}, &"body2": Color(0.55, 0.1, 0.15), &"crown": {"color": Color(1.0, 0.8, 0.25), "metal": 0.9, "rough": 0.25}, &"gem": {"color": Color(0.2, 0.6, 1.0), "emission": 0.8, "rough": 0.1}},
		{&"body": {"color": Color(0.35, 0.2, 0.5), "rough": 0.15, "rim": 0.6, "clearcoat": 0.8}, &"body2": Color(0.18, 0.1, 0.28), &"crown": {"color": Color(0.8, 0.82, 0.88), "metal": 0.9, "rough": 0.2}, &"gem": {"color": Color(0.3, 1.0, 0.5), "emission": 1.0, "rough": 0.1}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"slime":
			_slime(k, root, false)
		&"mushroom":
			_mushroom(k, root)
		&"bee":
			_bee(k, root)
		&"king_slime":
			_slime(k, root, true)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _slime(k: ModelKit, root: Node3D, king: bool) -> void:
	k.cyl(root, &"body2", Vector3(0, 0.06, 0), 0.95, 1.0, 0.12, Vector3.ZERO, 24)
	k.sphere(root, &"body", Vector3(0, 0.62, 0), 0.9, Vector3(1, 0.75, 1))
	k.cone(root, &"body", Vector3(0, 1.3, -0.05), 0.28, 0.45, Vector3(-10, 0, 0))
	k.eyes(root, Vector3(0, 0.8, 0.72), 0.6, 0.17, &"angry" if king else &"cute")
	var mouth := k.sphere(root, &"mouth", Vector3(0, 0.5, 0.84), 0.12, Vector3(1.5, 0.6, 0.5))
	if king:
		mouth.scale = Vector3(2.2, 0.8, 0.5)
		for x in [-0.12, 0.12]:
			k.cone(root, &"tooth", Vector3(x, 0.47, 0.88), 0.04, 0.1, Vector3(180, 0, 0))
	else:
		for x in [-0.5, 0.5]:
			k.sphere(root, &"blush", Vector3(x, 0.62, 0.66), 0.1, Vector3(1.2, 0.6, 0.4))
	var hl := k.sphere(root, &"shine", Vector3(-0.42, 1.0, 0.5), 0.14, Vector3(1.0, 0.6, 0.4))
	hl.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if king:
		# 王冠
		var cy := 1.22
		k.cyl(root, &"crown", Vector3(0, cy, -0.05), 0.42, 0.45, 0.22, Vector3.ZERO, 20)
		for i in 5:
			var a := TAU * i / 5.0
			var p := Vector3(sin(a) * 0.4, cy + 0.22, cos(a) * 0.4 - 0.05)
			k.cone(root, &"crown", p, 0.1, 0.3, Vector3.ZERO, 6)
			k.sphere(root, &"gem", p + Vector3(0, 0.18, 0), 0.06, Vector3.ONE, Vector3.ZERO, 8)
		k.sphere(root, &"gem", Vector3(0, cy, 0.4), 0.09, Vector3(1, 1, 0.6))
		# マント
		k.box(root, &"body2", Vector3(0, 0.55, -0.85), Vector3(1.3, 0.9, 0.06), Vector3(-15, 0, 0))


static func _mushroom(k: ModelKit, root: Node3D) -> void:
	# 足と胴（軸）
	for x in [-0.2, 0.2]:
		k.sphere(root, &"stem", Vector3(x, 0.09, 0.08), 0.15, Vector3(1, 0.6, 1.3))
	k.cyl(root, &"stem", Vector3(0, 0.5, 0), 0.32, 0.42, 0.85)
	for side in [-1.0, 1.0]:
		k.limb(root, &"stem", Vector3(0.36 * side, 0.55, 0), Vector3(0.55 * side, 0.38, 0.12), 0.07)
	# 顔
	k.eyes(root, Vector3(0, 0.6, 0.36), 0.3, 0.09)
	k.sphere(root, &"mouth", Vector3(0, 0.44, 0.38), 0.05, Vector3(1.4, 0.8, 0.5))
	for x in [-0.22, 0.22]:
		k.sphere(root, &"blush", Vector3(x, 0.5, 0.33), 0.06, Vector3(1.2, 0.6, 0.4))
	# かさ
	k.cyl(root, &"gill", Vector3(0, 0.9, 0), 0.8, 0.35, 0.1, Vector3.ZERO, 24)
	var cap_center := Vector3(0, 0.92, 0)
	k.dome(root, &"cap", cap_center, 0.85, 0.72)
	var radii := Vector3(0.85, 0.72, 0.85)
	for s in [[0, 55, 0.2], [60, 30, 0.16], [-60, 30, 0.16], [130, 40, 0.18], [-130, 40, 0.18], [180, 20, 0.14], [25, 12, 0.12], [-25, 12, 0.12], [90, 65, 0.13]]:
		k.stud(root, &"spot", cap_center, radii, s[0], s[1], Vector3(s[2], 0.04, s[2]))


static func _bee(k: ModelKit, root: Node3D) -> void:
	var y := 1.0
	# 胸
	k.sphere(root, &"body", Vector3(0, y, 0), 0.3)
	# おなか（しま模様）
	var seg := [[Vector3(0, y - 0.05, -0.32), 0.32, &"stripe"], [Vector3(0, y - 0.1, -0.55), 0.35, &"body"], [Vector3(0, y - 0.16, -0.78), 0.31, &"stripe"], [Vector3(0, y - 0.22, -0.97), 0.23, &"body"]]
	for s in seg:
		k.sphere(root, s[2], s[0], s[1])
	k.spike(root, &"dark", Vector3(0, y - 0.26, -1.12), Vector3(0, y - 0.33, -1.4), 0.07)
	# 頭
	var head := Vector3(0, y + 0.15, 0.32)
	k.sphere(root, &"body", head, 0.27)
	k.eyes(root, head + Vector3(0, 0.04, 0.22), 0.25, 0.1)
	k.sphere(root, &"mouth", head + Vector3(0, -0.1, 0.24), 0.04, Vector3(1.5, 0.7, 0.5))
	for side in [-1.0, 1.0]:
		var a := head + Vector3(0.08 * side, 0.22, 0.05)
		var b := head + Vector3(0.22 * side, 0.5, 0.18)
		k.limb(root, &"stripe", a, b, 0.02)
		k.sphere(root, &"stripe", b, 0.05)
		# 脚
		for i in 3:
			var z := 0.12 - i * 0.14
			k.limb(root, &"stripe", Vector3(0.12 * side, y - 0.22, z), Vector3(0.24 * side, y - 0.5, z + 0.05), 0.03)
		# 羽
		var p := k.pivot(root, Vector3(0.12 * side, y + 0.25, -0.1))
		k.sphere(p, &"wing", Vector3(0.45 * side, 0.12, -0.05), 0.35, Vector3(1.3, 0.06, 0.65), Vector3(0, 0, 18.0 * side))
		k.sphere(p, &"wing", Vector3(0.35 * side, 0.05, -0.35), 0.24, Vector3(1.3, 0.06, 0.65), Vector3(0, 20.0 * side, 12.0 * side))
		k.add_wing(p, side)
	k.parts["wing_speed"] = 0.07
	k.parts["wing_angle"] = 30.0
