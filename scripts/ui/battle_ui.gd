class_name BattleUI
extends CanvasLayer
## バトル画面の 2D UI。ゲームロジックは持たず、表示とボタン入力の通知だけを行う。

signal roll_pressed
signal retry_pressed

var enemy_bar: HpBar
var player_bar: HpBar
var roll_button: Button

var _root: Control
var _message_label: Label
var _result_label: Label
var _sub_result_label: Label
var _overlay: ColorRect
var _overlay_panel: PanelContainer
var _overlay_title: Label
var _overlay_subtitle: Label
var _retry_button: Button
var _result_tween: Tween
var _button_tween: Tween


func _ready() -> void:
	layer = 10
	_root = Control.new()
	_root.name = "Root"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.theme = _make_theme()
	add_child(_root)
	_build_top()
	_build_bottom()
	_build_center()
	_build_overlay()


func _make_theme() -> Theme:
	# フォントは project.godot の gui/theme/custom_font（同梱の Noto Sans JP）を使う。
	# Web 版ではシステムフォントが使えないため、必ず同梱フォントで表示する。
	var theme := Theme.new()
	theme.default_font_size = 28
	theme.set_color("font_color", "Label", Color(1, 0.97, 0.9))
	return theme


func _build_top() -> void:
	var panel := _make_panel()
	panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	panel.offset_left = 16
	panel.offset_right = -16
	panel.offset_top = 16
	_root.add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	var tag := Label.new()
	tag.text = "ENEMY"
	tag.add_theme_font_size_override("font_size", 18)
	tag.add_theme_color_override("font_color", Color(1, 0.55, 0.55))
	box.add_child(tag)
	enemy_bar = HpBar.new("SLIME", Color(0.9, 0.3, 0.35))
	box.add_child(enemy_bar)


func _build_bottom() -> void:
	var panel := _make_panel()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_left = 16
	panel.offset_right = -16
	panel.offset_bottom = -16
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_root.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	var tag := Label.new()
	tag.text = "PLAYER"
	tag.add_theme_font_size_override("font_size", 18)
	tag.add_theme_color_override("font_color", Color(0.55, 0.75, 1))
	box.add_child(tag)
	player_bar = HpBar.new("PLAYER", Color(0.3, 0.85, 0.45))
	box.add_child(player_bar)

	roll_button = Button.new()
	roll_button.text = "サイコロを振る"
	roll_button.custom_minimum_size = Vector2(0, 112)
	roll_button.focus_mode = Control.FOCUS_NONE
	roll_button.add_theme_font_size_override("font_size", 44)
	roll_button.add_theme_color_override("font_color", Color(0.2, 0.08, 0.02))
	roll_button.add_theme_color_override("font_hover_color", Color(0.2, 0.08, 0.02))
	roll_button.add_theme_color_override("font_pressed_color", Color(0.2, 0.08, 0.02))
	roll_button.add_theme_color_override("font_disabled_color", Color(0.35, 0.32, 0.3))
	roll_button.add_theme_stylebox_override("normal", _button_style(Color(1.0, 0.78, 0.25)))
	roll_button.add_theme_stylebox_override("hover", _button_style(Color(1.0, 0.85, 0.4)))
	roll_button.add_theme_stylebox_override("pressed", _button_style(Color(0.9, 0.62, 0.15)))
	roll_button.add_theme_stylebox_override("disabled", _button_style(Color(0.5, 0.47, 0.44)))
	roll_button.pressed.connect(func() -> void: roll_pressed.emit())
	roll_button.resized.connect(func() -> void: roll_button.pivot_offset = roll_button.size * 0.5)
	box.add_child(roll_button)


