class_name EnemyChapter08
extends RefCounted
## チャプター 8「しずみの海」
## 雑魚: クラブ / ジェリー / マーマン　ボス: クラーケン

const CHAPTER := 8
const AREA := "しずみの海"

const MOBS := [
	{
		"id": &"crab", "idle": &"breathe", "height": 1.3, "width": 2.6,
		"names": ["クラブ", "ブルークラブ", "アイアンクラブ"],
		"names_en": ["CRAB", "BLUE CRAB", "IRON CRAB"],
		"attack": "はさみうち",
		"desc": "海辺をよこ歩きする大ガニ。大きなハサミで何でもはさむ。",
		"palettes": [
			{&"shell": {"color": Color(0.9, 0.3, 0.2), "rough": 0.4, "clearcoat": 0.6}, &"shell2": Color(1.0, 0.6, 0.45)},
			{&"shell": {"color": Color(0.2, 0.45, 0.85), "rough": 0.4, "clearcoat": 0.6}, &"shell2": Color(0.6, 0.85, 1.0)},
			{&"shell": {"color": Color(0.55, 0.57, 0.62), "metal": 0.85, "rough": 0.3}, &"shell2": {"color": Color(0.8, 0.55, 0.3), "metal": 0.8, "rough": 0.3}},
		],
	},
	{
		"id": &"jellyfish", "idle": &"hover", "height": 2.0, "width": 2.0,
		"names": ["ジェリー", "ポイズンジェリー", "エレキジェリー"],
		"names_en": ["JELLY", "POISON JELLY", "ELECTRO JELLY"],
		"attack": "しびれしょくしゅ",
		"desc": "ふわふわと海をただようクラゲ。しょくしゅでしびれさせる。",
		"palettes": [
			{&"jelly": {"color": Color(1.0, 0.6, 0.85), "rough": 0.1, "emission": 0.3, "rim": 0.8}, &"jelly2": Color(1.0, 0.8, 0.92), &"glow": {"color": Color(1.0, 0.85, 0.95), "emission": 2.0}},
			{&"jelly": {"color": Color(0.55, 0.3, 0.8), "rough": 0.1, "emission": 0.3, "rim": 0.8}, &"jelly2": Color(0.5, 0.9, 0.35), &"glow": {"color": Color(0.6, 1.0, 0.4), "emission": 2.0}},
			{&"jelly": {"color": Color(1.0, 0.9, 0.3), "rough": 0.1, "emission": 0.6, "rim": 0.8}, &"jelly2": {"color": Color(0.5, 0.9, 1.0), "emission": 1.5}, &"glow": {"color": Color(0.6, 1.0, 1.0), "emission": 3.0}},
		],
	},
	{
		"id": &"merman", "idle": &"sway", "height": 2.0, "width": 2.2,
		"names": ["マーマン", "ディープマーマン", "ゴールドマーマン"],
		"names_en": ["MERMAN", "DEEP MERMAN", "GOLD MERMAN"],
		"attack": "トライデント",
		"desc": "海の底の王国の兵士。三つまたのヤリをあやつる。",
		"palettes": [
			{&"scale": Color(0.25, 0.6, 0.6), &"belly": Color(0.8, 0.9, 0.8), &"fin": Color(0.95, 0.55, 0.3)},
			{&"scale": Color(0.12, 0.15, 0.35), &"belly": Color(0.3, 0.35, 0.55), &"fin": {"color": Color(0.3, 0.9, 1.0), "emission": 1.0}},
			{&"scale": {"color": Color(1.0, 0.78, 0.28), "metal": 0.8, "rough": 0.3}, &"belly": Color(1.0, 0.95, 0.8), &"fin": Color(0.9, 0.2, 0.3)},
		],
	},
]

