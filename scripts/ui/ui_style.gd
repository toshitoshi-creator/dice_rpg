class_name UIStyle
extends RefCounted
## メニュー画面（ホーム・チャプター・ガチャ）で共通の見た目を作る道具。

const GOLD := Color(1.0, 0.8, 0.3)
const TEXT := Color(1, 0.97, 0.9)
const DARK_TEXT := Color(0.2, 0.08, 0.02)
const PANEL := Color(0.1, 0.07, 0.15, 0.92)
const BUTTON_GOLD := Color(1.0, 0.78, 0.25)
const BUTTON_BLUE := Color(0.3, 0.5, 0.9)
const BUTTON_PINK := Color(0.95, 0.4, 0.65)
const BUTTON_GRAY := Color(0.4, 0.36, 0.48)


static func box(bg: Color, border: Color, width: int = 3, radius: int = 16, margin: int = 18, bottom: int = -1) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(width)
	if bottom >= 0:
		s.border_width_bottom = bottom
	s.set_corner_radius_all(radius)
	s.content_margin_left = margin
	s.content_margin_right = margin
	s.content_margin_top = margin * 0.7
	s.content_margin_bottom = margin * 0.7
	return s


static func panel() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", box(PANEL, Color(0.85, 0.7, 0.4, 0.9), 3, 18, 20))
	return p


## 立体的なボタン。color が明るいときは文字を暗くする。
static func button(text: String, color: Color, height: int = 100, font_size: int = 38) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, height)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", font_size)
	style_button(b, color)
	return b


static func style_button(b: Button, color: Color) -> void:
	var fg := DARK_TEXT if color.get_luminance() > 0.55 else TEXT
	for state_name in ["font_color", "font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(state_name, fg)
	b.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.4) if fg == TEXT else Color(1, 1, 1, 0.0))
	b.add_theme_constant_override("outline_size", 6 if fg == TEXT else 0)
	b.add_theme_color_override("font_disabled_color", Color(0.62, 0.6, 0.64))
	b.add_theme_stylebox_override("normal", box(color, color.darkened(0.45), 4, 20, 16, 10))
	b.add_theme_stylebox_override("hover", box(color.lightened(0.12), color.darkened(0.45), 4, 20, 16, 10))
	b.add_theme_stylebox_override("pressed", box(color.darkened(0.12), color.darkened(0.5), 4, 20, 16, 6))
	b.add_theme_stylebox_override("disabled", box(Color(0.3, 0.28, 0.34), Color(0.2, 0.18, 0.22), 4, 20, 16, 10))


static func label(text: String, font_size: int, color: Color = TEXT, outline: int = 0) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	if outline > 0:
		l.add_theme_color_override("font_outline_color", Color(0.15, 0.04, 0.02))
		l.add_theme_constant_override("outline_size", outline)
	return l


## 画面上部のバー（もどるボタン・タイトル・ジェム）。もどるボタンを返す（back = false なら null）。
static func top_bar(parent: Control, title: String, gem_counter: GemCounter, back: bool = true) -> Button:
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 12)
	parent.add_child(bar)
	var back_button: Button = null
	if back:
		back_button = button("もどる", BUTTON_GRAY, 70, 28)
		back_button.custom_minimum_size.x = 150
		bar.add_child(back_button)
	var t := label(title, 40, GOLD, 12)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if back else HORIZONTAL_ALIGNMENT_LEFT
	t.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bar.add_child(t)
	bar.add_child(gem_counter)
	return back_button


## メニューの背景（縦のグラデーション）
static func background() -> TextureRect:
	var g := Gradient.new()
	g.set_color(0, Color(0.16, 0.22, 0.45))
	g.set_color(1, Color(0.08, 0.04, 0.14))
	g.add_point(0.55, Color(0.2, 0.12, 0.35))
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill_from = Vector2(0.5, 0)
	tex.fill_to = Vector2(0.5, 1)
	tex.width = 16
	tex.height = 256
	var r := TextureRect.new()
	r.texture = tex
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_SCALE
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


## 大きな数を 3 けたごとに「,」で区切る（例: 1234567 → "1,234,567"）
static func big_number(value: int) -> String:
	var digits := str(absi(value))
	var out := ""
	var count := 0
	for i in range(digits.length() - 1, -1, -1):
		out = digits[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "," + out
	return ("-" if value < 0 else "") + out
