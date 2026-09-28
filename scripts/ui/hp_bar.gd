class_name HpBar
extends VBoxContainer
## 名前・HP ゲージ・数値を表示する HP バー。
## 値が減るとき、実ゲージは素早く、後ろの白いゲージは遅れて減る。

var _name_label: Label
var _value_label: Label
var _bar: ProgressBar
var _trail: ProgressBar
var _fill_style: StyleBoxFlat
var _tween: Tween
var _shown_value: float = 0.0
var _max_value: int = 100
var _full_color: Color


func _init(title: String = "", fill_color: Color = Color(0.3, 0.85, 0.4)) -> void:
	_full_color = fill_color
	add_theme_constant_override("separation", 4)

	var header := HBoxContainer.new()
	add_child(header)
	_name_label = Label.new()
	_name_label.text = title
	_name_label.add_theme_font_size_override("font_size", 30)
	_name_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	_name_label.add_theme_constant_override("outline_size", 8)
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_name_label)
	_value_label = Label.new()
	_value_label.text = "100 / 100"
	_value_label.add_theme_font_size_override("font_size", 26)
	_value_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	_value_label.add_theme_constant_override("outline_size", 8)
	header.add_child(_value_label)

	var stack := Control.new()
	stack.custom_minimum_size = Vector2(0, 30)
	add_child(stack)

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.08, 0.06, 0.1, 0.9)
	bg.border_color = Color(0.9, 0.8, 0.55)
	bg.set_border_width_all(3)
	bg.set_corner_radius_all(8)
	var trail_fill := StyleBoxFlat.new()
	trail_fill.bg_color = Color(1.0, 0.92, 0.75)
	trail_fill.set_corner_radius_all(6)
	trail_fill.set_expand_margin_all(-3)
	_fill_style = StyleBoxFlat.new()
	_fill_style.bg_color = fill_color
	_fill_style.set_corner_radius_all(6)
	_fill_style.set_expand_margin_all(-3)
	var empty := StyleBoxEmpty.new()

	_trail = _make_bar(bg, trail_fill)
	stack.add_child(_trail)
	_bar = _make_bar(empty, _fill_style)
	stack.add_child(_bar)


func _make_bar(background: StyleBox, fill: StyleBox) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.min_value = 0
	bar.max_value = 100
	bar.step = 0.01
	bar.value = 100
	bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return bar


func set_title(title: String) -> void:
	_name_label.text = title


## アニメーション無しで即座に設定。
func set_values(current: int, maximum: int) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_max_value = maximum
	_bar.max_value = maximum
	_trail.max_value = maximum
	_bar.value = current
	_trail.value = current
	_set_shown(current)


## 滑らかに減らす / 増やす。
func animate_to(current: int, maximum: int) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_max_value = maximum
	_bar.max_value = maximum
	_trail.max_value = maximum
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_bar, "value", float(current), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_method(_set_shown, _shown_value, float(current), 0.5)
	if current < _trail.value:
		_tween.tween_property(_trail, "value", float(current), 0.6).set_delay(0.35).set_trans(Tween.TRANS_SINE)
	else:
		_trail.value = current


func _set_shown(v: float) -> void:
	_shown_value = v
	_value_label.text = "%d / %d" % [roundi(v), _max_value]
	var ratio := v / maxf(_max_value, 1)
	if ratio > 0.5:
		_fill_style.bg_color = _full_color
	elif ratio > 0.25:
		_fill_style.bg_color = Color(0.95, 0.75, 0.2)
	else:
		_fill_style.bg_color = Color(0.9, 0.2, 0.2)