const BOSS := {
	"id": &"kraken", "idle": &"breathe", "height": 3.4, "width": 4.4,
	"names": ["クラーケン", "ディープクラーケン", "ゴールドクラーケン"],
	"names_en": ["KRAKEN", "DEEP KRAKEN", "GOLD KRAKEN"],
	"attack": "しょくしゅのうず",
	"desc": "船をしずめる海の大怪物。8本のしょくしゅでまきつく。",
	"palettes": [
		{&"skin": {"color": Color(0.7, 0.25, 0.4), "rough": 0.35, "clearcoat": 0.5}, &"skin2": Color(1.0, 0.75, 0.75), &"water": Color(0.2, 0.45, 0.7, 0.5)},
		{&"skin": {"color": Color(0.1, 0.18, 0.4), "rough": 0.35, "clearcoat": 0.5}, &"skin2": {"color": Color(0.3, 0.95, 1.0), "emission": 1.5}, &"water": Color(0.1, 0.2, 0.45, 0.65)},
		{&"skin": {"color": Color(1.0, 0.7, 0.25), "metal": 0.6, "rough": 0.3}, &"skin2": Color(1.0, 0.95, 0.8), &"water": Color(0.2, 0.45, 0.7, 0.5)},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"crab":
			_crab(k, root)
		&"jellyfish":
			_jellyfish(k, root)
		&"merman":
			_merman(k, root)
		&"kraken":
			_kraken(k, root)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _crab(k: ModelKit, root: Node3D) -> void:
	var body := Vector3(0, 0.55, 0)
	k.sphere(root, &"shell", body, 0.6, Vector3(1.3, 0.55, 0.95))
	for s in [[30, 50], [-30, 50], [0, 70], [70, 30], [-70, 30]]:
		k.stud(root, &"shell2", body, Vector3(0.78, 0.33, 0.57), s[0], s[1], Vector3(0.08, 0.03, 0.08))
	k.box(root, &"dark", body + Vector3(0, -0.1, 0.52), Vector3(0.3, 0.05, 0.05))
	for side in [-1.0, 1.0]:
		var stalk_top := body + Vector3(0.2 * side, 0.52, 0.42)
		k.limb(root, &"shell", body + Vector3(0.18 * side, 0.2, 0.4), stalk_top, 0.04)
		k.sphere(root, &"eye_white", stalk_top, 0.1)
		k.sphere(root, &"pupil", stalk_top + Vector3(0, 0, 0.07), 0.05)
		var elbow := Vector3(0.95 * side, 0.62, 0.65)
		k.limb(root, &"shell", body + Vector3(0.65 * side, 0, 0.3), elbow, 0.1)
		var claw := Vector3(1.0 * side, 0.72, 0.95)
		k.limb(root, &"shell", elbow, claw, 0.1)
		k.sphere(root, &"shell", claw, 0.28, Vector3(0.9, 0.7, 1.15))
		k.spike(root, &"shell2", claw + Vector3(0.02 * side, 0.08, 0.18), claw + Vector3(-0.05 * side, 0.12, 0.62), 0.12)
		k.spike(root, &"shell2", claw + Vector3(0.02 * side, -0.08, 0.18), claw + Vector3(-0.05 * side, -0.05, 0.5), 0.09)
		for i in 3:
			var z := 0.05 - i * 0.25
			var knee := Vector3(1.0 * side, 0.65, z - 0.08)
			k.limb(root, &"shell", body + Vector3(0.6 * side, -0.05, z), knee, 0.055)
			k.limb(root, &"shell", knee, Vector3(1.2 * side, 0.02, z - 0.15), 0.045)


static func _jellyfish(k: ModelKit, root: Node3D) -> void:
	var base := Vector3(0, 1.25, 0)
	k.dome(root, &"jelly", base, 0.78, 0.78)
	k.sphere(root, &"glow", base + Vector3(0, 0.3, 0), 0.32, Vector3(1, 0.8, 1))
	k.torus(root, &"jelly2", base, 0.66, 0.82, Vector3.ZERO, Vector3(1, 0.35, 1))
	for i in 16:
		var a := TAU * i / 16.0
		k.sphere(root, &"jelly2", base + Vector3(sin(a) * 0.76, -0.03, cos(a) * 0.76), 0.08, Vector3(1, 0.7, 1), Vector3.ZERO, 10)
	for i in 8:
		var a := TAU * (i + 0.5) / 8.0
		var start := base + Vector3(sin(a) * 0.5, -0.05, cos(a) * 0.5)
		var pts := ModelKit.curl_points(start, Vector3(sin(a) * 0.2, -1, cos(a) * 0.2), Vector3(cos(a) * 0.9, 0, -sin(a) * 0.9), 1.1, 5)
		k.chain(root, &"jelly2", pts, 0.05, 0.02)
	for x in [-0.12, 0.12]:
		var pts := ModelKit.curl_points(base + Vector3(x, -0.05, 0.05), Vector3(0, -1, 0.1), Vector3(x * 4.0, 0, 0.3), 0.8, 4)
		k.chain(root, &"jelly", pts, 0.1, 0.05)
	k.eyes(root, base + Vector3(0, 0.25, 0.7), 0.32, 0.06, &"dot")
	k.sphere(root, &"mouth", base + Vector3(0, 0.12, 0.74), 0.05, Vector3(1.4, 0.6, 0.5))
	for x in [-0.3, 0.3]:
		k.sphere(root, &"blush", base + Vector3(x, 0.15, 0.68), 0.06, Vector3(1.2, 0.6, 0.4))


static func _merman(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.limb(root, &"scale", Vector3(0.15 * side, 0.85, 0), Vector3(0.17 * side, 0.1, 0.03), 0.1)
		k.sphere(root, &"fin", Vector3(0.17 * side, 0.04, 0.15), 0.15, Vector3(1, 0.3, 1.6))
	k.capsule(root, &"scale", Vector3(0, 1.25, 0), 0.32, 0.95)
	k.sphere(root, &"belly", Vector3(0, 1.2, 0.12), 0.26, Vector3(1, 1.5, 0.7))
	for i in 3:
		k.torus(root, &"scale", Vector3(0, 1.0 + i * 0.18, 0.2), 0.12, 0.2, Vector3(80, 0, 0), Vector3(1, 1, 0.3))
	var head := Vector3(0, 1.95, 0.1)
	k.sphere(root, &"scale", head, 0.32, Vector3(0.85, 1, 1.25))
	k.sphere(root, &"belly", head + Vector3(0, -0.12, 0.2), 0.2, Vector3(1, 0.6, 1))
	k.sphere(root, &"mouth", head + Vector3(0, -0.12, 0.38), 0.08, Vector3(1.4, 0.6, 0.6))
	for side in [-1.0, 1.0]:
		k.sphere(root, &"eye_white", head + Vector3(0.2 * side, 0.08, 0.22), 0.1)
		k.sphere(root, &"pupil", head + Vector3(0.23 * side, 0.08, 0.28), 0.05)
		k.sphere(root, &"fin", head + Vector3(0.28 * side, -0.08, -0.1), 0.15, Vector3(0.2, 1, 1.2), Vector3(0, 0, -20.0 * side))
		k.limb(root, &"scale", Vector3(0.38 * side, 1.55, 0), Vector3(0.45 * side, 1.15, 0.15), 0.08)
	k.sphere(root, &"fin", head + Vector3(0, 0.3, -0.15), 0.3, Vector3(0.08, 0.9, 1.3))
	k.sphere(root, &"fin", Vector3(0, 1.4, -0.3), 0.3, Vector3(0.08, 0.9, 0.9))
	var w := k.pivot(root, Vector3(0.45, 1.15, 0.15))
	k.limb(w, &"metal", Vector3(0, -0.8, 0), Vector3(0, 1.1, 0.1), 0.035)
	k.box(w, &"gold", Vector3(0, 1.1, 0.1), Vector3(0.36, 0.05, 0.05))
	for x in [-0.16, 0.0, 0.16]:
		k.spike(w, &"gold", Vector3(x, 1.1, 0.1), Vector3(x, 1.45 if x == 0.0 else 1.35, 0.12), 0.04)
	k.parts["weapon"] = w


static func _kraken(k: ModelKit, root: Node3D) -> void:
	k.cyl(root, &"water", Vector3(0, 0.04, 0), 1.9, 1.9, 0.06, Vector3.ZERO, 32)
	k.torus(root, &"water", Vector3(0, 0.08, 0), 1.3, 1.6, Vector3.ZERO, Vector3(1, 0.3, 1))
	k.sphere(root, &"skin", Vector3(0, 1.3, 0), 0.7, Vector3(1.1, 0.9, 1))
	var mantle := Vector3(0, 2.35, -0.25)
	k.sphere(root, &"skin", mantle, 0.8, Vector3(1, 1.4, 1))
	k.spike(root, &"skin", mantle + Vector3(0, 0.9, -0.2), mantle + Vector3(0, 1.3, -0.5), 0.35)
	for s in [[30, 20], [-40, 40], [160, 10], [100, -10], [-110, 30]]:
		k.stud(root, &"skin2", mantle, Vector3(0.8, 1.12, 0.8), s[0], s[1], Vector3(0.1, 0.02, 0.1))
	k.eyes(root, Vector3(0, 1.75, 0.66), 0.78, 0.2, &"angry", &"skin")
	for i in 8:
		var a := TAU * (i + 0.5) / 8.0
		var out := Vector3(sin(a), 0, cos(a))
		var start := Vector3(0, 1.1, 0) + out * 0.55
		var front := out.z > 0.3
		var bend := Vector3(0, 2.4, 0) + out * 0.8
		var pts := ModelKit.curl_points(start, out * 1.2 + Vector3(0, -0.8, 0), bend, 1.9 if front else 1.6, 6)
		k.chain(root, &"skin", pts, 0.22, 0.05)
		for j in range(1, 5):
			var p: Vector3 = pts[j]
			k.sphere(root, &"skin2", p + Vector3(0, -0.15 + j * 0.02, 0) + out * 0.05, 0.05, Vector3(1, 0.5, 1))
