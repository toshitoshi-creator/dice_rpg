class_name EquipmentScreen
extends Control
## 装備画面。ぶき・たて・よろいを付けかえる。
## ゲームのデータは持たず、表示するときに GameProgress を受け取り、
## 付けかえたいときは equip_requested を出す（実際に付けかえるのは BattleManager）。

signal equip_requested(slot: StringName, id: StringName)
signal closed

const PORTRAIT := preload("res://assets/images/hero_cutin.jpg")
const GOLD := Color(1.0, 0.8, 0.3)

var _progress: GameProgress
var _slot: StringName = EquipmentDatabase.SLOT_WEAPON
## 詳しい説明を出している装備
var _focus_id: StringName = &""

var _panel: PanelContainer
var _stats: Label
var _special: Label
var _tabs: Array[Button] = []
var _list: VBoxContainer
var _detail_name: Label
var _detail_icon: TextureRect
var _detail_text: Label
var _close_button: Button


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false


func _ready() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.01, 0.06, 0.8)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.offset_left = 20
	_panel.offset_right = -20
	_panel.offset_top = 40
	_panel.offset_bottom = -40
	_panel.add_theme_stylebox_override("panel", _box(Color(0.1, 0.07, 0.15, 0.97), Color(0.85, 0.7, 0.4), 3, 18, 22))
	add_child(_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	_panel.add_child(box)

	var title := Label.new()
	title.text = "そうび"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", GOLD)
	title.add_theme_color_override("font_outline_color", Color(0.3, 0.08, 0.02))
	title.add_theme_constant_override("outline_size", 14)
	box.add_child(title)

	# 勇者の顔と、今の能力
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 18)
	box.add_child(head)
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", _box(Color(0.75, 0.12, 0.05), GOLD, 4, 14, 0))
	head.add_child(frame)
	var face := TextureRect.new()
	face.texture = PORTRAIT
	face.custom_minimum_size = Vector2(170, 170)
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	frame.add_child(face)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	head.add_child(info)
	_stats = Label.new()
	_stats.add_theme_font_size_override("font_size", 30)
	info.add_child(_stats)
	_special = Label.new()
	_special.add_theme_font_size_override("font_size", 24)
	_special.add_theme_color_override("font_color", GOLD)
	_special.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(_special)

	# 部位のタブ
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 10)
	box.add_child(tabs)
	for slot in EquipmentDatabase.SLOTS:
		var b := Button.new()
		b.text = EquipmentDatabase.SLOT_NAMES[slot]
		b.custom_minimum_size = Vector2(0, 76)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 32)
		b.set_meta(&"slot", slot)
		b.pressed.connect(show_slot.bind(slot))
		tabs.add_child(b)
		_tabs.append(b)

	# 装備の一覧
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 12)
	scroll.add_child(_list)

	# 説明
	var detail := PanelContainer.new()
	detail.custom_minimum_size = Vector2(0, 150)
	detail.add_theme_stylebox_override("panel", _box(Color(0.05, 0.04, 0.08, 0.9), Color(0.5, 0.42, 0.3), 2, 12, 16))
	box.add_child(detail)
	var drow := HBoxContainer.new()
	drow.add_theme_constant_override("separation", 14)
	detail.add_child(drow)
	_detail_icon = TextureRect.new()
	_detail_icon.custom_minimum_size = Vector2(110, 110)
	_detail_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_detail_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_detail_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	drow.add_child(_detail_icon)
	var dbox := VBoxContainer.new()
	dbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	drow.add_child(dbox)
	_detail_name = Label.new()
	_detail_name.add_theme_font_size_override("font_size", 28)
	_detail_name.add_theme_color_override("font_color", GOLD)
	dbox.add_child(_detail_name)
	_detail_text = Label.new()
	_detail_text.add_theme_font_size_override("font_size", 24)
	_detail_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dbox.add_child(_detail_text)

	_close_button = Button.new()
	_close_button.text = "とじる"
	_close_button.custom_minimum_size = Vector2(0, 96)
	_close_button.focus_mode = Control.FOCUS_NONE
	_close_button.add_theme_font_size_override("font_size", 40)
	for state_name in ["font_color", "font_hover_color", "font_pressed_color"]:
		_close_button.add_theme_color_override(state_name, Color(0.2, 0.08, 0.02))
	_close_button.add_theme_stylebox_override("normal", _box(Color(1.0, 0.78, 0.25), Color(0.55, 0.4, 0.1), 4, 20, 0, 10))
	_close_button.add_theme_stylebox_override("hover", _box(Color(1.0, 0.85, 0.4), Color(0.55, 0.4, 0.1), 4, 20, 0, 10))
	_close_button.add_theme_stylebox_override("pressed", _box(Color(0.9, 0.62, 0.15), Color(0.55, 0.4, 0.1), 4, 20, 0, 10))
	_close_button.pressed.connect(close)
	box.add_child(_close_button)


func _box(bg: Color, border: Color, width: int, radius: int, margin: int, bottom := -1) -> StyleBoxFlat:
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


func is_open() -> bool:
	return visible


