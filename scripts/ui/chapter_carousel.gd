class_name ChapterCarousel
extends Control
## ホーム画面の真ん中の、左右にスワイプしてチャプターを選ぶカード。
## カードの背景にそのチャプターのボスを出す: クリア前は黒いシルエット、クリア後はちゃんと表示。

signal page_changed(chapter: int)
## カードをタップした（ドラッグしなかった）
signal chapter_tapped(chapter: int)

const BOSS_DIR := "res://assets/images/bosses/"
## カードどうしのすき間
const GAP := 18.0
## この距離以上ドラッグしたら次のカードへ
const SWIPE_DISTANCE := 70.0
const SILHOUETTE := Color(0.02, 0.01, 0.05, 1.0)
## 形だけを 1 色でぬりつぶすシェーダー（色をかけ算するだけだと目などがうっすら見えるため）
const SILHOUETTE_SHADER := """
shader_type canvas_item;
uniform vec4 fill : source_color = vec4(0.02, 0.01, 0.05, 1.0);
void fragment() {
	COLOR = vec4(fill.rgb, texture(TEXTURE, UV).a * fill.a);
}
"""

static var _silhouette_material: ShaderMaterial

## 今のページ（0 = CHAPTER 1）
var current := 0

var _progress: GameProgress
var _track: Control
var _pages: Array[Control] = []
var _dots: HBoxContainer
var _prev: Button
var _next: Button
var _dragging := false
var _drag_start := Vector2.ZERO
var _drag_offset := 0.0
var _moved := false
var _offset := 0.0
var _tween: Tween


func _init() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	_track = Control.new()
	_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_track)
	_dots = HBoxContainer.new()
	_dots.alignment = BoxContainer.ALIGNMENT_CENTER
	_dots.add_theme_constant_override("separation", 10)
	_dots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dots)
	_prev = _arrow("‹", -1)
	_next = _arrow("›", 1)
	resized.connect(_layout)


func _arrow(text: String, dir: int) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(64, 96)
	b.add_theme_font_size_override("font_size", 60)
	for state_name in ["font_color", "font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(state_name, Color(1, 0.95, 0.8))
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.15))
	var empty := StyleBoxFlat.new()
	empty.bg_color = Color(0, 0, 0, 0.25)
	empty.set_corner_radius_all(14)
	for s in ["normal", "hover", "pressed", "disabled"]:
		b.add_theme_stylebox_override(s, empty)
	b.pressed.connect(func() -> void: go_to(current + dir))
	add_child(b)
	return b


## チャプターのカードを作り直す。start_chapter を指定するとそのチャプターを表示する。
func refresh(progress: GameProgress, start_chapter: int = 0) -> void:
	_progress = progress
	for p in _pages:
		p.queue_free()
	_pages.clear()
	for child in _dots.get_children():
		child.queue_free()
	for c in range(1, EnemyDatabase.CHAPTER_COUNT + 1):
		var page := _make_page(c)
		_track.add_child(page)
		_pages.append(page)
		var dot := Panel.new()
		dot.custom_minimum_size = Vector2(14, 14)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_dots.add_child(dot)
	if start_chapter > 0:
		current = start_chapter - 1
	current = clampi(current, 0, _pages.size() - 1)
	_layout()
	_update_indicators()


## はじめに見せるチャプター: まだクリアしていない、遊べるチャプターのうち最初のもの。
static func suggested_chapter(progress: GameProgress) -> int:
	for c in range(1, EnemyDatabase.CHAPTER_COUNT + 1):
		if progress.is_chapter_unlocked(c) and not progress.is_chapter_cleared(c):
			return c
	var last := 1
	for c in range(1, EnemyDatabase.CHAPTER_COUNT + 1):
		if progress.is_chapter_unlocked(c):
			last = c
	return last


func selected_chapter() -> int:
	return current + 1


func page_count() -> int:
	return _pages.size()


