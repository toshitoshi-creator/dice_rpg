class_name GachaScreen
extends Control
## ガチャ画面。そうびガチャ / ダイスガチャを選んで 1 回 / 10 回引く。
## 引いた結果は GachaResultView で演出つきで見せる。

signal back_pressed
## ガチャを引いた（results は Gacha.pull() の結果）。音などは GameApp が鳴らす
signal pulled(results: Array)

var gems: GemCounter
var single_button: Button
var ten_button: Button
var result_view: GachaResultView

var _progress: GameProgress
var _gacha: Gacha
var _banner: StringName = Gacha.BANNER_EQUIPMENT
var _tabs: Array[Button] = []
var _banner_title: Label
var _banner_desc: Label
var _featured: HFlowContainer
var _banner_panel: PanelContainer
var _notice: Label


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
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)
	gems = GemCounter.new()
	var back := UIStyle.top_bar(box, "ガチャ", gems)
	back.pressed.connect(func() -> void:
		if not result_view.visible:
			back_pressed.emit())

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 12)
	box.add_child(tabs)
	for banner in Gacha.BANNERS:
		var b := UIStyle.button(Gacha.BANNERS[banner]["name"], UIStyle.BUTTON_GRAY, 80, 32)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.set_meta(&"banner", banner)
		b.pressed.connect(show_banner.bind(banner))
		tabs.add_child(b)
		_tabs.append(b)

	# バナー（ガチャの看板）
	_banner_panel = PanelContainer.new()
	_banner_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_banner_panel)
	var bbox := VBoxContainer.new()
	bbox.alignment = BoxContainer.ALIGNMENT_CENTER
	bbox.add_theme_constant_override("separation", 16)
	_banner_panel.add_child(bbox)
	_banner_title = UIStyle.label("", 64, UIStyle.GOLD, 18)
	_banner_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bbox.add_child(_banner_title)
	_banner_desc = UIStyle.label("", 30, UIStyle.TEXT, 8)
	_banner_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bbox.add_child(_banner_desc)
	var pickup := UIStyle.label("SSR ピックアップ", 26, Color(1, 0.9, 0.5), 8)
	pickup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bbox.add_child(pickup)
	_featured = HFlowContainer.new()
	_featured.alignment = FlowContainer.ALIGNMENT_CENTER
	_featured.add_theme_constant_override("h_separation", 6)
	_featured.add_theme_constant_override("v_separation", 6)
	bbox.add_child(_featured)
	var rates := UIStyle.label("出るかくりつ\n" + Gacha.rates_text(), 24, UIStyle.TEXT, 6)
	rates.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rates.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bbox.add_child(rates)
	var rules := UIStyle.label("10かいガチャは SR 以上が 1つ かくてい！\nもっているものが出たら ジェムに かわる", 24, Color(0.75, 0.95, 1.0), 6)
	rules.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rules.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bbox.add_child(rules)

	_notice = UIStyle.label("", 26, Color(1, 0.55, 0.5), 8)
	_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_notice)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	box.add_child(row)
	single_button = UIStyle.button("1かい\n%d ジェム" % Gacha.cost(1), UIStyle.BUTTON_BLUE, 130, 34)
	single_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	single_button.pressed.connect(pull.bind(1))
	row.add_child(single_button)
	ten_button = UIStyle.button("10かい\n%d ジェム" % Gacha.cost(10), UIStyle.BUTTON_PINK, 130, 34)
	ten_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ten_button.pressed.connect(pull.bind(10))
	row.add_child(ten_button)

	result_view = GachaResultView.new()
	add_child(result_view)
	result_view.closed.connect(_update)


func setup(progress: GameProgress, gacha: Gacha) -> void:
	_progress = progress
	_gacha = gacha
	_update()


func show_banner(banner: StringName) -> void:
	_banner = banner
	_update()


func current_banner() -> StringName:
	return _banner


## ガチャを引く。ジェムが足りなければ何もしない。
func pull(count: int) -> void:
	if _progress == null or result_view.visible:
		return
	if not _progress.can_spend(Gacha.cost(count)):
		_notice.text = "ジェムが たりない！ ステージを クリアして あつめよう"
		return
	var results := _gacha.pull(_progress, _banner, count)
	gems.set_value(_progress.gems)
	pulled.emit(results)
	result_view.play(results)


func _update() -> void:
	if _progress == null:
		return
	gems.set_value(_progress.gems)
	_notice.text = ""
	single_button.disabled = not _progress.can_spend(Gacha.cost(1))
	ten_button.disabled = not _progress.can_spend(Gacha.cost(10))
	var info: Dictionary = Gacha.BANNERS[_banner]
	_banner_title.text = info["name"]
	_banner_desc.text = info["desc"]
	var color := Color(0.55, 0.2, 0.45) if _banner == Gacha.BANNER_EQUIPMENT else Color(0.2, 0.35, 0.6)
	_banner_panel.add_theme_stylebox_override("panel", UIStyle.box(color.darkened(0.3), UIStyle.GOLD, 5, 24, 24))
	for b in _tabs:
		UIStyle.style_button(b, UIStyle.BUTTON_GOLD if b.get_meta(&"banner") == _banner else UIStyle.BUTTON_GRAY)
	for child in _featured.get_children():
		_featured.remove_child(child)
		child.queue_free()
	for pair in Gacha.pool(_banner, 4):
		var icon := TextureRect.new()
		icon.texture = EquipmentDatabase.get_icon(pair[0], pair[1])
		icon.custom_minimum_size = Vector2(96, 96)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_featured.add_child(icon)