func open(progress: GameProgress) -> void:
	_progress = progress
	visible = true
	refresh()
	modulate.a = 0.0
	_panel.pivot_offset = _panel.size * 0.5
	_panel.scale = Vector2.ONE * 0.9
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "modulate:a", 1.0, 0.18)
	t.tween_property(_panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


## 表示する部位を切り替える。
func show_slot(slot: StringName) -> void:
	_slot = slot
	_focus_id = &""
	refresh()


## 付けかえたあとなどに表示を作り直す。
func refresh() -> void:
	if _progress == null:
		return
	var weapon := _progress.weapon()
	_stats.text = "最大HP  %d\nこうげき  +%d\nぼうぎょ  +%d" % [_progress.total_max_hp(), _progress.attack_bonus(), _progress.defense_bonus()]
	_special.text = "SP技: %s" % weapon["special_name"]
	for b in _tabs:
		var active: bool = b.get_meta(&"slot") == _slot
		var base := Color(1.0, 0.78, 0.25) if active else Color(0.3, 0.26, 0.36)
		for state_name in ["font_color", "font_hover_color", "font_pressed_color"]:
			b.add_theme_color_override(state_name, Color(0.2, 0.08, 0.02) if active else Color(0.9, 0.86, 0.8))
		b.add_theme_stylebox_override("normal", _box(base, base.darkened(0.45), 3, 14, 0, 7))
		b.add_theme_stylebox_override("hover", _box(base.lightened(0.1), base.darkened(0.45), 3, 14, 0, 7))
		b.add_theme_stylebox_override("pressed", _box(base.darkened(0.1), base.darkened(0.45), 3, 14, 0, 7))
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	for id in EquipmentDatabase.items(_slot):
		_list.add_child(_make_card(id))
	if _focus_id == &"":
		_focus_id = _progress.equipped[_slot]
	_show_detail(_focus_id)


func _make_card(id: StringName) -> Button:
	var item := EquipmentDatabase.get_item(_slot, id)
	var owned := _progress.is_owned(_slot, id)
	var equipped: bool = _progress.equipped[_slot] == id
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, 104)
	b.focus_mode = Control.FOCUS_NONE
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.icon = EquipmentDatabase.get_icon(_slot, id)
	b.add_theme_constant_override("icon_max_width", 84)
	b.add_theme_constant_override("h_separation", 14)
	if not owned:
		# まだ持っていない装備は影（シルエット）だけ見せる
		for state_name in ["icon_normal_color", "icon_hover_color", "icon_pressed_color"]:
			b.add_theme_color_override(state_name, Color(0, 0, 0, 0.85))
	b.add_theme_font_size_override("font_size", 28)
	b.set_meta(&"item_id", id)
	var line2 := EquipmentDatabase.stat_text(_slot, id)
	if _slot == EquipmentDatabase.SLOT_WEAPON:
		line2 += "   SP: " + String(item["special_name"])
	if owned:
		b.text = "%s%s\n%s" % ["【E】" if equipped else "", item["name"], line2]
	else:
		b.text = "？？？\n%s" % EquipmentDatabase.unlock_text(_slot, id)
	var bg := Color(0.32, 0.22, 0.08) if equipped else (Color(0.16, 0.13, 0.22) if owned else Color(0.1, 0.1, 0.12))
	var border := GOLD if equipped else (Color(0.45, 0.4, 0.55) if owned else Color(0.25, 0.25, 0.28))
	var fg := Color(1, 0.95, 0.8) if owned else Color(0.5, 0.5, 0.55)
	for state_name in ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color"]:
		b.add_theme_color_override(state_name, fg)
	b.add_theme_stylebox_override("normal", _box(bg, border, 3, 14, 18))
	b.add_theme_stylebox_override("hover", _box(bg.lightened(0.08), border, 3, 14, 18))
	b.add_theme_stylebox_override("pressed", _box(bg.darkened(0.1), border, 3, 14, 18))
	b.add_theme_stylebox_override("disabled", _box(bg, border, 3, 14, 18))
	b.pressed.connect(_on_card_pressed.bind(id))
	return b


func _on_card_pressed(id: StringName) -> void:
	_focus_id = id
	if _progress.is_owned(_slot, id) and _progress.equipped[_slot] != id:
		equip_requested.emit(_slot, id)
	refresh()


func _show_detail(id: StringName) -> void:
	var item := EquipmentDatabase.get_item(_slot, id)
	_detail_icon.texture = EquipmentDatabase.get_icon(_slot, id)
	_detail_icon.self_modulate = Color.WHITE if _progress.is_owned(_slot, id) else Color(0, 0, 0, 0.85)
	if not _progress.is_owned(_slot, id):
		_detail_name.text = "？？？"
		_detail_text.text = EquipmentDatabase.unlock_text(_slot, id)
		return
	_detail_name.text = "%s（%s）" % [item["name"], EquipmentDatabase.stat_text(_slot, id)]
	var text := String(item.get("desc", ""))
	if _slot == EquipmentDatabase.SLOT_WEAPON:
		text += "\nSP技「%s」: %s" % [item["special_name"], item["special_desc"]]
	_detail_text.text = text


## テスト用: 一覧のボタンを取得する。
func get_card(id: StringName) -> Button:
	for child in _list.get_children():
		if child is Button and child.get_meta(&"item_id") == id:
			return child
	return null
