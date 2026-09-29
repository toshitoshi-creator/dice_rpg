class_name RoadMap
extends Control
## チャプター内の進み具合を表示する道のり（● ━ ● ━ ◯ ━ 👑）。
## progress（0 = STAGE 1、1 = STAGE 2 …）を Tween で動かすと、プレイヤーの印が道を進む。

@export var total: int = 4
@export var progress: float = 0.0:
	set(value):
		progress = value
		queue_redraw()

const DONE_COLOR := Color(1.0, 0.8, 0.3)
const TODO_COLOR := Color(0.45, 0.42, 0.5)
const BOSS_COLOR := Color(0.95, 0.25, 0.25)
const MARKER_COLOR := Color(0.35, 0.7, 1.0)


func _init() -> void:
	custom_minimum_size = Vector2(420, 70)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _node_pos(i: int) -> Vector2:
	var margin := 34.0
	var w := size.x - margin * 2.0
	var x := margin + (w * i / maxf(total - 1, 1))
	return Vector2(x, size.y * 0.62)


func _draw() -> void:
	if total <= 0:
		return
	var font := get_theme_default_font()
	# 読みやすいように半透明の下地
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.08, 0.05, 0.12, 0.6)
	bg.set_corner_radius_all(14)
	draw_style_box(bg, Rect2(Vector2(0, 4), Vector2(size.x, size.y + 18)))
	# 道
	for i in total - 1:
		var a := _node_pos(i)
		var b := _node_pos(i + 1)
		draw_line(a, b, Color(0, 0, 0, 0.6), 10.0)
		var done := clampf(progress - i, 0.0, 1.0)
		draw_line(a, b, TODO_COLOR, 6.0)
		if done > 0.0:
			draw_line(a, a.lerp(b, done), DONE_COLOR, 6.0)
	# ステージの丸
	for i in total:
		var p := _node_pos(i)
		var is_boss := i == total - 1
		var r := 15.0 if is_boss else 11.0
		var reached := progress >= i - 0.001
		draw_circle(p, r + 3.0, Color(0, 0, 0, 0.7))
		var c := (BOSS_COLOR if is_boss else DONE_COLOR) if reached else (BOSS_COLOR.darkened(0.45) if is_boss else TODO_COLOR)
		draw_circle(p, r, c)
		var label := "BOSS" if is_boss else str(i + 1)
		var fs := 16 if is_boss else 18
		var tw := font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, fs).x
		draw_string(font, p + Vector2(-tw * 0.5, r + 22.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1, 0.97, 0.9))
	# プレイヤーの印（道の上を進む）
	var idx := clampi(int(floor(progress)), 0, total - 1)
	var frac := progress - idx
	var pos := _node_pos(idx)
	if idx < total - 1:
		pos = pos.lerp(_node_pos(idx + 1), frac)
	var hop := absf(sin(progress * PI * 4.0)) * 6.0 if frac > 0.001 and frac < 0.999 else 0.0
	var m := pos + Vector2(0, -26.0 - hop)
	draw_colored_polygon(PackedVector2Array([m + Vector2(-10, -12), m + Vector2(10, -12), m + Vector2(0, 4)]), Color(0, 0, 0, 0.7))
	draw_colored_polygon(PackedVector2Array([m + Vector2(-8, -11), m + Vector2(8, -11), m + Vector2(0, 2)]), MARKER_COLOR)
