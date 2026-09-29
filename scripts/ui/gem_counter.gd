class_name GemCounter
extends PanelContainer
## 持っているジェムの数（青い宝石のマーク＋数字）。

var _label: Label
var _value := -1


func _init() -> void:
	add_theme_stylebox_override("panel", UIStyle.box(Color(0.05, 0.04, 0.1, 0.85), Color(0.45, 0.75, 1.0), 2, 30, 14))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	add_child(row)
	var icon := GemIcon.new()
	icon.custom_minimum_size = Vector2(34, 34)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(icon)
	_label = UIStyle.label("0", 30)
	_label.custom_minimum_size = Vector2(80, 0)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(_label)


func set_value(value: int, animate: bool = false) -> void:
	if animate and _value >= 0 and value != _value:
		var t := create_tween()
		t.tween_method(func(v: float) -> void: _label.text = str(roundi(v)), float(_value), float(value), 0.5)
	else:
		_label.text = str(value)
	_value = value


## ジェムのマーク（ひし形の宝石）
class GemIcon extends Control:
	func _draw() -> void:
		var w := size.x
		var h := size.y
		var top := PackedVector2Array([Vector2(w * 0.2, h * 0.3), Vector2(w * 0.35, h * 0.1), Vector2(w * 0.65, h * 0.1), Vector2(w * 0.8, h * 0.3)])
		var body := PackedVector2Array([Vector2(w * 0.08, h * 0.32), Vector2(w * 0.92, h * 0.32), Vector2(w * 0.5, h * 0.95)])
		draw_colored_polygon(body, Color(0.2, 0.55, 1.0))
		draw_colored_polygon(PackedVector2Array([Vector2(w * 0.08, h * 0.32), Vector2(w * 0.35, h * 0.1), Vector2(w * 0.65, h * 0.1), Vector2(w * 0.92, h * 0.32)]), Color(0.55, 0.85, 1.0))
		draw_colored_polygon(PackedVector2Array([Vector2(w * 0.5, h * 0.32), Vector2(w * 0.92, h * 0.32), Vector2(w * 0.5, h * 0.95)]), Color(0.12, 0.38, 0.85))
		draw_polyline(top, Color(1, 1, 1, 0.7), 1.5)
		draw_circle(Vector2(w * 0.38, h * 0.22), w * 0.06, Color(1, 1, 1, 0.9))
