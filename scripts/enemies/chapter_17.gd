class_name EnemyChapter17
extends RefCounted
## チャプター 17「ひみつのジャングル」
## 雑魚: ゴリラ / カメレオン / ジャングルスネーク　ボス: ティラノ

const CHAPTER := 17
const AREA := "ひみつのジャングル"

const MOBS := [
	{
		"id": &"gorilla", "idle": &"breathe", "height": 2.0, "width": 2.4,
		"names": ["ゴリラ", "シルバーバック", "キングゴリラ"],
		"names_en": ["GORILLA", "SILVERBACK", "KING GORILLA"],
		"attack": "ドラミング",
		"desc": "ジャングルの力もち。むねをたたくと森じゅうにひびく。",
		"palettes": [
			{&"fur": Color(0.2, 0.18, 0.18), &"skin": Color(0.35, 0.3, 0.3), &"fur2": Color(0.3, 0.28, 0.28)},
			{&"fur": Color(0.25, 0.25, 0.28), &"skin": Color(0.4, 0.38, 0.4), &"fur2": Color(0.75, 0.75, 0.78)},
			{&"fur": Color(0.45, 0.2, 0.1), &"skin": Color(0.55, 0.4, 0.3), &"fur2": {"color": Color(1.0, 0.8, 0.3), "metal": 0.6, "rough": 0.4}},
		],
	},
	{
		"id": &"chameleon", "idle": &"sway", "height": 1.4, "width": 2.4,
		"names": ["カメレオン", "ステルスカメレオン", "レインボーカメレオン"],
		"names_en": ["CHAMELEON", "STEALTH LEON", "RAINBOW LEON"],
		"attack": "のびるベロ",
		"desc": "まわりの色にとけこむトカゲ。長いベロでいきなりおそってくる。",
		"palettes": [
			{&"scale": Color(0.35, 0.8, 0.3), &"scale2": Color(0.95, 0.85, 0.2), &"eye_ring": Color(0.9, 0.5, 0.2)},
			{&"scale": {"color": Color(0.5, 0.6, 0.55, 0.55)}, &"scale2": {"color": Color(0.7, 0.75, 0.7, 0.55)}, &"eye_ring": Color(0.3, 0.3, 0.35)},
			{&"scale": {"color": Color(0.9, 0.3, 0.7), "emission": 0.3}, &"scale2": {"color": Color(0.3, 0.9, 1.0), "emission": 0.4}, &"eye_ring": Color(1.0, 0.9, 0.3)},
		],
	},
	{
		"id": &"jungle_snake", "idle": &"sway", "height": 1.6, "width": 2.4,
		"names": ["ジャングルスネーク", "キングコブラ", "ゴールドコブラ"],
		"names_en": ["JUNGLE SNAKE", "KING COBRA", "GOLD COBRA"],
		"attack": "どくのキバ",
		"desc": "木の上から落ちてくる大ヘビ。えりを広げておどかしてくる。",
		"palettes": [
			{&"scale": Color(0.25, 0.55, 0.2), &"belly": Color(0.9, 0.85, 0.5), &"eye_glow": {"color": Color(1.0, 0.8, 0.2), "emission": 2.5}},
			{&"scale": Color(0.2, 0.18, 0.15), &"belly": Color(0.9, 0.6, 0.3), &"eye_glow": {"color": Color(1.0, 0.3, 0.2), "emission": 3.0}},
			{&"scale": {"color": Color(1.0, 0.8, 0.3), "metal": 0.8, "rough": 0.3}, &"belly": Color(0.2, 0.1, 0.3), &"eye_glow": {"color": Color(0.5, 0.2, 1.0), "emission": 3.0}},
		],
	},
]

