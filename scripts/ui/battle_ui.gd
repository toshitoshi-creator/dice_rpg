class_name BattleUI
extends CanvasLayer
## バトル画面の 2D UI。ゲームロジックは持たず、表示とボタン入力の通知だけを行う。

signal roll_pressed
signal special_pressed
## 「そうび」ボタン（バトル中・結果画面）
signal equip_pressed
## 「ホーム」ボタン
signal home_pressed
## 結果画面のボタン（&"next" = 次のステージ, &"retry" = 再挑戦, &"stages" = ステージ選択へ, &"home" = ホームへ）
signal overlay_action(action: StringName)

var enemy_bar: HpBar
var player_bar: HpBar
var roll_button: Button
var special_button: Button
var equip_button: Button
var home_button: Button
## 装備画面
var equipment: EquipmentScreen

var _root: Control
var _message_label: Label
var _result_label: Label
var _sub_result_label: Label
var _overlay: ColorRect
var _overlay_panel: PanelContainer
var _overlay_title: Label
var _overlay_subtitle: Label
var _overlay_detail: Label
var _overlay_buttons: VBoxContainer
var _stage_tag: Label
var _banner_title: Label
var _banner_subtitle: Label
var _result_tween: Tween
var _button_tween: Tween
var _banner_tween: Tween
var _road: RoadMap
var _sp_bar: ProgressBar
var _sp_fill: StyleBoxFlat
var _sp_label: Label
var _sp_tween: Tween
var _sp_ready := false
var _cutin: SpecialCutIn
var _road_tween: Tween


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
	_cutin = SpecialCutIn.new()
	_root.add_child(_cutin)
	equipment = EquipmentScreen.new()
	_root.add_child(equipment)


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
	_stage_tag = Label.new()
	_stage_tag.text = "STAGE 1"
	_stage_tag.add_theme_font_size_override("font_size", 20)
	_stage_tag.add_theme_color_override("font_color", Color(1, 0.55, 0.55))
	box.add_child(_stage_tag)
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
	var head := HBoxContainer.new()
	box.add_child(head)
	var tag := Label.new()
	tag.text = "PLAYER"
	tag.add_theme_font_size_override("font_size", 18)
	tag.add_theme_color_override("font_color", Color(0.55, 0.75, 1))
	tag.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(tag)
	home_button = Button.new()
	home_button.text = "ホーム"
	home_button.custom_minimum_size = Vector2(130, 56)
	home_button.focus_mode = Control.FOCUS_NONE
	home_button.add_theme_font_size_override("font_size", 24)
	for state_name in ["font_color", "font_hover_color", "font_pressed_color"]:
		home_button.add_theme_color_override(state_name, Color(1, 0.95, 0.85))
	home_button.add_theme_color_override("font_disabled_color", Color(0.6, 0.58, 0.62))
	home_button.add_theme_stylebox_override("normal", _small_button_style(Color(0.4, 0.36, 0.48)))
	home_button.add_theme_stylebox_override("hover", _small_button_style(Color(0.48, 0.44, 0.56)))
	home_button.add_theme_stylebox_override("pressed", _small_button_style(Color(0.32, 0.28, 0.4)))
	home_button.add_theme_stylebox_override("disabled", _small_button_style(Color(0.28, 0.27, 0.32)))
	home_button.pressed.connect(func() -> void: home_pressed.emit())
	head.add_child(home_button)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(10, 0)
	head.add_child(gap)
	equip_button = Button.new()
	equip_button.text = "そうび"
	equip_button.custom_minimum_size = Vector2(150, 56)
	equip_button.focus_mode = Control.FOCUS_NONE
	equip_button.add_theme_font_size_override("font_size", 26)
	for state_name in ["font_color", "font_hover_color", "font_pressed_color"]:
		equip_button.add_theme_color_override(state_name, Color(1, 0.95, 0.85))
	equip_button.add_theme_color_override("font_disabled_color", Color(0.6, 0.58, 0.62))
	equip_button.add_theme_stylebox_override("normal", _small_button_style(Color(0.3, 0.42, 0.75)))
	equip_button.add_theme_stylebox_override("hover", _small_button_style(Color(0.38, 0.5, 0.85)))
	equip_button.add_theme_stylebox_override("pressed", _small_button_style(Color(0.24, 0.34, 0.62)))
	equip_button.add_theme_stylebox_override("disabled", _small_button_style(Color(0.28, 0.27, 0.32)))
	equip_button.pressed.connect(func() -> void: equip_pressed.emit())
	head.add_child(equip_button)
	player_bar = HpBar.new("PLAYER", Color(0.3, 0.85, 0.45))
	box.add_child(player_bar)

	# スペシャルゲージ
	var sp_row := HBoxContainer.new()
	sp_row.add_theme_constant_override("separation", 10)
	box.add_child(sp_row)
	var sp_tag := Label.new()
	sp_tag.text = "SP"
	sp_tag.add_theme_font_size_override("font_size", 24)
	sp_tag.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
	sp_tag.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	sp_tag.add_theme_constant_override("outline_size", 6)
	sp_row.add_child(sp_tag)
	_sp_bar = ProgressBar.new()
	_sp_bar.show_percentage = false
	_sp_bar.max_value = 100
	_sp_bar.step = 0.01
	_sp_bar.custom_minimum_size = Vector2(0, 20)
	_sp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sp_bg := StyleBoxFlat.new()
	sp_bg.bg_color = Color(0.08, 0.06, 0.1, 0.9)
	sp_bg.border_color = Color(0.9, 0.75, 0.4)
	sp_bg.set_border_width_all(2)
	sp_bg.set_corner_radius_all(6)
	_sp_fill = StyleBoxFlat.new()
	_sp_fill.bg_color = Color(1.0, 0.72, 0.2)
	_sp_fill.set_corner_radius_all(5)
	_sp_fill.set_expand_margin_all(-2)
	_sp_bar.add_theme_stylebox_override("background", sp_bg)
	_sp_bar.add_theme_stylebox_override("fill", _sp_fill)
	sp_row.add_child(_sp_bar)
	_sp_label = Label.new()
	_sp_label.text = "0%"
	_sp_label.custom_minimum_size = Vector2(70, 0)
	_sp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_sp_label.add_theme_font_size_override("font_size", 22)
	sp_row.add_child(_sp_label)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	box.add_child(buttons)

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
	roll_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_child(roll_button)

	special_button = Button.new()
	special_button.text = "SP"
	special_button.custom_minimum_size = Vector2(190, 112)
	special_button.focus_mode = Control.FOCUS_NONE
	special_button.add_theme_font_size_override("font_size", 48)
	for state_name in ["font_color", "font_hover_color", "font_pressed_color"]:
		special_button.add_theme_color_override(state_name, Color(1, 1, 1))
	special_button.add_theme_color_override("font_outline_color", Color(0.45, 0.05, 0.05))
	special_button.add_theme_constant_override("outline_size", 10)
	special_button.add_theme_color_override("font_disabled_color", Color(0.7, 0.66, 0.6))
	special_button.add_theme_stylebox_override("normal", _button_style(Color(0.95, 0.3, 0.15)))
	special_button.add_theme_stylebox_override("hover", _button_style(Color(1.0, 0.4, 0.2)))
	special_button.add_theme_stylebox_override("pressed", _button_style(Color(0.8, 0.2, 0.1)))
	special_button.add_theme_stylebox_override("disabled", _button_style(Color(0.33, 0.3, 0.36)))
	special_button.disabled = true
	special_button.pressed.connect(func() -> void: special_pressed.emit())
	special_button.resized.connect(func() -> void: special_button.pivot_offset = special_button.size * 0.5)
	buttons.add_child(special_button)


