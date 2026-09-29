class_name EnemyChapter11
extends RefCounted
## チャプター 11「おかしの国」
## 雑魚: カップケーキ / グミベア / キャンディスネーク　ボス: ケーキキング

const CHAPTER := 11
const AREA := "おかしの国"

const MOBS := [
	{
		"id": &"cupcake", "idle": &"bounce", "height": 1.4, "width": 2.2,
		"names": ["カップケーキ", "チョコカップケーキ", "ゴールドカップケーキ"],
		"names_en": ["CUPCAKE", "CHOCO CUPCAKE", "GOLD CUPCAKE"],
		"attack": "クリームアタック",
		"desc": "ふわふわのクリームをのせたおかしの魔物。あまい香りで近づいてくる。",
		"palettes": [
			{&"cup": Color(0.95, 0.5, 0.6), &"cake": Color(0.95, 0.78, 0.5), &"cream": {"color": Color(1.0, 0.95, 0.97), "rough": 0.3}, &"berry": {"color": Color(0.9, 0.1, 0.2), "clearcoat": 1.0}},
			{&"cup": Color(0.4, 0.7, 0.95), &"cake": Color(0.45, 0.28, 0.16), &"cream": {"color": Color(0.5, 0.3, 0.18), "rough": 0.3}, &"berry": {"color": Color(1.0, 0.95, 0.9), "clearcoat": 1.0}},
			{&"cup": {"color": Color(1.0, 0.8, 0.3), "metal": 0.8, "rough": 0.3}, &"cake": Color(0.98, 0.9, 0.7), &"cream": {"color": Color(1.0, 0.9, 0.6), "rough": 0.25}, &"berry": {"color": Color(0.3, 0.8, 1.0), "emission": 1.2}},
		],
	},
	{
		"id": &"gummy_bear", "idle": &"bounce", "height": 1.6, "width": 2.0,
		"names": ["グミベア", "グレープグミベア", "レインボーグミベア"],
		"names_en": ["GUMMY BEAR", "GRAPE GUMMY", "RAINBOW GUMMY"],
		"attack": "ぷにぷにパンチ",
		"desc": "すきとおったグミのクマ。たたくとぷるんとはねかえる。",
		"palettes": [
			{&"gummy": {"color": Color(1.0, 0.3, 0.25), "rough": 0.1, "clearcoat": 1.0, "rim": 0.6}, &"gummy2": {"color": Color(1.0, 0.55, 0.45), "rough": 0.1}},
			{&"gummy": {"color": Color(0.55, 0.2, 0.75), "rough": 0.1, "clearcoat": 1.0, "rim": 0.6}, &"gummy2": {"color": Color(0.75, 0.5, 0.9), "rough": 0.1}},
			{&"gummy": {"color": Color(0.3, 0.9, 0.6), "rough": 0.05, "clearcoat": 1.0, "emission": 0.4}, &"gummy2": {"color": Color(1.0, 0.9, 0.3), "emission": 0.6}},
		],
	},
	{
		"id": &"candy_snake", "idle": &"sway", "height": 1.5, "width": 2.4,
		"names": ["キャンディスネーク", "ミントスネーク", "ロイヤルスネーク"],
		"names_en": ["CANDY SNAKE", "MINT SNAKE", "ROYAL SNAKE"],
		"attack": "ぐるぐるまきつき",
		"desc": "しま模様のキャンディでできたヘビ。なめるとあまいがかむと痛い。",
		"palettes": [
			{&"candy": Color(0.98, 0.95, 0.95), &"stripe": Color(0.9, 0.12, 0.2), &"eye_glow": {"color": Color(0.2, 0.9, 0.3), "emission": 2.0}},
			{&"candy": Color(0.9, 1.0, 0.95), &"stripe": Color(0.2, 0.8, 0.6), &"eye_glow": {"color": Color(0.3, 0.6, 1.0), "emission": 2.0}},
			{&"candy": {"color": Color(1.0, 0.85, 0.4), "metal": 0.6, "rough": 0.3}, &"stripe": Color(0.45, 0.15, 0.6), &"eye_glow": {"color": Color(1.0, 0.2, 0.3), "emission": 3.0}},
		],
	},
]