const BOSS := {
	"id": &"t_rex", "idle": &"breathe", "height": 3.6, "width": 4.2,
	"names": ["ティラノ", "ブラックティラノ", "マグマティラノ"],
	"names_en": ["T-REX", "BLACK T-REX", "MAGMA T-REX"],
	"attack": "きょうりゅうのキバ",
	"desc": "ジャングルのおくで生きのこった恐竜の王。大きなあごで何でもかみくだく。",
	"palettes": [
		{&"scale": Color(0.35, 0.55, 0.25), &"belly": Color(0.85, 0.8, 0.55), &"spot": Color(0.25, 0.4, 0.18), &"eye_glow": {"color": Color(1.0, 0.8, 0.2), "emission": 2.5}},
		{&"scale": Color(0.15, 0.14, 0.16), &"belly": Color(0.4, 0.38, 0.4), &"spot": Color(0.6, 0.1, 0.15), &"eye_glow": {"color": Color(1.0, 0.2, 0.2), "emission": 3.0}},
		{&"scale": Color(0.3, 0.12, 0.08), &"belly": {"color": Color(1.0, 0.5, 0.1), "emission": 0.8}, &"spot": {"color": Color(1.0, 0.35, 0.05), "emission": 1.5}, &"eye_glow": {"color": Color(1.0, 0.9, 0.3), "emission": 3.5}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"gorilla":
			_gorilla(k, root)
		&"chameleon":
			_chameleon(k, root)
		&"jungle_snake":
			_cobra(k, root)
		&"t_rex":
			_t_rex(k, root)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _gorilla(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.limb(root, &"fur", Vector3(0.25 * side, 0.6, -0.1), Vector3(0.3 * side, 0.1, -0.05), 0.13)
		k.sphere(root, &"skin", Vector3(0.3 * side, 0.07, 0), 0.13, Vector3(1, 0.6, 1.4))
		# ながいうで
		k.limb(root, &"fur", Vector3(0.55 * side, 1.35, 0), Vector3(0.7 * side, 0.6, 0.25), 0.16)
		k.limb(root, &"fur", Vector3(0.7 * side, 0.6, 0.25), Vector3(0.72 * side, 0.15, 0.35), 0.14)
		k.sphere(root, &"skin", Vector3(0.72 * side, 0.1, 0.38), 0.15, Vector3(1.1, 0.7, 1.2))
	k.sphere(root, &"fur", Vector3(0, 0.75, -0.1), 0.45, Vector3(1.1, 1, 1))
	k.sphere(root, &"fur2", Vector3(0, 1.25, -0.15), 0.6, Vector3(1.2, 0.9, 1))
	k.sphere(root, &"skin", Vector3(0, 1.15, 0.3), 0.35, Vector3(1.1, 1, 0.5))
	var head := Vector3(0, 1.72, 0.2)
	k.sphere(root, &"fur", head, 0.3, Vector3(1, 1.05, 1))
	k.sphere(root, &"skin", head + Vector3(0, -0.08, 0.2), 0.2, Vector3(1.2, 0.9, 0.7))
	k.box(root, &"fur", head + Vector3(0, 0.1, 0.25), Vector3(0.4, 0.08, 0.1))
	k.eyes(root, head + Vector3(0, 0.02, 0.28), 0.18, 0.05, &"angry")
	for side in [-1.0, 1.0]:
		k.sphere(root, &"dark", head + Vector3(0.05 * side, -0.08, 0.37), 0.025)


static func _chameleon(k: ModelKit, root: Node3D) -> void:
	k.sphere(root, &"scale", Vector3(0, 0.7, -0.1), 0.4, Vector3(0.8, 1, 1.4))
	k.bone(root, &"scale2", Vector3(0, 1.0, -0.4), Vector3(0, 1.15, 0.3), 0.06, 0.02)
	var head := Vector3(0, 0.85, 0.5)
	k.sphere(root, &"scale", head, 0.28, Vector3(0.9, 1, 1.2))
	k.cone(root, &"scale2", head + Vector3(0, 0.25, -0.1), 0.15, 0.3, Vector3(-30, 0, 0))
	for side in [-1.0, 1.0]:
		k.sphere(root, &"eye_ring", head + Vector3(0.2 * side, 0.08, 0.05), 0.12)
		k.sphere(root, &"pupil", head + Vector3(0.28 * side, 0.1, 0.1), 0.04)
		for z in [0.25, -0.35]:
			k.limb(root, &"scale", Vector3(0.22 * side, 0.6, z), Vector3(0.35 * side, 0.3, z + 0.05), 0.06)
			k.limb(root, &"scale", Vector3(0.35 * side, 0.3, z + 0.05), Vector3(0.38 * side, 0.03, z + 0.12), 0.05)
	# ぐるぐるしっぽ
	var tail := k.pivot(root, Vector3(0, 0.6, -0.65))
	k.chain(tail, &"scale", ModelKit.curl_points(Vector3.ZERO, Vector3(0, -0.4, -1), Vector3(0, 1.5, 0.5), 0.9, 6), 0.12, 0.04)
	k.parts["tail"] = tail
	# ベロ
	k.sphere(root, &"mouth", head + Vector3(0, -0.12, 0.3), 0.06, Vector3(1.4, 0.5, 0.6))
	k.chain(root, &"tongue", [head + Vector3(0, -0.14, 0.34), head + Vector3(0, -0.2, 0.55), head + Vector3(0, -0.15, 0.75)], 0.03, 0.03)
	k.sphere(root, &"tongue", head + Vector3(0, -0.15, 0.78), 0.06)


static func _cobra(k: ModelKit, root: Node3D) -> void:
	for i in 3:
		var y := 0.15 + i * 0.25
		var r := 0.65 - i * 0.15
		k.torus(root, &"scale", Vector3(0, y, -0.1), r - 0.16, r, Vector3.ZERO, Vector3(1, 1.3, 1))
	k.chain(root, &"scale", [Vector3(0, 0.8, -0.1), Vector3(0, 1.15, 0.0), Vector3(0, 1.35, 0.15)], 0.15, 0.13)
	k.sphere(root, &"belly", Vector3(0, 1.1, 0.12), 0.12, Vector3(1, 2.2, 0.5))
	# えり（フード）
	k.sphere(root, &"scale", Vector3(0, 1.35, 0.1), 0.42, Vector3(1.3, 1.1, 0.25))
	k.sphere(root, &"belly", Vector3(0, 1.32, 0.17), 0.3, Vector3(1.1, 1.0, 0.1))
	var head := Vector3(0, 1.6, 0.25)
	k.sphere(root, &"scale", head, 0.22, Vector3(1.1, 0.8, 1.3))
	for side in [-1.0, 1.0]:
		k.sphere(root, &"eye_glow", head + Vector3(0.12 * side, 0.07, 0.18), 0.05)
		k.spike(root, &"tooth", head + Vector3(0.06 * side, -0.1, 0.24), head + Vector3(0.06 * side, -0.22, 0.26), 0.02)
	k.bone(root, &"tongue", head + Vector3(0, -0.05, 0.28), head + Vector3(0, -0.1, 0.52), 0.025, 0.008)


static func _t_rex(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.limb(root, &"scale", Vector3(0.4 * side, 1.3, -0.2), Vector3(0.45 * side, 0.7, 0.0), 0.28)
		k.limb(root, &"scale", Vector3(0.45 * side, 0.7, 0.0), Vector3(0.45 * side, 0.12, -0.1), 0.2)
		k.sphere(root, &"scale", Vector3(0.45 * side, 0.08, 0.1), 0.2, Vector3(1, 0.5, 1.8))
		for f in 3:
			k.spike(root, &"tooth", Vector3(0.45 * side + (f - 1) * 0.1, 0.06, 0.38), Vector3(0.45 * side + (f - 1) * 0.12, 0.02, 0.5), 0.03)
		# みじかいうで
		k.limb(root, &"scale", Vector3(0.35 * side, 1.9, 0.55), Vector3(0.4 * side, 1.65, 0.8), 0.07)
	k.capsule(root, &"scale", Vector3(0, 1.6, -0.1), 0.6, 1.9, Vector3(65, 0, 0))
	k.sphere(root, &"belly", Vector3(0, 1.6, 0.35), 0.45, Vector3(1, 1.3, 0.6))
	var tail := k.pivot(root, Vector3(0, 1.3, -0.8))
	k.chain(tail, &"scale", ModelKit.curl_points(Vector3.ZERO, Vector3(0, -0.4, -1), Vector3(0, 0.5, 0), 1.8, 5), 0.4, 0.08)
	k.parts["tail"] = tail
	for i in 5:
		k.stud(root, &"spot", Vector3(0, 1.6, -0.1), Vector3(0.6, 0.95, 0.7), 150 + i * 15.0, 20 - i * 8.0, Vector3(0.15, 0.12, 0.04))
	var head := Vector3(0, 2.5, 0.75)
	k.sphere(root, &"scale", head, 0.48, Vector3(1, 0.85, 1.4))
	k.box(root, &"scale", head + Vector3(0, -0.28, 0.25), Vector3(0.6, 0.18, 0.7))
	k.box(root, &"mouth", head + Vector3(0, -0.18, 0.3), Vector3(0.62, 0.06, 0.68))
	for i in 5:
		for side in [-1.0, 1.0]:
			k.spike(root, &"tooth", head + Vector3(0.25 * side, -0.15, 0.0 + i * 0.13), head + Vector3(0.25 * side, -0.28, 0.02 + i * 0.13), 0.035)
	for side in [-1.0, 1.0]:
		k.sphere(root, &"eye_glow", head + Vector3(0.28 * side, 0.12, 0.25), 0.07)
		k.box(root, &"scale", head + Vector3(0.28 * side, 0.22, 0.25), Vector3(0.14, 0.05, 0.14), Vector3(0, 0, -20.0 * side))
