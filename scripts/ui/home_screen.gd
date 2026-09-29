class_name HomeScreen
extends Control
## ホーム画面。まん中でチャプターを左右にスワイプして選び、「ぼうけんに でる」で出発する。
## 下に今の装備、そうび / ガチャ へのボタン。

## 選んでいるチャプターで出発する
signal adventure_pressed(chapter: int)
signal equipment_pressed
signal gacha_pressed

const PORTRAIT := preload("res://assets/images/hero_cutin.jpg")

var adventure_button: Button
var equipment_button: Button
var gacha_button: Button
var gems: GemCounter
var carousel: ChapterCarousel

var _progress: GameProgress
var _equip_row: HBoxContainer
var _level_label: Label
var _exp_bar: ProgressBar


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 36)
	add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)

	# 上: 勇者の顔・タイトル・ジェム
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 14)
	box.add_child(top)
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", UIStyle.box(Color(0.75, 0.15, 0.08), UIStyle.GOLD, 4, 20, 4))
	top.add_child(frame)
	var face := TextureRect.new()
	face.texture = PORTRAIT
	face.custom_minimum_size = Vector2(96, 96)
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	frame.add_child(face)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	top.add_child(info)
	var logo := UIStyle.label("DICE BATTLE", 34, UIStyle.GOLD, 10)
	info.add_child(logo)
	_level_label = UIStyle.label("", 26, UIStyle.TEXT, 6)
	info.add_child(_level_label)
	_exp_bar = ProgressBar.new()
	_exp_bar.show_percentage = false
	_exp_bar.custom_minimum_size = Vector2(0, 12)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.05, 0.04, 0.1, 0.9)
	bg.set_corner_radius_all(6)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.45, 0.85, 1.0)
	fill.set_corner_radius_all(6)
	_exp_bar.add_theme_stylebox_override("background", bg)
	_exp_bar.add_theme_stylebox_override("fill", fill)
	info.add_child(_exp_bar)
	gems = GemCounter.new()
	gems.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(gems)

	# まん中: チャプター選択（スワイプ）
	carousel = ChapterCarousel.new()
	carousel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	carousel.custom_minimum_size = Vector2(0, 560)
	carousel.page_changed.connect(func(_c: int) -> void: _update_button())
	carousel.chapter_tapped.connect(func(_c: int) -> void:
		if not adventure_button.disabled:
			adventure_button.pressed.emit())
	box.add_child(carousel)

	# 今の装備
	_equip_row = HBoxContainer.new()
	_equip_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_equip_row.add_theme_constant_override("separation", 14)
	box.add_child(_equip_row)

	adventure_button = UIStyle.button("ぼうけんに でる", UIStyle.BUTTON_GOLD, 120, 48)
	adventure_button.pressed.connect(func() -> void: adventure_pressed.emit(carousel.selected_chapter()))
	box.add_child(adventure_button)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	box.add_child(row)
	equipment_button = UIStyle.button("そうび", UIStyle.BUTTON_BLUE, 100, 38)
	equipment_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	equipment_button.pressed.connect(func() -> void: equipment_pressed.emit())
	row.add_child(equipment_button)
	gacha_button = UIStyle.button("ガチャ", UIStyle.BUTTON_PINK, 100, 38)
	gacha_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gacha_button.pressed.connect(func() -> void: gacha_pressed.emit())
	row.add_child(gacha_button)


## 表示を作り直す。first_time = true なら、まだクリアしていないチャプターを表示する。
func refresh(progress: GameProgress, first_time: bool = false) -> void:
	_progress = progress
	gems.set_value(progress.gems)
	_level_label.text = "Lv%d   サイコロ %d こ" % [progress.level, progress.dice_count()]
	_exp_bar.max_value = progress.exp_to_next()
	_exp_bar.value = progress.exp_points
	carousel.refresh(progress, ChapterCarousel.suggested_chapter(progress) if first_time else 0)
	_update_button()
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
		icon.custom_minimum_size = Vector2(84, 84)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		cell.add_child(icon)
		_equip_row.add_child(cell)


func _update_button() -> void:
	if _progress == null:
		return
	var c := carousel.selected_chapter()
	var unlocked := _progress.is_chapter_unlocked(c)
	adventure_button.disabled = not unlocked
	adventure_button.text = "ぼうけんに でる" if unlocked else ("じゅんびちゅう" if not StageDatabase.is_playable(c) else "まだ いけない")