const BOSS := {
	"id": &"cake_king", "idle": &"breathe", "height": 3.4, "width": 3.6,
	"names": ["ケーキキング", "チョコケーキキング", "ゴールデンケーキキング"],
	"names_en": ["CAKE KING", "CHOCO CAKE KING", "GOLDEN CAKE KING"],
	"attack": "スイーツプレス",
	"desc": "おかしの国を治める巨大なケーキ。ろうそくの火はいつまでも消えない。",
	"palettes": [
		{&"cake": Color(0.98, 0.9, 0.75), &"cream": Color(1.0, 0.97, 0.98), &"layer": Color(0.95, 0.45, 0.55), &"berry": {"color": Color(0.9, 0.1, 0.2), "clearcoat": 1.0}, &"candle": Color(0.5, 0.75, 1.0), &"flame": {"color": Color(1.0, 0.7, 0.2), "emission": 3.0, "unshaded": true}},
		{&"cake": Color(0.4, 0.25, 0.15), &"cream": Color(0.55, 0.35, 0.2), &"layer": Color(0.95, 0.9, 0.8), &"berry": {"color": Color(0.95, 0.95, 0.9)}, &"candle": Color(1.0, 0.6, 0.7), &"flame": {"color": Color(1.0, 0.5, 0.2), "emission": 3.0, "unshaded": true}},
		{&"cake": {"color": Color(1.0, 0.82, 0.35), "metal": 0.7, "rough": 0.3}, &"cream": Color(1.0, 0.95, 0.8), &"layer": Color(0.5, 0.2, 0.7), &"berry": {"color": Color(0.3, 0.8, 1.0), "emission": 1.5}, &"candle": Color(1.0, 1.0, 1.0), &"flame": {"color": Color(0.5, 0.8, 1.0), "emission": 3.5, "unshaded": true}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"cupcake":
			_cupcake(k, root)
		&"gummy_bear":
			_gummy(k, root)
		&"candy_snake":
			_snake(k, root)
		&"cake_king":
			_cake_king(k, root)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _cupcake(k: ModelKit, root: Node3D) -> void:
	# カップ（ひだ付き）
	k.cyl(root, &"cup", Vector3(0, 0.35, 0), 0.62, 0.45, 0.7, Vector3.ZERO, 20)
	for i in 12:
		var a := TAU * i / 12.0
		k.box(root, &"cup", Vector3(sin(a) * 0.55, 0.36, cos(a) * 0.55), Vector3(0.08, 0.68, 0.06), Vector3(0, rad_to_deg(a), 0))
	k.cyl(root, &"cake", Vector3(0, 0.78, 0), 0.66, 0.64, 0.2, Vector3.ZERO, 20)
	# クリームのうず
	k.sphere(root, &"cream", Vector3(0, 0.95, 0), 0.62, Vector3(1, 0.45, 1))
	k.sphere(root, &"cream", Vector3(0, 1.15, 0), 0.46, Vector3(1, 0.5, 1))
	k.sphere(root, &"cream", Vector3(0, 1.32, 0), 0.3, Vector3(1, 0.6, 1))
	k.sphere(root, &"berry", Vector3(0, 1.5, 0), 0.16)
	k.limb(root, &"dark", Vector3(0, 1.62, 0), Vector3(0.06, 1.78, -0.04), 0.02)
	# 顔（カップに）
	k.eyes(root, Vector3(0, 0.52, 0.6), 0.34, 0.1, &"angry")
	k.sphere(root, &"mouth", Vector3(0, 0.32, 0.58), 0.07, Vector3(1.6, 0.6, 0.5))
	for side in [-1.0, 1.0]:
		k.sphere(root, &"blush", Vector3(0.28 * side, 0.38, 0.58), 0.06, Vector3(1.2, 0.6, 0.4))
		k.limb(root, &"cream", Vector3(0.6 * side, 0.6, 0), Vector3(0.85 * side, 0.4, 0.2), 0.07)


static func _gummy(k: ModelKit, root: Node3D) -> void:
	k.sphere(root, &"gummy", Vector3(0, 0.6, 0), 0.5, Vector3(1, 1.1, 0.85))
	k.sphere(root, &"gummy2", Vector3(0, 0.55, 0.3), 0.3, Vector3(1, 1.1, 0.5))
	var head := Vector3(0, 1.25, 0.05)
	k.sphere(root, &"gummy", head, 0.4)
	k.sphere(root, &"gummy2", head + Vector3(0, -0.1, 0.32), 0.16, Vector3(1.2, 0.9, 0.7))
	k.sphere(root, &"dark", head + Vector3(0, -0.04, 0.44), 0.05)
	k.eyes(root, head + Vector3(0, 0.08, 0.34), 0.28, 0.07, &"dot")
	for side in [-1.0, 1.0]:
		k.sphere(root, &"gummy", head + Vector3(0.3 * side, 0.32, -0.02), 0.14, Vector3(1, 1, 0.6))
		k.sphere(root, &"gummy", Vector3(0.52 * side, 0.75, 0.05), 0.16, Vector3(1, 1.5, 1))
		k.sphere(root, &"gummy", Vector3(0.25 * side, 0.12, 0.08), 0.2, Vector3(1, 0.7, 1.2))
	var hl := k.sphere(root, &"shine", Vector3(-0.2, 1.45, 0.3), 0.08, Vector3(1, 0.6, 0.4))
	hl.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


static func _snake(k: ModelKit, root: Node3D) -> void:
	# とぐろ
	for i in 3:
		var y := 0.18 + i * 0.3
		var r := 0.7 - i * 0.16
		k.torus(root, &"candy" if i % 2 == 0 else &"stripe", Vector3(0, y, -0.1), r - 0.18, r, Vector3.ZERO, Vector3(1, 1.4, 1))
	# 首と頭（しま模様）
	var pts := [Vector3(0, 1.0, -0.1), Vector3(0, 1.3, 0.05), Vector3(0, 1.5, 0.25)]
	for i in pts.size() - 1:
		k.limb(root, &"stripe" if i % 2 == 0 else &"candy", pts[i], pts[i + 1], 0.16)
	var head := Vector3(0, 1.58, 0.42)
	k.sphere(root, &"candy", head, 0.26, Vector3(1.1, 0.8, 1.3))
	k.box(root, &"stripe", head + Vector3(0, 0.12, 0), Vector3(0.36, 0.05, 0.4))
	for side in [-1.0, 1.0]:
		k.sphere(root, &"eye_glow", head + Vector3(0.13 * side, 0.08, 0.22), 0.06)
		k.spike(root, &"tooth", head + Vector3(0.07 * side, -0.1, 0.3), head + Vector3(0.07 * side, -0.22, 0.32), 0.025)
	k.bone(root, &"tongue", head + Vector3(0, -0.06, 0.34), head + Vector3(0, -0.12, 0.6), 0.03, 0.01)


static func _cake_king(k: ModelKit, root: Node3D) -> void:
	# 3 段のケーキ
	var tiers := [[0.4, 1.2], [1.1, 0.95], [1.7, 0.7]]
	for t in tiers:
		var y: float = t[0]
		var r: float = t[1]
		k.cyl(root, &"cake", Vector3(0, y, 0), r, r, 0.6, Vector3.ZERO, 24)
		k.cyl(root, &"layer", Vector3(0, y, 0), r + 0.02, r + 0.02, 0.1, Vector3.ZERO, 24)
		k.torus(root, &"cream", Vector3(0, y + 0.3, 0), r - 0.1, r + 0.06, Vector3.ZERO, Vector3(1, 0.7, 1))
		for i in 8:
			var a := TAU * i / 8.0 + 0.2
			k.sphere(root, &"berry", Vector3(sin(a) * r * 0.9, y + 0.38, cos(a) * r * 0.9), 0.08)
	# ろうそく
	for x in [-0.35, 0.0, 0.35]:
		k.cyl(root, &"candle", Vector3(x, 2.25, 0), 0.06, 0.06, 0.5)
		k.sphere(root, &"flame", Vector3(x, 2.58, 0), 0.08, Vector3(1, 1.6, 1))
	# 顔（下の段）
	k.eyes(root, Vector3(0, 0.55, 1.12), 0.6, 0.16, &"angry")
	k.sphere(root, &"mouth", Vector3(0, 0.25, 1.15), 0.16, Vector3(2.2, 0.7, 0.4))
	for x in [-0.15, 0.15]:
		k.cone(root, &"tooth", Vector3(x, 0.22, 1.2), 0.05, 0.12, Vector3(180, 0, 0))
	# 手（クリームのうで）
	for side in [-1.0, 1.0]:
		k.limb(root, &"cream", Vector3(1.1 * side, 0.7, 0), Vector3(1.55 * side, 1.2, 0.35), 0.14)
		k.sphere(root, &"cream", Vector3(1.6 * side, 1.28, 0.4), 0.2)