func _build_center() -> void:
	_message_label = Label.new()
	_message_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_message_label.anchor_left = 0.0
	_message_label.anchor_right = 1.0
	_message_label.anchor_top = 0.2
	_message_label.anchor_bottom = 0.2
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.add_theme_font_size_override("font_size", 34)
	_message_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	_message_label.add_theme_constant_override("outline_size", 12)
	_message_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_message_label)

	_result_label = _make_big_label(220, Color(1, 0.95, 0.7))
	_result_label.anchor_top = 0.3
	_result_label.anchor_bottom = 0.5
	_root.add_child(_result_label)
	_sub_result_label = _make_big_label(72, Color(1, 0.35, 0.2))
	_sub_result_label.anchor_top = 0.47
	_sub_result_label.anchor_bottom = 0.57
	_root.add_child(_sub_result_label)


func _make_big_label(font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.anchor_left = 0.0
	l.anchor_right = 1.0
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0.15, 0.03, 0.05))
	l.add_theme_constant_override("outline_size", maxi(font_size / 8, 10))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.visible = false
	l.resized.connect(func() -> void: l.pivot_offset = l.size * 0.5)
	return l


func _build_overlay() -> void:
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.55)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay.visible = false
	_root.add_child(_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)
	_overlay_panel = _make_panel()
	_overlay_panel.custom_minimum_size = Vector2(560, 0)
	center.add_child(_overlay_panel)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 24)
	_overlay_panel.add_child(box)
	_overlay_title = Label.new()
	_overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay_title.add_theme_font_size_override("font_size", 96)
	_overlay_title.add_theme_color_override("font_outline_color", Color(0.1, 0.02, 0.05))
	_overlay_title.add_theme_constant_override("outline_size", 18)
	box.add_child(_overlay_title)
	_overlay_subtitle = Label.new()
	_overlay_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay_subtitle.add_theme_font_size_override("font_size", 36)
	box.add_child(_overlay_subtitle)
	_retry_button = Button.new()
	_retry_button.text = "もう一度戦う"
	_retry_button.custom_minimum_size = Vector2(0, 104)
	_retry_button.focus_mode = Control.FOCUS_NONE
	_retry_button.add_theme_font_size_override("font_size", 40)
	_retry_button.add_theme_color_override("font_color", Color(0.1, 0.05, 0.02))
	_retry_button.add_theme_color_override("font_hover_color", Color(0.1, 0.05, 0.02))
	_retry_button.add_theme_color_override("font_pressed_color", Color(0.1, 0.05, 0.02))
	_retry_button.add_theme_stylebox_override("normal", _button_style(Color(1.0, 0.78, 0.25)))
	_retry_button.add_theme_stylebox_override("hover", _button_style(Color(1.0, 0.85, 0.4)))
	_retry_button.add_theme_stylebox_override("pressed", _button_style(Color(0.9, 0.62, 0.15)))
	_retry_button.add_theme_stylebox_override("disabled", _button_style(Color(0.5, 0.47, 0.44)))
	_retry_button.pressed.connect(_on_retry_pressed)
	box.add_child(_retry_button)


func _make_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.07, 0.14, 0.82)
	style.border_color = Color(0.85, 0.7, 0.4, 0.9)
	style.set_border_width_all(3)
	style.set_corner_radius_all(16)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 14
	style.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", style)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel


