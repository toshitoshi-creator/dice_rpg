class_name HomeScreen
extends Control
## ホーム画面。勇者のイラスト・今の装備・ジェムと、ぼうけん / そうび / ガチャ へのボタン。

signal adventure_pressed
signal equipment_pressed
signal gacha_pressed

const PORTRAIT := preload("res://assets/images/hero_cutin.jpg")

var adventure_button: Button
var equipment_button: Button
var gacha_button: Button
var gems: GemCounter

var _equip_row: HBoxContainer
var _hero: Control


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 36)
	add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)

	gems = GemCounter.new()
	UIStyle.top_bar(box, "", gems, false)

	var logo := UIStyle.label("DICE BATTLE", 88, UIStyle.GOLD, 22)
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(logo)
	var sub := UIStyle.label("サイコロをふって まものをたおせ！", 28, UIStyle.TEXT, 8)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)

	# 勇者のイラスト（ゆっくり上下にゆれる）
	var hero_holder := CenterContainer.new()
	hero_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(hero_holder)
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", UIStyle.box(Color(0.75, 0.15, 0.08), UIStyle.GOLD, 6, 36, 8))
	hero_holder.add_child(frame)
	var face := TextureRect.new()
	face.texture = PORTRAIT
	face.custom_minimum_size = Vector2(420, 420)
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	frame.add_child(face)
	_hero = frame

	# 今の装備
	_equip_row = HBoxContainer.new()
	_equip_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_equip_row.add_theme_constant_override("separation", 14)
	box.add_child(_equip_row)

	adventure_button = UIStyle.button("ぼうけんに でる", UIStyle.BUTTON_GOLD, 130, 50)
	adventure_button.pressed.connect(func() -> void: adventure_pressed.emit())
	box.add_child(adventure_button)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	box.add_child(row)
	equipment_button = UIStyle.button("そうび", UIStyle.BUTTON_BLUE, 110, 40)
	equipment_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	equipment_button.pressed.connect(func() -> void: equipment_pressed.emit())
	row.add_child(equipment_button)
	gacha_button = UIStyle.button("ガチャ", UIStyle.BUTTON_PINK, 110, 40)
	gacha_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gacha_button.pressed.connect(func() -> void: gacha_pressed.emit())
	row.add_child(gacha_button)

	var t := create_tween().set_loops()
	t.tween_property(frame, "position:y", -10.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).as_relative()
	t.tween_property(frame, "position:y", 10.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).as_relative()


func refresh(progress: GameProgress) -> void:
	gems.set_value(progress.gems)
	for child in _equip_row.get_children():
		_equip_row.remove_child(child)
		child.queue_free()
	for slot in EquipmentDatabase.SLOTS:
		var id: StringName = progress.equipped[slot]
		var cell := PanelContainer.new()
		var rarity := EquipmentDatabase.rarity(slot, id)
		cell.add_theme_stylebox_override("panel", UIStyle.box(Color(0.08, 0.06, 0.12, 0.85), EquipmentDatabase.RARITY_COLORS[rarity], 3, 14, 6))
		var icon := TextureRect.new()
		icon.texture = EquipmentDatabase.get_icon(slot, id)
		icon.custom_minimum_size = Vector2(92, 92)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		cell.add_child(icon)
		_equip_row.add_child(cell)