func _build_center() -> void:
	_message_label = Label.new()
	_message_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_message_label.anchor_left = 0.0
	_message_label.anchor_right = 1.0
	_message_label.anchor_top = 0.215
	_message_label.anchor_bottom = 0.215
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

	# チャプター内の道のり
	_road = RoadMap.new()
	_road.anchor_left = 0.5
	_road.anchor_right = 0.5
	_road.anchor_top = 0.132
	_road.anchor_bottom = 0.132
	_road.offset_left = -220
	_road.offset_right = 220
	_road.offset_bottom = 72
	_road.visible = false
	_root.add_child(_road)

	# ステージ開始時のバナー
	_banner_title = _make_big_label(120, Color(1, 0.9, 0.55))
	_banner_title.anchor_top = 0.3
	_banner_title.anchor_bottom = 0.42
	_root.add_child(_banner_title)
	_banner_subtitle = _make_big_label(40, Color(1, 0.97, 0.9))
	_banner_subtitle.anchor_top = 0.42
	_banner_subtitle.anchor_bottom = 0.5
	_root.add_child(_banner_subtitle)


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
	_overlay_panel.custom_minimum_size = Vector2(540, 0)
	center.add_child(_overlay_panel)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 24)
	_overlay_panel.add_child(box)
	_overlay_title = Label.new()
	_overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay_title.add_theme_font_size_override("font_size", 76)
	_overlay_title.add_theme_color_override("font_outline_color", Color(0.1, 0.02, 0.05))
	_overlay_title.add_theme_constant_override("outline_size", 18)
	box.add_child(_overlay_title)
	_overlay_subtitle = Label.new()
	_overlay_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay_subtitle.add_theme_font_size_override("font_size", 36)
	box.add_child(_overlay_subtitle)
	_overlay_detail = Label.new()
	_overlay_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay_detail.add_theme_font_size_override("font_size", 28)
	_overlay_detail.add_theme_color_override("font_color", Color(0.6, 1.0, 0.65))
	box.add_child(_overlay_detail)
	_overlay_buttons = VBoxContainer.new()
	_overlay_buttons.add_theme_constant_override("separation", 16)
	box.add_child(_overlay_buttons)


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


