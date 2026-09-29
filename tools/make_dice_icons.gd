extends SceneTree
## サイコロのアイコン（斜めから見た立方体と目）を DiceDatabase から作る。
## サイコロを追加・変更したら実行する:
##   godot --headless --path . -s res://tools/make_dice_icons.gd
## → assets/icons/dice/<id>.png（128×128、背景は透明）

const OUT_DIR := "res://assets/icons/dice/"
const SIZE := 128
const SCALE := 4

## 目の位置（面の中の 0〜1 の座標）
const PIPS := {
	1: [Vector2(0.5, 0.5)],
	2: [Vector2(0.27, 0.27), Vector2(0.73, 0.73)],
	3: [Vector2(0.25, 0.25), Vector2(0.5, 0.5), Vector2(0.75, 0.75)],
	4: [Vector2(0.27, 0.27), Vector2(0.73, 0.27), Vector2(0.27, 0.73), Vector2(0.73, 0.73)],
	5: [Vector2(0.25, 0.25), Vector2(0.75, 0.25), Vector2(0.5, 0.5), Vector2(0.25, 0.75), Vector2(0.75, 0.75)],
	6: [Vector2(0.27, 0.22), Vector2(0.73, 0.22), Vector2(0.27, 0.5), Vector2(0.73, 0.5), Vector2(0.27, 0.78), Vector2(0.73, 0.78)],
}


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	for id in DiceDatabase.DICE:
		var img := _draw(DiceDatabase.DICE[id])
		img.save_png(OUT_DIR + String(id) + ".png")
		print("dice icon: ", id)
	quit()


func _draw(d: Dictionary) -> Image:
	var n := SIZE * SCALE
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var body: Color = d["body"]
	var metal := float(d.get("metal", 0.0))
	var faces: Array = d["faces"]
	# 見える 3 面: 上 = 上の面, 右 = 右の面, 左 = 手前の面（(原点, 横方向, 縦方向, 明るさ, 数字)）
	var planes := [
		[Vector2(0.5, 0.06), Vector2(0.4, 0.21), Vector2(-0.4, 0.21), 0.25, faces[0]],
		[Vector2(0.1, 0.27), Vector2(0.4, 0.21), Vector2(0, 0.46), 0.0, faces[4]],
		[Vector2(0.5, 0.48), Vector2(0.4, -0.21), Vector2(0, 0.46), -0.25, faces[2]],
	]
	for y in n:
		for x in n:
			var p := Vector2(x + 0.5, y + 0.5) / n
			for plane in planes:
				var o: Vector2 = plane[0]
				var u: Vector2 = plane[1]
				var v: Vector2 = plane[2]
				var det := u.x * v.y - u.y * v.x
				var q := p - o
				var a := (q.x * v.y - q.y * v.x) / det
				var b := (u.x * q.y - u.y * q.x) / det
				if a < 0.0 or a > 1.0 or b < 0.0 or b > 1.0:
					continue
				var shade: float = plane[3]
				var c := body.lightened(shade) if shade > 0.0 else body.darkened(-shade)
				# 金属は面の中でグラデーション
				if metal > 0.0:
					c = c.lightened(metal * 0.35 * (1.0 - b)).darkened(metal * 0.2 * b)
				# ふち（角を丸く見せる暗い線）
				var edge := minf(minf(a, 1.0 - a), minf(b, 1.0 - b))
				if edge < 0.035:
					c = c.darkened(0.35)
				var value: int = plane[4]
				for pip in PIPS.get(value, []):
					if (Vector2(a, b) - pip).length() < (0.13 if value == 1 else 0.095):
						c = d["one"] if value == 1 else d["number"]
				img.set_pixel(x, y, c)
				break
	img.resize(SIZE, SIZE, Image.INTERPOLATE_LANCZOS)
	return img
