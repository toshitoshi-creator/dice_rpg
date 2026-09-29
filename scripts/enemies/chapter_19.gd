class_name EnemyChapter19
extends RefCounted
## チャプター 19「ゆめのせかい」
## 雑魚: ねむりヒツジ / テディベア / ピエロ　ボス: ナイトメア

const CHAPTER := 19
const AREA := "ゆめのせかい"

const MOBS := [
	{
		"id": &"dream_sheep", "idle": &"hover", "height": 1.4, "width": 2.2,
		"names": ["ねむりヒツジ", "ゆめみヒツジ", "あくむヒツジ"],
		"names_en": ["SLEEPY SHEEP", "DREAM SHEEP", "NIGHTMARE SHEEP"],
		"attack": "ねむりのうた",
		"desc": "かぞえると眠くなるヒツジ。1 ぴき、2 ひき…zzz",
		"palettes": [
			{&"wool": {"color": Color(0.98, 0.97, 0.95), "rough": 0.95}, &"face": Color(0.25, 0.22, 0.25), &"cap": Color(0.4, 0.55, 0.95)},
			{&"wool": {"color": Color(1.0, 0.8, 0.9), "rough": 0.95}, &"face": Color(0.9, 0.85, 0.8), &"cap": Color(0.6, 0.4, 0.9)},
			{&"wool": {"color": Color(0.25, 0.2, 0.35), "rough": 0.9}, &"face": Color(0.1, 0.08, 0.12), &"cap": {"color": Color(0.9, 0.2, 0.3), "emission": 0.5}},
		],
	},
	{
		"id": &"teddy", "idle": &"bounce", "height": 1.6, "width": 2.0,
		"names": ["テディベア", "ピンクテディ", "のろいのテディ"],
		"names_en": ["TEDDY", "PINK TEDDY", "CURSED TEDDY"],
		"attack": "ぬいぐるみパンチ",
		"desc": "夢の中でうごきだしたぬいぐるみ。ほつれたところからわたが出ている。",
		"palettes": [
			{&"plush": {"color": Color(0.75, 0.52, 0.3), "rough": 0.95}, &"plush2": {"color": Color(0.95, 0.85, 0.7), "rough": 0.95}, &"ribbon": Color(0.9, 0.15, 0.2)},
			{&"plush": {"color": Color(1.0, 0.65, 0.78), "rough": 0.95}, &"plush2": {"color": Color(1.0, 0.95, 0.95), "rough": 0.95}, &"ribbon": Color(0.4, 0.7, 1.0)},
			{&"plush": {"color": Color(0.35, 0.3, 0.38), "rough": 0.95}, &"plush2": {"color": Color(0.6, 0.55, 0.6), "rough": 0.95}, &"ribbon": {"color": Color(0.6, 0.1, 0.8), "emission": 0.5}},
		],
	},
	{
		"id": &"clown", "idle": &"bounce", "height": 1.9, "width": 2.2,
		"names": ["ピエロ", "ジェスター", "あくまのピエロ"],
		"names_en": ["CLOWN", "JESTER", "EVIL CLOWN"],
		"attack": "びっくりばこ",
		"desc": "夢のサーカスのピエロ。わらいながらボールを投げてくる。",
		"palettes": [
			{&"suit": Color(0.95, 0.3, 0.3), &"suit2": Color(1.0, 0.85, 0.2), &"skin": Color(1.0, 0.97, 0.95), &"nose": Color(0.95, 0.1, 0.1)},
			{&"suit": Color(0.3, 0.3, 0.9), &"suit2": Color(0.3, 0.85, 0.5), &"skin": Color(1.0, 0.97, 0.95), &"nose": Color(1.0, 0.8, 0.2)},
			{&"suit": Color(0.2, 0.1, 0.25), &"suit2": Color(0.7, 0.1, 0.2), &"skin": Color(0.85, 0.85, 0.9), &"nose": {"color": Color(1.0, 0.1, 0.2), "emission": 1.5}},
		],
	},
]

const BOSS := {
	"id": &"nightmare", "idle": &"flicker", "height": 3.6, "width": 4.0,
	"names": ["ナイトメア", "ブラックナイトメア", "ドリームイーター"],
	"names_en": ["NIGHTMARE", "BLACK NIGHTMARE", "DREAM EATER"],
	"attack": "あくむのいななき",
	"desc": "夢を食べるやみの馬。たてがみはゆらめく影でできている。",
	"palettes": [
		{&"body": Color(0.15, 0.12, 0.25), &"mane": {"color": Color(0.5, 0.2, 0.9, 0.7), "emission": 1.0}, &"hoof": Color(0.1, 0.08, 0.12), &"eye_glow": {"color": Color(1.0, 0.3, 0.5), "emission": 3.0}},
		{&"body": Color(0.05, 0.05, 0.07), &"mane": {"color": Color(0.9, 0.2, 0.2, 0.7), "emission": 1.2}, &"hoof": Color(0.5, 0.1, 0.1), &"eye_glow": {"color": Color(1.0, 0.9, 0.3), "emission": 3.0}},
		{&"body": Color(0.25, 0.25, 0.55), &"mane": {"color": Color(0.5, 1.0, 1.0, 0.7), "emission": 1.5}, &"hoof": {"color": Color(1.0, 0.85, 0.35), "metal": 0.9, "rough": 0.2}, &"eye_glow": {"color": Color(0.5, 1.0, 1.0), "emission": 3.5}},
	],
}


