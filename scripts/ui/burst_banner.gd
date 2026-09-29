class_name BurstBanner
extends Control
## クリティカル・ゾロ目のときの派手な演出。
## 画面のフラッシュ、回る光の線、画面をかけぬける帯、ドンと出てくる大きな文字（虹色にもできる）。
## play() は終わるまで await できる。

var _flash: ColorRect
var _rays: Node2D
var _ray_polys: Array[Polygon2D] = []
var _band: Polygon2D
var _title: Label
var _subtitle: Label
var _sparks: Array[Polygon2D] = []
var _rainbow := false
var _time := 0.0
var _running := false


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func _ready() -> void:
	_flash = ColorRect.new()
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash)
	_rays = Node2D.new()
	add_child(_rays)
	for i in 16:
		var p := Polygon2D.new()
		var a := TAU * i / 16.0
		var w := 0.09
		p.polygon = PackedVector2Array([Vector2.ZERO, Vector2.from_angle(a - w) * 1400.0, Vector2.from_angle(a + w) * 1400.0])
		_rays.add_child(p)
		_ray_polys.append(p)
	_band = Polygon2D.new()
	add_child(_band)
	for i in 24:
		var sp := Polygon2D.new()
		sp.polygon = PackedVector2Array([Vector2(0, -14), Vector2(4, -4), Vector2(14, 0), Vector2(4, 4), Vector2(0, 14), Vector2(-4, 4), Vector2(-14, 0), Vector2(-4, -4)])
		add_child(sp)
		_sparks.append(sp)
	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 104)
	_title.add_theme_color_override("font_outline_color", Color(0.2, 0.02, 0.02))
	_title.add_theme_constant_override("outline_size", 26)
	_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_title.add_theme_constant_override("shadow_offset_y", 8)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_title)
	_subtitle = Label.new()
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle.add_theme_font_size_override("font_size", 64)
	_subtitle.add_theme_color_override("font_outline_color", Color(0.1, 0.02, 0.1))
	_subtitle.add_theme_constant_override("outline_size", 18)
	_subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_subtitle)


func is_playing() -> bool:
	return _running


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta
	_rays.rotation += delta * 1.6
	if _rainbow:
		for i in _ray_polys.size():
			_ray_polys[i].color = Color.from_hsv(fmod(_time * 0.5 + i / 16.0, 1.0), 0.7, 1.0, _ray_polys[i].color.a)
		_title.add_theme_color_override("font_color", Color.from_hsv(fmod(_time * 0.8, 1.0), 0.45, 1.0))


## 演出を再生する。strength: 1 = 普通、2 以上でさらに派手（長め・大きめ）
func play(title: String, subtitle: String, color: Color, rainbow: bool = false, strength: float = 1.0) -> void:
	var w := size.x
	var h := size.y
	var cy := h * 0.42
	_running = true
	_rainbow = rainbow
	_time = 0.0
	visible = true
	modulate.a = 1.0
	_rays.position = Vector2(w * 0.5, cy)
	_rays.scale = Vector2.ONE * 0.2
	_rays.modulate.a = 0.0
	for p in _ray_polys:
		p.color = Color(color.lightened(0.3), 0.35)
	var band_h := 150.0 + 30.0 * strength
	_band.polygon = PackedVector2Array([Vector2(0, cy - band_h * 0.5 - 40), Vector2(w, cy - band_h * 0.5 + 40),
		Vector2(w, cy + band_h * 0.5 + 40), Vector2(0, cy + band_h * 0.5 - 40)])
	_band.color = Color(color.darkened(0.3), 0.85)
	_band.position.x = -w
	_title.text = title
	_fit(_title, title, 104, w - 40)
	_title.add_theme_color_override("font_color", color.lightened(0.55))
	_title.size = Vector2(w, 140)
	_title.position = Vector2(0, cy - 90)
	_title.pivot_offset = _title.size * 0.5
	_title.scale = Vector2.ONE * 3.5
	_title.modulate.a = 0.0
	_title.rotation = deg_to_rad(-4)
	_subtitle.text = subtitle
	_fit(_subtitle, subtitle, 64, w - 40)
	_subtitle.add_theme_color_override("font_color", Color(1, 0.95, 0.55))
	_subtitle.size = Vector2(w, 80)
	_subtitle.position = Vector2(0, cy + 50)
	_subtitle.pivot_offset = _subtitle.size * 0.5
	_subtitle.modulate.a = 0.0
	_flash.color = Color(color.lightened(0.7), 0.0)
	for sp in _sparks:
		sp.position = Vector2(w * 0.5, cy)
		sp.color = Color.from_hsv(randf(), 0.6, 1.0) if rainbow else color.lightened(randf_range(0.2, 0.7))
		sp.scale = Vector2.ONE * randf_range(0.6, 1.4) * (1.0 + 0.3 * strength)
		sp.modulate.a = 1.0

	var hold := 0.55 + 0.25 * strength
	var t := create_tween().set_parallel(true)
	t.tween_property(_flash, "color:a", 0.75, 0.06)
	t.tween_property(_flash, "color:a", 0.0, 0.35).set_delay(0.06)
	t.tween_property(_rays, "modulate:a", 1.0, 0.15)
	t.tween_property(_rays, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(_band, "position:x", 0.0, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.tween_property(_title, "modulate:a", 1.0, 0.1).set_delay(0.08)
	t.tween_property(_title, "scale", Vector2.ONE, 0.28).set_delay(0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(_title, "rotation", 0.0, 0.28).set_delay(0.08)
	t.tween_property(_subtitle, "modulate:a", 1.0, 0.15).set_delay(0.3)
	for sp in _sparks:
		var dir := Vector2.from_angle(randf() * TAU) * randf_range(250.0, 520.0) * (1.0 + 0.25 * strength)
		t.tween_property(sp, "position", sp.position + dir, 0.7).set_delay(0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		t.tween_property(sp, "modulate:a", 0.0, 0.4).set_delay(0.45)
		t.tween_property(sp, "rotation", randf_range(-6, 6), 0.8)
	await t.finished
	# ドクン、と一回ふくらむ
	var pulse := create_tween()
	pulse.tween_property(_title, "scale", Vector2.ONE * 1.12, 0.12).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(_title, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_SINE)
	pulse.tween_interval(maxf(hold - 0.3, 0.05))
	pulse.tween_property(self, "modulate:a", 0.0, 0.25)
	await pulse.finished
	visible = false
	_running = false


## 画面の幅に収まるように文字の大きさを決める
func _fit(label: Label, text: String, max_size: int, max_width: float) -> void:
	var font := label.get_theme_font("font")
	var size := max_size
	while size > 24 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x + size * 0.5 > max_width:
		size -= 4
	label.add_theme_font_size_override("font_size", size)