## カードを移動する（アニメーションつき）。
func go_to(index: int, animate: bool = true) -> void:
	index = clampi(index, 0, maxi(_pages.size() - 1, 0))
	var changed := index != current
	current = index
	var target := -current * _page_step()
	if _tween and _tween.is_valid():
		_tween.kill()
	if animate:
		_tween = create_tween()
		_tween.tween_method(_set_offset, _offset, target, 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		_set_offset(target)
	_update_indicators()
	if changed:
		page_changed.emit(selected_chapter())


func _page_step() -> float:
	return _page_width() + GAP


func _page_width() -> float:
	return maxf(size.x - 170.0, 200.0)


func _layout() -> void:
	var w := _page_width()
	var h := maxf(size.y - 40.0, 100.0)
	for i in _pages.size():
		_pages[i].position = Vector2(85.0 + i * _page_step(), 0)
		_pages[i].size = Vector2(w, h)
		_pages[i].pivot_offset = Vector2(w, h) * 0.5
	_dots.position = Vector2(0, size.y - 26)
	_dots.size = Vector2(size.x, 20)
	_prev.position = Vector2(0, h * 0.5 - 48)
	_next.position = Vector2(size.x - 64, h * 0.5 - 48)
	_set_offset(-current * _page_step())


func _set_offset(value: float) -> void:
	_offset = value
	_track.position.x = value
	# まん中から離れたカードは少し小さく・暗く
	for i in _pages.size():
		var d := absf((i * _page_step() + value) / _page_step())
		var k := clampf(d, 0.0, 1.0)
		_pages[i].scale = Vector2.ONE * lerpf(1.0, 0.86, k)
		_pages[i].modulate = Color(1, 1, 1).lerp(Color(0.6, 0.6, 0.7), k)


func _update_indicators() -> void:
	for i in _dots.get_child_count():
		var s := StyleBoxFlat.new()
		s.set_corner_radius_all(7)
		s.bg_color = UIStyle.GOLD if i == current else Color(1, 1, 1, 0.3)
		(_dots.get_child(i) as Panel).add_theme_stylebox_override("panel", s)
	_prev.disabled = current <= 0
	_next.disabled = current >= _pages.size() - 1


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_moved = false
			_drag_start = event.position
			_drag_offset = _offset
			if _tween and _tween.is_valid():
				_tween.kill()
		elif _dragging:
			_dragging = false
			var dx: float = event.position.x - _drag_start.x
			if not _moved:
				go_to(current, true)
				chapter_tapped.emit(selected_chapter())
			elif dx <= -SWIPE_DISTANCE:
				go_to(current + 1)
			elif dx >= SWIPE_DISTANCE:
				go_to(current - 1)
			else:
				go_to(current)
		accept_event()
	elif event is InputEventMouseMotion and _dragging:
		var dx: float = event.position.x - _drag_start.x
		if absf(dx) > 12.0:
			_moved = true
		# 端ではひっぱりが重くなる
		var target := _drag_offset + dx
		var min_off := -(_pages.size() - 1) * _page_step()
		if target > 0.0:
			target *= 0.35
		elif target < min_off:
			target = min_off + (target - min_off) * 0.35
		_set_offset(target)
		accept_event()


func _make_page(c: int) -> Control:
	var unlocked := _progress.is_chapter_unlocked(c)
	var cleared := _progress.is_chapter_cleared(c)
	var has_stages := StageDatabase.is_playable(c)
	var color: Color = CHAPTER_COLORS[(c - 1) % CHAPTER_COLORS.size()]
	var page := PanelContainer.new()
	page.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg := color.darkened(0.45) if unlocked else color.darkened(0.7)
	page.add_theme_stylebox_override("panel", UIStyle.box(bg, UIStyle.GOLD if cleared else color.lightened(0.2), 5, 28, 0))
	page.set_meta(&"chapter", c)

	var inner := Control.new()
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.clip_contents = true
	page.add_child(inner)
	# 後ろの光
	var glow := TextureRect.new()
	glow.texture = _glow_texture(color.lightened(0.3) if cleared else color)
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(glow)
	# ボス（クリア前はシルエット）
	var boss := TextureRect.new()
	var path := BOSS_DIR + "chapter_%02d.png" % c
	if ResourceLoader.exists(path):
		boss.texture = load(path)
	boss.set_anchors_preset(Control.PRESET_FULL_RECT)
	boss.offset_top = 90
	boss.offset_bottom = -70
	boss.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	boss.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if not cleared:
		boss.material = _silhouette()
	boss.set_meta(&"silhouette", not cleared)
	boss.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss.name = "Boss"
	inner.add_child(boss)
	if not cleared:
		var q := UIStyle.label("？", 120, Color(1, 1, 1, 0.18))
		q.set_anchors_preset(Control.PRESET_FULL_RECT)
		q.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		q.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		q.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.add_child(q)

	var head := VBoxContainer.new()
	head.set_anchors_preset(Control.PRESET_TOP_WIDE)
	head.offset_top = 16
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(head)
	var num := UIStyle.label("CHAPTER %d" % c, 30, UIStyle.GOLD, 10)
	num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.add_child(num)
	var area := UIStyle.label(StageDatabase.chapter_name(c), 44, UIStyle.TEXT, 14)
	area.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.add_child(area)

	var status := ""
	var status_color := UIStyle.TEXT
	if cleared:
		status = "★ クリア！"
		status_color = UIStyle.GOLD
	elif unlocked:
		status = "ボスが まちうけている…"
	elif not has_stages:
		status = "じゅんびちゅう"
		status_color = Color(0.7, 0.7, 0.75)
	else:
		status = "CHAPTER %d をクリアで かいほう" % (c - 1)
		status_color = Color(0.7, 0.7, 0.75)
	var foot := UIStyle.label(status, 30, status_color, 10)
	foot.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	foot.offset_top = -64
	foot.offset_bottom = -18
	foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	foot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(foot)
	return page


static func _silhouette() -> ShaderMaterial:
	if _silhouette_material == null:
		var shader := Shader.new()
		shader.code = SILHOUETTE_SHADER
		_silhouette_material = ShaderMaterial.new()
		_silhouette_material.shader = shader
		_silhouette_material.set_shader_parameter("fill", SILHOUETTE)
	return _silhouette_material


## ページ c のボスがシルエットで表示されているか
func is_silhouette(c: int) -> bool:
	return bool(get_boss_rect(c).get_meta(&"silhouette", false))


func _glow_texture(color: Color) -> GradientTexture2D:
	var g := Gradient.new()
	g.set_color(0, Color(color, 0.7))
	g.set_color(1, Color(color, 0.0))
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.55)
	t.fill_to = Vector2(0.5, 1.05)
	t.width = 128
	t.height = 128
	return t


## テスト用: ページ c のボス画像
func get_boss_rect(c: int) -> TextureRect:
	return _pages[c - 1].find_child("Boss", true, false) as TextureRect


const CHAPTER_COLORS := [
	Color(0.35, 0.7, 0.35), Color(0.2, 0.5, 0.3), Color(0.85, 0.6, 0.25), Color(0.45, 0.35, 0.6), Color(0.3, 0.3, 0.45),
	Color(0.55, 0.8, 0.95), Color(0.9, 0.35, 0.2), Color(0.2, 0.45, 0.8), Color(0.5, 0.2, 0.35), Color(0.55, 0.15, 0.35),
]