static func build(model: StringName, k: ModelKit, root: Node3D) -> bool:
	match model:
		&"dream_sheep":
			_sheep(k, root)
		&"teddy":
			_teddy(k, root)
		&"clown":
			_clown(k, root)
		&"nightmare":
			_nightmare(k, root)
		_:
			return false
	return true


# ------------------------------------------------------------------
static func _sheep(k: ModelKit, root: Node3D) -> void:
	var c := Vector3(0, 0.85, 0)
	for p in [[Vector3.ZERO, 0.5], [Vector3(-0.3, 0.1, -0.2), 0.35], [Vector3(0.3, 0.1, -0.2), 0.35], [Vector3(0, 0.3, -0.1), 0.35], [Vector3(-0.3, -0.1, 0.15), 0.3], [Vector3(0.3, -0.1, 0.15), 0.3]]:
		k.sphere(root, &"wool", c + p[0], p[1])
	for side in [-1.0, 1.0]:
		for z in [0.2, -0.25]:
			k.limb(root, &"face", Vector3(0.22 * side, 0.5, z), Vector3(0.22 * side, 0.25, z), 0.05)
	var head := c + Vector3(0, 0.05, 0.5)
	k.sphere(root, &"face", head, 0.25, Vector3(0.9, 1, 1))
	k.sphere(root, &"wool", head + Vector3(0, 0.22, -0.05), 0.18)
	# とじた目（ねむっている）
	for side in [-1.0, 1.0]:
		k.box(root, &"eye_white", head + Vector3(0.09 * side, 0.03, 0.21), Vector3(0.09, 0.02, 0.02), Vector3(0, 0, -15.0 * side))
		k.sphere(root, &"face", head + Vector3(0.24 * side, 0.05, 0), 0.1, Vector3(1.4, 0.5, 0.8))
	# ナイトキャップ
	k.cone(root, &"cap", head + Vector3(0.05, 0.4, -0.1), 0.2, 0.5, Vector3(-20, 0, -25))
	k.sphere(root, &"wool", head + Vector3(0.25, 0.62, -0.2), 0.07)


static func _teddy(k: ModelKit, root: Node3D) -> void:
	k.sphere(root, &"plush", Vector3(0, 0.6, 0), 0.45, Vector3(1, 1.1, 0.9))
	k.sphere(root, &"plush2", Vector3(0, 0.55, 0.28), 0.28, Vector3(1, 1.1, 0.5))
	# ほつれた縫い目
	for i in 4:
		k.box(root, &"dark", Vector3(-0.2, 0.45 + i * 0.08, 0.36), Vector3(0.08, 0.015, 0.02), Vector3(0, 0, 30))
	for side in [-1.0, 1.0]:
		k.sphere(root, &"plush", Vector3(0.28 * side, 0.15, 0.1), 0.18, Vector3(1, 0.8, 1.3))
		k.sphere(root, &"plush", Vector3(0.48 * side, 0.7, 0.1), 0.15, Vector3(1, 1.6, 1))
	var head := Vector3(0, 1.2, 0.05)
	k.sphere(root, &"plush", head, 0.38)
	k.sphere(root, &"plush2", head + Vector3(0, -0.1, 0.3), 0.15, Vector3(1.2, 0.9, 0.7))
	k.sphere(root, &"dark", head + Vector3(0, -0.05, 0.42), 0.045)
	# ボタンの目
	for side in [-1.0, 1.0]:
		k.cyl(root, &"dark", head + Vector3(0.13 * side, 0.08, 0.34), 0.06, 0.06, 0.03, Vector3(80, 0, 0), 12)
		k.sphere(root, &"plush", head + Vector3(0.28 * side, 0.28, -0.02), 0.13, Vector3(1, 1, 0.6))
		k.sphere(root, &"plush2", head + Vector3(0.28 * side, 0.28, 0.02), 0.07, Vector3(1, 1, 0.5))
	# リボン
	for side in [-1.0, 1.0]:
		k.sphere(root, &"ribbon", Vector3(0.12 * side, 0.9, 0.3), 0.1, Vector3(1.4, 0.8, 0.5))
	k.sphere(root, &"ribbon", Vector3(0, 0.9, 0.32), 0.05)


