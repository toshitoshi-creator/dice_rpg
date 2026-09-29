class_name GachaResultView
extends Control
## ガチャの結果演出。光の玉がふるえて弾け、手に入れたものが 1 つずつ出てくる。
## 玉の色は出た中でいちばん高いレア度の色（SSR は金色に虹の光）。

signal closed
## 演出の段階（サウンド用）: &"charge", &"burst", &"card", &"ssr"
signal cue(name: StringName)

var _dim: ColorRect
var _orb: Orb
var _flash: ColorRect
var _grid: GridContainer
var _ok: Button
var _title: Label
var _running := false


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false


func _ready() -> void:
	_dim = ColorRect.new()
	_dim.color = Color(0.02, 0.01, 0.06, 0.94)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_dim)
	_orb = Orb.new()
	_orb.size = Vector2(320, 320)
	_orb.pivot_offset = Vector2(160, 160)
	add_child(_orb)
	_title = UIStyle.label("", 52, UIStyle.GOLD, 16)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_title.offset_top = 50
	_title.offset_bottom = 120
	add_child(_title)
	_grid = GridContainer.new()
	_grid.add_theme_constant_override("h_separation", 14)
	_grid.add_theme_constant_override("v_separation", 14)
	add_child(_grid)
	_ok = UIStyle.button("OK", UIStyle.BUTTON_GOLD, 100, 40)
	_ok.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_ok.offset_left = 60
	_ok.offset_right = -60
	_ok.offset_top = -150
	_ok.offset_bottom = -44
	_ok.pressed.connect(close)
	add_child(_ok)
	_flash = ColorRect.new()
	_flash.color = Color(1, 1, 1, 0)
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash)


func is_running() -> bool:
	return _running


func close() -> void:
	if _running:
		return
	visible = false
	closed.emit()


## 結果を演出つきで見せる。終わるまで await できる。
func play(results: Array) -> void:
	if results.is_empty():
		return
	visible = true
	_running = true
	_ok.visible = false
	_title.text = ""
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	var best := 1
	for d in results:
		best = maxi(best, int(d["rarity"]))
	var color: Color = EquipmentDatabase.RARITY_COLORS[best]

	# 1. 光の玉がふるえながら大きくなる
	_orb.color = color
	_orb.rainbow = best >= 4
	_orb.position = size * 0.5 - _orb.size * 0.5
	_orb.scale = Vector2.ONE * 0.2
	_orb.modulate.a = 1.0
	_orb.visible = true
	cue.emit(&"charge")
	var t := create_tween()
	t.tween_property(_orb, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	for i in 8:
		var off := Vector2(randf_range(-14, 14), randf_range(-14, 14)) * (1.0 + i * 0.15)
		t.tween_property(_orb, "position", size * 0.5 - _orb.size * 0.5 + off, 0.06)
	t.tween_property(_orb, "position", size * 0.5 - _orb.size * 0.5, 0.05)
	await t.finished
	# 2. はじける
	cue.emit(&"ssr" if best >= 4 else &"burst")
	t = create_tween()
	t.tween_property(_orb, "scale", Vector2.ONE * 3.0, 0.25).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(_orb, "modulate:a", 0.0, 0.25)
	t.parallel().tween_property(_flash, "color", Color(color.lightened(0.6), 0.9), 0.12)
	t.tween_property(_flash, "color:a", 0.0, 0.4)
	await get_tree().create_timer(0.3).timeout
	_orb.visible = false

	# 3. 手に入れたものを 1 つずつ見せる
	_title.text = "ガチャけっか"
	var single := results.size() == 1
	_grid.columns = 1 if single else 2
	var card_size := Vector2(560, 300) if single else Vector2(320, 150)
	var rows := ceili(results.size() / float(_grid.columns))
	var grid_size := Vector2(card_size.x * _grid.columns + 14 * (_grid.columns - 1), card_size.y * rows + 14 * (rows - 1))
	_grid.position = Vector2((size.x - grid_size.x) * 0.5, maxf(140.0, (size.y - 170.0 - grid_size.y) * 0.5 + 60.0))
	for d in results:
		var card := _make_card(d, card_size, single)
		_grid.add_child(card)
		card.modulate.a = 0.0
		card.pivot_offset = card_size * 0.5
		card.scale = Vector2.ONE * 0.4
		var ct := create_tween()
		ct.tween_property(card, "modulate:a", 1.0, 0.12)
		ct.parallel().tween_property(card, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		cue.emit(&"card")
		await get_tree().create_timer(0.12 if not single else 0.3).timeout
	_ok.visible = true
	_running = false


func _make_card(d: Dictionary, card_size: Vector2, big: bool) -> PanelContainer:
	var rarity := int(d["rarity"])
	var rcol: Color = EquipmentDatabase.RARITY_COLORS[rarity]
	var item := EquipmentDatabase.get_item(d["slot"], d["id"])
	var card := PanelContainer.new()
	card.custom_minimum_size = card_size
	card.add_theme_stylebox_override("panel", UIStyle.box(rcol.darkened(0.7), rcol, 5 if rarity >= 3 else 3, 16, 10))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)
	var icon := TextureRect.new()
	icon.texture = EquipmentDatabase.get_icon(d["slot"], d["id"])
	icon.custom_minimum_size = Vector2(220, 220) if big else Vector2(110, 110)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(icon)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(info)
	info.add_child(UIStyle.label(EquipmentDatabase.RARITY_NAMES[rarity], 44 if big else 28, rcol, 8))
	var name_label := UIStyle.label(item.get("name", ""), 36 if big else 22, UIStyle.TEXT, 6)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(name_label)
	if d["new"]:
		info.add_child(UIStyle.label("NEW!", 32 if big else 22, Color(1, 0.4, 0.35), 8))
	else:
		info.add_child(UIStyle.label("+%d ジェム" % d["gems"], 28 if big else 20, Color(0.55, 0.85, 1.0), 6))
	return card


## 光の玉
class Orb extends Control:
	var color := Color.WHITE
	var rainbow := false
	var _t := 0.0

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		var c := size * 0.5
		var r := size.x * 0.5
		for i in 8:
			var k := 1.0 - i / 8.0
			var col := color
			if rainbow:
				col = Color.from_hsv(fmod(_t * 0.6 + i * 0.12, 1.0), 0.6, 1.0)
			draw_circle(c, r * k, Color(col, 0.08 + 0.1 * (1.0 - k)))
		# 回る光の線
		for i in 12:
			var a := _t * 2.0 + i * TAU / 12.0
			draw_line(c + Vector2.from_angle(a) * r * 0.35, c + Vector2.from_angle(a) * r * 0.95, Color(color.lightened(0.5), 0.35), 4.0)
		draw_circle(c, r * 0.3, color.lightened(0.6))
		draw_circle(c, r * 0.18, Color(1, 1, 1))