func _button_style(color: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = color.darkened(0.45)
	s.set_border_width_all(4)
	s.border_width_bottom = 10
	s.set_corner_radius_all(20)
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 6
	return s


# ------------------------------------------------------------------
# 外部から呼ぶ表示 API
# ------------------------------------------------------------------
func bind_actors(player: BattleActor, enemy: BattleActor) -> void:
	player_bar.set_title(player.display_name)
	player_bar.set_values(player.hp, player.max_hp)
	enemy_bar.set_title(enemy.display_name)
	enemy_bar.set_values(enemy.hp, enemy.max_hp)
	player.hp_changed.connect(player_bar.animate_to)
	enemy.hp_changed.connect(enemy_bar.animate_to)


func set_roll_enabled(enabled: bool) -> void:
	roll_button.disabled = not enabled
	if _button_tween and _button_tween.is_valid():
		_button_tween.kill()
	roll_button.scale = Vector2.ONE
	if enabled:
		# 押せる時はボタンをゆっくり脈動させる
		_button_tween = create_tween().set_loops()
		_button_tween.tween_property(roll_button, "scale", Vector2(1.03, 1.03), 0.5).set_trans(Tween.TRANS_SINE)
		_button_tween.tween_property(roll_button, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_SINE)


func show_message(text: String) -> void:
	_message_label.text = text
	_message_label.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(_message_label, "modulate:a", 1.0, 0.15)


## 出目を大きく表示してから縮小・消去する。
func show_dice_result(value: int, is_critical: bool) -> void:
	if _result_tween and _result_tween.is_valid():
		_result_tween.kill()
	_result_label.text = "%d!" % value
	_result_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2) if is_critical else Color(1, 0.97, 0.85))
	_result_label.visible = true
	_result_label.modulate.a = 1.0
	_result_label.scale = Vector2.ONE * 2.6
	_result_label.pivot_offset = _result_label.size * 0.5
	_sub_result_label.visible = is_critical
	_sub_result_label.text = "CRITICAL!"
	_sub_result_label.modulate.a = 0.0
	_sub_result_label.pivot_offset = _sub_result_label.size * 0.5
	_sub_result_label.scale = Vector2.ONE * 0.3

	_result_tween = create_tween()
	_result_tween.tween_property(_result_label, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if is_critical:
		_result_tween.tween_property(_sub_result_label, "modulate:a", 1.0, 0.1)
		_result_tween.parallel().tween_property(_sub_result_label, "scale", Vector2.ONE * 1.15, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_result_tween.parallel().tween_property(_sub_result_label, "rotation", deg_to_rad(-6.0), 0.2)
	_result_tween.tween_interval(0.55)
	_result_tween.tween_property(_result_label, "scale", Vector2.ONE * 0.5, 0.3).set_ease(Tween.EASE_IN)
	_result_tween.parallel().tween_property(_result_label, "modulate:a", 0.0, 0.3)
	_result_tween.parallel().tween_property(_sub_result_label, "modulate:a", 0.0, 0.3)
	_result_tween.tween_callback(func() -> void:
		_result_label.visible = false
		_sub_result_label.visible = false
		_sub_result_label.rotation = 0.0)


func show_victory(enemy_name: String) -> void:
	_show_overlay("VICTORY!", "%s DEFEATED" % enemy_name, Color(1, 0.85, 0.25))


func show_defeat() -> void:
	_show_overlay("DEFEAT", "YOU WERE DEFEATED", Color(0.75, 0.2, 0.25))


func _show_overlay(title: String, subtitle: String, color: Color) -> void:
	_overlay_title.text = title
	_overlay_title.add_theme_color_override("font_color", color)
	_overlay_subtitle.text = subtitle
	_retry_button.disabled = false
	_overlay.visible = true
	_overlay.modulate.a = 0.0
	_overlay_panel.pivot_offset = _overlay_panel.size * 0.5
	_overlay_panel.scale = Vector2.ONE * 0.6
	var t := create_tween().set_parallel(true)
	t.tween_property(_overlay, "modulate:a", 1.0, 0.3)
	t.tween_property(_overlay_panel, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func hide_overlay() -> void:
	_overlay.visible = false


func is_overlay_visible() -> bool:
	return _overlay.visible


func reset_view() -> void:
	hide_overlay()
	if _result_tween and _result_tween.is_valid():
		_result_tween.kill()
	_result_label.visible = false
	_sub_result_label.visible = false
	_message_label.text = ""


func _on_retry_pressed() -> void:
	# 連打で二重にリトライしないよう即座に無効化
	if _retry_button.disabled:
		return
	_retry_button.disabled = true
	retry_pressed.emit()