func _small_button_style(color: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = color.darkened(0.45)
	s.set_border_width_all(3)
	s.border_width_bottom = 6
	s.set_corner_radius_all(12)
	return s


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


func set_equip_enabled(enabled: bool) -> void:
	equip_button.disabled = not enabled


func set_home_enabled(enabled: bool) -> void:
	home_button.disabled = not enabled


## 装備画面を開く。
func open_equipment(progress: GameProgress) -> void:
	equipment.open(progress)


func is_equipment_open() -> bool:
	return equipment.is_open()


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


## スペシャルゲージとボタンの表示を更新する。
## value: 0〜100、ready: 満タン、can_use: 今押せる（プレイヤーのターン中）。
func update_special(value: float, full: bool, can_use: bool) -> void:
	var t := create_tween()
	t.tween_property(_sp_bar, "value", value, 0.4).set_trans(Tween.TRANS_SINE)
	_sp_label.text = "%d%%" % floori(value)
	special_button.disabled = not (full and can_use)
	if full != _sp_ready:
		_sp_ready = full
		if _sp_tween and _sp_tween.is_valid():
			_sp_tween.kill()
		special_button.scale = Vector2.ONE
		special_button.modulate = Color.WHITE
		_sp_fill.bg_color = Color(1.0, 0.72, 0.2)
		if full:
			# 満タン: ボタンが金色に明滅して脈動する
			_sp_tween = create_tween().set_loops()
			_sp_tween.tween_property(special_button, "scale", Vector2(1.08, 1.08), 0.35).set_trans(Tween.TRANS_SINE)
			_sp_tween.parallel().tween_property(special_button, "modulate", Color(1.4, 1.25, 0.8), 0.35)
			_sp_tween.parallel().tween_property(_sp_fill, "bg_color", Color(1.0, 0.95, 0.6), 0.35)
			_sp_tween.tween_property(special_button, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_SINE)
			_sp_tween.parallel().tween_property(special_button, "modulate", Color.WHITE, 0.35)
			_sp_tween.parallel().tween_property(_sp_fill, "bg_color", Color(1.0, 0.6, 0.15), 0.35)


## スペシャル技のカットイン。終わるまで await できる。
func play_special_cutin(title: String, subtitle: String, portrait: Texture2D, color: Color) -> void:
	await _cutin.play(title, subtitle, portrait, color)


func is_cutin_playing() -> bool:
	return _cutin.is_playing()


func show_message(text: String) -> void:
	_message_label.text = text
	_message_label.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(_message_label, "modulate:a", 1.0, 0.15)


## 出目を大きく表示してから縮小・消去する。
## values: 全部のサイコロの出目（1 こなら [出目]）
func show_dice_result(values: Array, is_critical: bool) -> void:
	if _result_tween and _result_tween.is_valid():
		_result_tween.kill()
	if values.size() <= 1:
		_result_label.text = "%d!" % (values[0] if not values.is_empty() else 0)
		_result_label.add_theme_font_size_override("font_size", 220)
	else:
		_result_label.text = "×".join(values.map(func(v: int) -> String: return str(v)))
		# 「6×4×2」の文字数に合わせて、画面の幅に収まる大きさにする
		_result_label.add_theme_font_size_override("font_size", clampi(roundi(620.0 / (values.size() * 2 - 1)), 48, 160))
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


## ステージクリア画面。
## rewards: ごほうびの説明（1 行ずつ）。
func show_stage_clear(enemy_name: String, rewards: Array[String] = []) -> void:
	_show_overlay("STAGE CLEAR!", "%s をたおした！" % enemy_name, Color(1, 0.85, 0.25),
		_rewards_text(rewards).strip_edges(),
		[{"text": "つぎのステージへ", "action": &"next"}, {"text": "ステージをえらぶ", "action": &"stages", "secondary": true},
		{"text": "そうび", "action": &"equip", "secondary": true}])


func _rewards_text(rewards: Array[String]) -> String:
	var text := ""
	for r in rewards:
		text += "\n" + r
	return text


## 全ステージクリア画面。
func show_game_clear(enemy_name: String, rewards: Array[String] = []) -> void:
	_show_overlay("CHAPTER CLEAR!", "%s をたおした！" % enemy_name, Color(1, 0.85, 0.25),
		"チャプター制覇！おめでとう！" + _rewards_text(rewards),
		[{"text": "ホームへ", "action": &"home"}, {"text": "ステージをえらぶ", "action": &"stages", "secondary": true}])


## 敗北画面。
func show_defeat() -> void:
	var buttons: Array = [{"text": "もう一度 たたかう", "action": &"retry"}]
	buttons.append({"text": "そうび", "action": &"equip", "secondary": true})
	buttons.append({"text": "ステージをえらぶ", "action": &"stages", "secondary": true})
	_show_overlay("DEFEAT", "レベルを上げたり そうびを 見直そう", Color(0.75, 0.2, 0.25), "", buttons)


func _show_overlay(title: String, subtitle: String, color: Color, detail: String, buttons: Array) -> void:
	_overlay_title.text = title
	_overlay_title.add_theme_color_override("font_color", color)
	_overlay_subtitle.text = subtitle
	_overlay_detail.text = detail
	_overlay_detail.visible = detail != ""
	for child in _overlay_buttons.get_children():
		_overlay_buttons.remove_child(child)
		child.queue_free()
	for def in buttons:
		_overlay_buttons.add_child(_make_overlay_button(def["text"], def["action"], def.get("secondary", false)))
	_overlay.visible = true
	_overlay.modulate.a = 0.0
	_overlay_panel.pivot_offset = _overlay_panel.size * 0.5
	_overlay_panel.scale = Vector2.ONE * 0.6
	var t := create_tween().set_parallel(true)
	t.tween_property(_overlay, "modulate:a", 1.0, 0.3)
	t.tween_property(_overlay_panel, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _make_overlay_button(text: String, action: StringName, secondary: bool) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 88 if secondary else 104)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 32 if secondary else 40)
	var base := Color(0.62, 0.58, 0.7) if secondary else Color(1.0, 0.78, 0.25)
	for state_name in ["font_color", "font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(state_name, Color(0.1, 0.05, 0.02))
	b.add_theme_stylebox_override("normal", _button_style(base))
	b.add_theme_stylebox_override("hover", _button_style(base.lightened(0.15)))
	b.add_theme_stylebox_override("pressed", _button_style(base.darkened(0.12)))
	b.add_theme_stylebox_override("disabled", _button_style(Color(0.5, 0.47, 0.44)))
	b.set_meta(&"action", action)
	b.pressed.connect(_on_overlay_button_pressed.bind(action))
	return b


## 結果画面のボタンを取得（テスト・キーボード操作用）。
func get_overlay_button(action: StringName) -> Button:
	for child in _overlay_buttons.get_children():
		if child is Button and child.get_meta(&"action") == action:
			return child
	return null


## 結果画面の一番上のボタンを押す（Enter / Space 用）。
func press_primary_overlay_button() -> void:
	if not _overlay.visible or _overlay_buttons.get_child_count() == 0:
		return
	var b := _overlay_buttons.get_child(0) as Button
	if b and not b.disabled:
		b.pressed.emit()


## 道のりを表示する（index = 今いるステージ）。
func show_road(index: int, total: int) -> void:
	if _road_tween and _road_tween.is_valid():
		_road_tween.kill()
	_road.total = total
	_road.progress = index
	if not _road.visible:
		_road.visible = true
		_road.modulate.a = 0.0
	_road_tween = create_tween()
	_road_tween.tween_property(_road, "modulate:a", 1.0, 0.2)


## 道のりの印を次のステージへ進める。
func advance_road(to_index: int, duration: float) -> void:
	if _road_tween and _road_tween.is_valid():
		_road_tween.kill()
	_road.visible = true
	_road.modulate.a = 1.0
	_road_tween = create_tween()
	_road_tween.tween_property(_road, "progress", float(to_index), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func hide_road() -> void:
	if not _road.visible:
		return
	if _road_tween and _road_tween.is_valid():
		_road_tween.kill()
	_road_tween = create_tween()
	_road_tween.tween_property(_road, "modulate:a", 0.0, 0.3)
	_road_tween.tween_callback(func() -> void: _road.visible = false)


func is_road_visible() -> bool:
	return _road.visible


func get_road_progress() -> float:
	return _road.progress


func set_stage_info(text: String, is_boss: bool) -> void:
	_stage_tag.text = text
	_stage_tag.add_theme_color_override("font_color", Color(1, 0.3, 0.3) if is_boss else Color(1, 0.55, 0.55))


## ステージ開始の演出。終わるまで await できる。
func play_stage_intro(title: String, subtitle: String, is_boss: bool) -> void:
	if _banner_tween and _banner_tween.is_valid():
		_banner_tween.kill()
	_banner_title.text = title
	_banner_title.add_theme_color_override("font_color", Color(1, 0.3, 0.25) if is_boss else Color(1, 0.9, 0.55))
	_banner_subtitle.text = subtitle
	for l in [_banner_title, _banner_subtitle]:
		l.visible = true
		l.modulate.a = 0.0
		l.pivot_offset = l.size * 0.5
		l.scale = Vector2.ONE * (1.8 if l == _banner_title else 1.0)
	_banner_tween = create_tween()
	_banner_tween.tween_property(_banner_title, "modulate:a", 1.0, 0.2)
	_banner_tween.parallel().tween_property(_banner_title, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_banner_tween.tween_property(_banner_subtitle, "modulate:a", 1.0, 0.25)
	_banner_tween.tween_interval(1.1 if is_boss else 0.8)
	_banner_tween.tween_property(_banner_title, "modulate:a", 0.0, 0.3)
	_banner_tween.parallel().tween_property(_banner_subtitle, "modulate:a", 0.0, 0.3)
	_banner_tween.tween_callback(func() -> void:
		_banner_title.visible = false
		_banner_subtitle.visible = false)
	await _banner_tween.finished


func hide_overlay() -> void:
	_overlay.visible = false


func is_overlay_visible() -> bool:
	return _overlay.visible


func reset_view() -> void:
	hide_overlay()
	if _banner_tween and _banner_tween.is_valid():
		_banner_tween.kill()
	_banner_title.visible = false
	_banner_subtitle.visible = false
	if _result_tween and _result_tween.is_valid():
		_result_tween.kill()
	_result_label.visible = false
	_sub_result_label.visible = false
	_message_label.text = ""


func _on_overlay_button_pressed(action: StringName) -> void:
	# 「そうび」は画面を開くだけなので、ほかのボタンは押せるまま
	if action == &"equip":
		equip_pressed.emit()
		return
	# 連打で二重に実行しないよう、押したら全ボタンを無効化
	for child in _overlay_buttons.get_children():
		if child is Button:
			if child.disabled:
				return
	for child in _overlay_buttons.get_children():
		if child is Button:
			child.disabled = true
	overlay_action.emit(action)
