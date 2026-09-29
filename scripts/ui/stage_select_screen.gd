class_name StageSelectScreen
extends Control
## ステージ選択画面（c-1 〜 c-10）。クリアしたステージの次まで遊べる。
## 各ステージの「おすすめレベル」を表示する。

signal stage_selected(chapter: int, stage: int)
signal back_pressed

var gems: GemCounter
var _progress: GameProgress
var _chapter := 1
var _title: Label
var _level: Label
var _grid: GridContainer


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 32)
	add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)
	gems = GemCounter.new()
	var back := UIStyle.top_bar(box, "ステージ", gems)
	back.pressed.connect(func() -> void: back_pressed.emit())
	_title = UIStyle.label("", 44, UIStyle.GOLD, 14)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_title)
	_level = UIStyle.label("", 28, UIStyle.TEXT, 8)
	_level.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_level)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 2
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("h_separation", 14)
	_grid.add_theme_constant_override("v_separation", 14)
	scroll.add_child(_grid)


func current_chapter() -> int:
	return _chapter


func open(progress: GameProgress, chapter: int) -> void:
	_progress = progress
	_chapter = chapter
	refresh()


func refresh() -> void:
	gems.set_value(_progress.gems)
	_title.text = "CHAPTER %d  %s" % [_chapter, StageDatabase.chapter_name(_chapter)]
	_level.text = "ゆうしゃ Lv%d   サイコロ %d こ   EXP %d / %d" % [_progress.level, _progress.dice_count(), _progress.exp_points, _progress.exp_to_next()]
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	for s in range(1, StageDatabase.count(_chapter) + 1):
		_grid.add_child(_make_button(s))


func _make_button(s: int) -> Button:
	var stage := StageDatabase.get_stage(s - 1, _chapter)
	var unlocked := _progress.is_stage_unlocked(_chapter, s)
	var cleared := _progress.is_stage_cleared(_chapter, s)
	var rec := StageDatabase.recommended_level(_chapter, s)
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, 150)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 30)
	b.set_meta(&"stage", s)
	var mark := "★ " if cleared else ""
	var name_line := "BOSS" if stage.is_boss else EnemyDatabase.get_enemy(stage.enemy_no).display_name
	if not unlocked:
		name_line = "？？？"
	b.text = "%s%s\n%s\nおすすめ Lv%d" % [mark, stage.title, name_line, rec]
	var color := Color(0.75, 0.2, 0.2) if stage.is_boss else Color(0.25, 0.45, 0.75)
	if not unlocked:
		color = Color(0.2, 0.2, 0.24)
	var border := UIStyle.GOLD if cleared else color.lightened(0.3)
	var fg := UIStyle.TEXT if unlocked else Color(0.5, 0.5, 0.55)
	# レベルが足りないときは おすすめレベルを赤っぽく（ボタンの文字は 1 色なので、枠の色で知らせる）
	if unlocked and _progress.level < rec:
		border = Color(1.0, 0.45, 0.35)
	for state_name in ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color"]:
		b.add_theme_color_override(state_name, fg)
	b.add_theme_stylebox_override("normal", UIStyle.box(color.darkened(0.35), border, 4, 18, 14, 9))
	b.add_theme_stylebox_override("hover", UIStyle.box(color.darkened(0.25), border, 4, 18, 14, 9))
	b.add_theme_stylebox_override("pressed", UIStyle.box(color.darkened(0.45), border, 4, 18, 14, 5))
	b.add_theme_stylebox_override("disabled", UIStyle.box(color.darkened(0.35), border, 4, 18, 14, 9))
	b.disabled = not unlocked
	b.pressed.connect(func() -> void: stage_selected.emit(_chapter, s))
	return b


## テスト用
func get_button(s: int) -> Button:
	for child in _grid.get_children():
		if child is Button and child.get_meta(&"stage") == s:
			return child
	return null
