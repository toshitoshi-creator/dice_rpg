class_name SpecialCutIn
extends Control
## スペシャル技のカットイン演出（画面暗転・斜めの帯・集中線・キャラの顔・技名）。
## play() は演出が終わるまで await できる。

var _dim: ColorRect
var _band_back: Polygon2D
var _band_front: Polygon2D
## 斜めの窓に切り抜いたキャラの顔（金の枠つき）
var _portrait: Node2D
var _portrait_poly: Polygon2D
var _portrait_frame: Line2D
var _title: Label
var _subtitle: Label
var _flash: ColorRect
var _lines: Array[Line2D] = []
var _line_speed: Array[float] = []
var _running := false


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false


func _ready() -> void:
	_dim = ColorRect.new()
	_dim.color = Color(0.02, 0.0, 0.06, 0.7)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dim)
	# 集中線（右から左へ流れる光の線）
	for i in 26:
		var l := Line2D.new()
		l.width = randf_range(3.0, 9.0)
		l.default_color = Color(1.0, 0.95, 0.7, randf_range(0.35, 0.8))
		l.points = PackedVector2Array([Vector2.ZERO, Vector2(randf_range(120, 380), 0)])
		add_child(l)
		_lines.append(l)
		_line_speed.append(randf_range(1800.0, 3200.0))
	_band_back = Polygon2D.new()
	_band_back.color = Color(0.85, 0.15, 0.1)
	add_child(_band_back)
	_band_front = Polygon2D.new()
	_band_front.color = Color(1.0, 0.78, 0.2)
	add_child(_band_front)
	_portrait = Node2D.new()
	add_child(_portrait)
	_portrait_poly = Polygon2D.new()
	_portrait.add_child(_portrait_poly)
	_portrait_frame = Line2D.new()
	_portrait_frame.width = 8.0
	_portrait_frame.default_color = Color(1.0, 0.85, 0.35)
	_portrait_frame.closed = true
	_portrait.add_child(_portrait_frame)
	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 62)
	_title.add_theme_color_override("font_color", Color(1, 1, 1))
	_title.add_theme_color_override("font_outline_color", Color(0.55, 0.05, 0.02))
	_title.add_theme_constant_override("outline_size", 22)
	_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_title.add_theme_constant_override("shadow_offset_y", 6)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_title)
	_subtitle = Label.new()
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle.add_theme_font_size_override("font_size", 32)
	_subtitle.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
	_subtitle.add_theme_color_override("font_outline_color", Color(0.1, 0.02, 0.05))
	_subtitle.add_theme_constant_override("outline_size", 10)
	_subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_subtitle)
	_flash = ColorRect.new()
	_flash.color = Color(1, 1, 1, 0)
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash)


func _process(delta: float) -> void:
	if not _running:
		return
	var w := size.x
	for i in _lines.size():
		var l := _lines[i]
		l.position.x -= _line_speed[i] * delta
		if l.position.x < -400.0:
			l.position.x = w + randf_range(0, 300)
			l.position.y = randf_range(size.y * 0.3, size.y * 0.66)


func is_playing() -> bool:
	return _running


## カットインを再生する。portrait はキャラの顔（SubViewport のテクスチャなど）。
func play(title: String, subtitle: String, portrait: Texture2D, color: Color = Color(1.0, 0.78, 0.2)) -> void:
	var w := size.x
	var h := size.y
	var cy := h * 0.47
	var band_h := h * 0.2
	var slant := 60.0
	_band_front.color = color
	_band_back.polygon = PackedVector2Array([Vector2(0, cy - band_h * 0.62 - slant), Vector2(w, cy - band_h * 0.62 + slant),
		Vector2(w, cy + band_h * 0.62 + slant), Vector2(0, cy + band_h * 0.62 - slant)])
	_band_front.polygon = PackedVector2Array([Vector2(0, cy - band_h * 0.5 - slant), Vector2(w, cy - band_h * 0.5 + slant),
		Vector2(w, cy + band_h * 0.5 + slant), Vector2(0, cy + band_h * 0.5 - slant)])
	for i in _lines.size():
		_lines[i].position = Vector2(randf_range(0, w * 1.5), randf_range(cy - band_h, cy + band_h))
	# 平行四辺形の窓に顔を貼る
	var pw := w * 0.5
	var ph := h * 0.22
	var sl := 50.0
	var shape := PackedVector2Array([Vector2(sl, 0), Vector2(pw + sl, 0), Vector2(pw, ph), Vector2(0, ph)])
	_portrait_poly.polygon = shape
	_portrait_poly.texture = portrait
	var tex_size := Vector2(512, 512) if portrait == null else portrait.get_size()
	var crop_h := tex_size.x * ph / (pw + sl)
	var y0 := (tex_size.y - crop_h) * 0.45
	var uv := PackedVector2Array()
	for pt in shape:
		uv.append(Vector2(pt.x / (pw + sl) * tex_size.x, y0 + pt.y / ph * crop_h))
	_portrait_poly.uv = uv
	_portrait_frame.points = shape
	_portrait.position = Vector2(-pw - 80, cy - ph - band_h * 0.35)
	_title.text = title
	_title.size = Vector2(w, 100)
	_title.pivot_offset = _title.size * 0.5
	_title.position = Vector2(0, cy + band_h * 0.05)
	_subtitle.text = subtitle
	_subtitle.size = Vector2(w, 50)
	_subtitle.position = Vector2(0, cy + band_h * 0.62 + 40)

	visible = true
	_running = true
	modulate.a = 1.0
	_dim.modulate.a = 0.0
	_band_back.position = Vector2(-w * 1.2, 0)
	_band_front.position = Vector2(w * 1.2, 0)
	_title.modulate.a = 0.0
	_title.scale = Vector2.ONE * 3.0
	_subtitle.modulate.a = 0.0
	_flash.color.a = 0.0

	var t := create_tween()
	t.tween_property(_dim, "modulate:a", 1.0, 0.15)
	t.parallel().tween_property(_band_back, "position:x", 0.0, 0.22).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(_band_front, "position:x", 0.0, 0.26).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_delay(0.06)
	t.parallel().tween_property(_portrait, "position:x", w * 0.06, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.12)
	t.tween_property(_title, "modulate:a", 1.0, 0.08)
	t.parallel().tween_property(_title, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(_flash, "color:a", 0.7, 0.05)
	t.tween_property(_flash, "color:a", 0.0, 0.25)
	t.parallel().tween_property(_subtitle, "modulate:a", 1.0, 0.2)
	# ゆっくり流れて余韻
	t.tween_property(_portrait, "position:x", w * 0.1, 0.9)
	t.parallel().tween_property(_title, "scale", Vector2.ONE * 1.08, 0.9)
	# 抜ける
	t.tween_property(_band_front, "position:x", -w * 1.3, 0.22).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(_band_back, "position:x", w * 1.3, 0.22).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(_portrait, "position:x", -w * 0.8, 0.2).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(_title, "modulate:a", 0.0, 0.18)
	t.parallel().tween_property(_subtitle, "modulate:a", 0.0, 0.18)
	t.parallel().tween_property(_dim, "modulate:a", 0.0, 0.3)
	await t.finished
	_running = false
	visible = false
