class_name ChapterScreen
extends Control
## チャプター選択画面。遊べるのは、ステージが用意されていて、ひとつ前のチャプターをクリアしたチャプター。

signal chapter_selected(chapter: int)
signal back_pressed

## チャプターごとの帯の色
const COLORS := [
	Color(0.35, 0.7, 0.35), Color(0.2, 0.5, 0.3), Color(0.85, 0.6, 0.25), Color(0.45, 0.35, 0.6), Color(0.3, 0.3, 0.45),
	Color(0.55, 0.8, 0.95), Color(0.9, 0.35, 0.2), Color(0.2, 0.45, 0.8), Color(0.5, 0.2, 0.35), Color(0.35, 0.1, 0.25),
]

var gems: GemCounter
var _list: VBoxContainer
var _progress: GameProgress


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)
	gems = GemCounter.new()
	var back := UIStyle.top_bar(box, "チャプター", gems)
	back.pressed.connect(func() -> void: back_pressed.emit())
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 14)
	scroll.add_child(_list)


## チャプター c が遊べるか。
static func is_unlocked(progress: GameProgress, c: int) -> bool:
	return StageDatabase.is_playable(c) and (c == 1 or progress.is_chapter_cleared(c - 1))


func refresh(progress: GameProgress) -> void:
	_progress = progress
	gems.set_value(progress.gems)
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	for c in range(1, EnemyDatabase.CHAPTER_COUNT + 1):
		_list.add_child(_make_card(c))


func _make_card(c: int) -> Button:
	var unlocked := is_unlocked(_progress, c)
	var cleared := _progress.is_chapter_cleared(c)
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, 150)
	b.focus_mode = Control.FOCUS_NONE
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_size_override("font_size", 32)
	b.set_meta(&"chapter", c)
	var status := ""
	if cleared:
		status = "★ クリア！"
	elif unlocked:
		status = "ステージ %d  ＋ボス" % (StageDatabase.count(c) - 1)
	elif not StageDatabase.is_playable(c):
		status = "じゅんびちゅう"
	else:
		status = "CHAPTER %d をクリアすると あそべる" % (c - 1)
	b.text = "CHAPTER %d\n%s\n%s" % [c, StageDatabase.chapter_name(c), status]
	var color: Color = COLORS[(c - 1) % COLORS.size()]
	var bg := color.darkened(0.35) if unlocked else Color(0.14, 0.13, 0.16)
	var border := UIStyle.GOLD if cleared else (color.lightened(0.3) if unlocked else Color(0.3, 0.3, 0.33))
	var fg := UIStyle.TEXT if unlocked else Color(0.5, 0.5, 0.55)
	for state_name in ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color"]:
		b.add_theme_color_override(state_name, fg)
	b.add_theme_stylebox_override("normal", UIStyle.box(bg, border, 4, 18, 26, 10))
	b.add_theme_stylebox_override("hover", UIStyle.box(bg.lightened(0.08), border, 4, 18, 26, 10))
	b.add_theme_stylebox_override("pressed", UIStyle.box(bg.darkened(0.1), border, 4, 18, 26, 6))
	b.add_theme_stylebox_override("disabled", UIStyle.box(bg, border, 4, 18, 26, 10))
	b.disabled = not unlocked
	b.pressed.connect(func() -> void: chapter_selected.emit(c))
	return b


## テスト用
func get_card(c: int) -> Button:
	for child in _list.get_children():
		if child is Button and child.get_meta(&"chapter") == c:
			return child
	return null