static func _clown(k: ModelKit, root: Node3D) -> void:
	for side in [-1.0, 1.0]:
		k.limb(root, &"suit" if side < 0 else &"suit2", Vector3(0.16 * side, 0.7, 0), Vector3(0.2 * side, 0.12, 0.05), 0.1)
		k.sphere(root, &"suit2" if side < 0 else &"suit", Vector3(0.22 * side, 0.08, 0.15), 0.12, Vector3(1, 0.6, 2))
		k.limb(root, &"suit2" if side < 0 else &"suit", Vector3(0.38 * side, 1.25, 0), Vector3(0.55 * side, 0.9, 0.2), 0.09)
		k.sphere(root, &"eye_white", Vector3(0.57 * side, 0.85, 0.24), 0.1)
	k.sphere(root, &"suit", Vector3(-0.12, 1.0, 0), 0.38, Vector3(0.7, 1, 0.9))
	k.sphere(root, &"suit2", Vector3(0.12, 1.0, 0), 0.38, Vector3(0.7, 1, 0.9))
	for i in 3:
		k.sphere(root, &"eye_white", Vector3(0, 0.85 + i * 0.15, 0.34), 0.05)
	# えり
	for i in 8:
		var a := TAU * i / 8.0
		k.sphere(root, &"eye_white", Vector3(sin(a) * 0.25, 1.38, cos(a) * 0.25), 0.1, Vector3(1, 0.4, 1))
	var head := Vector3(0, 1.62, 0.02)
	k.sphere(root, &"skin", head, 0.26)
	k.eyes(root, head + Vector3(0, 0.05, 0.22), 0.18, 0.06, &"angry")
	k.sphere(root, &"nose", head + Vector3(0, -0.03, 0.27), 0.07)
	k.sphere(root, &"mouth", head + Vector3(0, -0.13, 0.22), 0.07, Vector3(1.8, 0.6, 0.5))
	for side in [-1.0, 1.0]:
		k.sphere(root, &"suit2" if side < 0 else &"suit", head + Vector3(0.24 * side, 0.08, -0.02), 0.12, Vector3(1, 1.3, 1))
	# 帽子
	k.cone(root, &"suit", head + Vector3(-0.1, 0.35, 0), 0.12, 0.35, Vector3(0, 0, 30))
	k.cone(root, &"suit2", head + Vector3(0.1, 0.35, 0), 0.12, 0.35, Vector3(0, 0, -30))
	k.sphere(root, &"nose", head + Vector3(-0.26, 0.48, 0), 0.05)
	k.sphere(root, &"nose", head + Vector3(0.26, 0.48, 0), 0.05)


static func _nightmare(k: ModelKit, root: Node3D) -> void:
	k.capsule(root, &"body", Vector3(0, 1.5, -0.1), 0.5, 1.8, Vector3(90, 0, 0))
	for side in [-1.0, 1.0]:
		for z in [0.55, -0.7]:
			k.limb(root, &"body", Vector3(0.3 * side, 1.3, z), Vector3(0.32 * side, 0.65, z + 0.05), 0.14)
			k.limb(root, &"body", Vector3(0.32 * side, 0.65, z + 0.05), Vector3(0.32 * side, 0.15, z), 0.1)
			k.cyl(root, &"hoof", Vector3(0.32 * side, 0.08, z), 0.13, 0.15, 0.16)
	# 首と頭
	k.limb(root, &"body", Vector3(0, 1.8, 0.6), Vector3(0, 2.5, 0.95), 0.25)
	var head := Vector3(0, 2.6, 1.15)
	k.capsule(root, &"body", head, 0.2, 0.75, Vector3(60, 0, 0))
	for side in [-1.0, 1.0]:
		k.sphere(root, &"eye_glow", head + Vector3(0.17 * side, 0.12, -0.05), 0.07)
		k.spike(root, &"body", head + Vector3(0.1 * side, 0.3, -0.15), head + Vector3(0.14 * side, 0.55, -0.2), 0.06)
		k.spike(root, &"hoof", head + Vector3(0.12 * side, 0.3, -0.1), head + Vector3(0.35 * side, 0.7, -0.35), 0.05)
	k.sphere(root, &"dark", head + Vector3(0, -0.2, 0.3), 0.06)
	# 影のたてがみとしっぽ
	for i in 6:
		var p := Vector3(0, 2.1 + i * 0.12, 0.65 + i * 0.07)
		k.bone(root, &"mane", p, p + Vector3(0, 0.3, -0.45), 0.13, 0.02)
	var tail := k.pivot(root, Vector3(0, 1.7, -1.0))
	k.chain(tail, &"mane", ModelKit.curl_points(Vector3.ZERO, Vector3(0, -0.2, -1), Vector3(0, 1.2, 0), 1.1, 5), 0.2, 0.03)
	k.parts["tail"] = tail
