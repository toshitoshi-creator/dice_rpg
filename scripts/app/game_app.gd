class_name GameApp
extends Node
## ゲーム全体の画面の切りかえ役（main.tscn のいちばん上）。
##
## ホーム（チャプターをスワイプで選ぶ）→ ステージ選択（c-1〜c-10）→ バトル（BattleManager）
##       → そうび（EquipmentScreen）
##       → ガチャ（GachaScreen）
## プレイヤーのデータ（ジェム・持ち物・装備）は GameProgress 1 つを全画面で使い、save_path に保存する。

signal screen_changed(screen_name: StringName)

const SAVE_PATH := "user://save.cfg"
const SCREEN_HOME := &"home"
const SCREEN_EQUIPMENT := &"equipment"
const SCREEN_GACHA := &"gacha"
const SCREEN_STAGES := &"stages"
const SCREEN_BATTLE := &"battle"

## false にするとセーブデータを読み書きしない（テスト用。add_child 前に設定する）
var use_save := true

var progress := GameProgress.new()
var gacha := Gacha.new()
var sound: SoundManager
var battle: BattleManager
var current_screen: StringName = &""

var home: HomeScreen
var equipment: EquipmentScreen
var gacha_screen: GachaScreen
var stages: StageSelectScreen

var _menu_layer: CanvasLayer
var _screens: Dictionary = {}


func _ready() -> void:
	randomize()
	if use_save:
		progress.load_save(SAVE_PATH)
	sound = SoundManager.new()
	sound.name = "Sound"
	add_child(sound)

	_menu_layer = CanvasLayer.new()
	_menu_layer.layer = 5
	add_child(_menu_layer)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	var theme := Theme.new()
	theme.default_font_size = 28
	theme.set_color("font_color", "Label", UIStyle.TEXT)
	root.theme = theme
	_menu_layer.add_child(root)
	root.add_child(UIStyle.background())

	home = HomeScreen.new()
	root.add_child(home)
	home.adventure_pressed.connect(open_stages)
	home.equipment_pressed.connect(func() -> void: _go(SCREEN_EQUIPMENT))
	home.gacha_pressed.connect(func() -> void: _go(SCREEN_GACHA))

	stages = StageSelectScreen.new()
	root.add_child(stages)
	stages.back_pressed.connect(func() -> void: _go(SCREEN_HOME))
	stages.stage_selected.connect(start_stage)

	gacha_screen = GachaScreen.new()
	root.add_child(gacha_screen)
	gacha_screen.back_pressed.connect(func() -> void: _go(SCREEN_HOME))
	gacha_screen.pulled.connect(func(_r: Array) -> void: sound.play(&"button"))
	gacha_screen.result_view.cue.connect(_on_gacha_cue)

	equipment = EquipmentScreen.new()
	root.add_child(equipment)
	equipment.equip_requested.connect(func(slot: StringName, id: StringName) -> void:
		if progress.equip(slot, id):
			sound.play(&"button", 0.0, 1.3))
	equipment.closed.connect(func() -> void: _go(SCREEN_HOME))

	_screens = {SCREEN_HOME: home, SCREEN_STAGES: stages, SCREEN_GACHA: gacha_screen, SCREEN_EQUIPMENT: equipment}
	home.refresh(progress, true)
	show_home()


func show_home() -> void:
	_end_battle()
	_show(SCREEN_HOME)


## 画面ボタンを押したとき（音つき）
func _go(screen: StringName) -> void:
	sound.play(&"button")
	if screen == SCREEN_HOME:
		show_home()
	else:
		_show(screen)


func _show(screen: StringName) -> void:
	current_screen = screen
	_menu_layer.visible = screen != SCREEN_BATTLE
	for key in _screens:
		if key != SCREEN_EQUIPMENT:
			_screens[key].visible = key == screen
	match screen:
		SCREEN_HOME:
			home.refresh(progress)
		SCREEN_GACHA:
			gacha_screen.setup(progress, gacha)
		SCREEN_STAGES:
			stages.refresh()
		SCREEN_EQUIPMENT:
			equipment.open(progress)
	if screen != SCREEN_EQUIPMENT and equipment.visible:
		equipment.visible = false
	screen_changed.emit(screen)


## チャプター c のステージ選択を開く。
func open_stages(c: int) -> void:
	if not progress.is_chapter_unlocked(c):
		return
	sound.play(&"button")
	_end_battle()
	stages.open(progress, c)
	_show(SCREEN_STAGES)


## ステージ c-s のバトルを始める。
func start_stage(c: int, s: int) -> void:
	if not progress.is_stage_unlocked(c, s):
		return
	sound.play(&"button")
	_end_battle()
	progress.start_stage_at(c, s - 1)
	battle = BattleManager.new()
	battle.name = "Battle"
	battle.use_save = false
	battle.progress = progress
	battle.exit_requested.connect(_on_battle_exit)
	add_child(battle)
	_show(SCREEN_BATTLE)


## チャプターを 1 ステージ目から始める（テスト・デバッグ用）
func start_chapter(c: int) -> void:
	start_stage(c, 1)


func _on_battle_exit(to: StringName) -> void:
	if to == &"stages":
		(func() -> void:
			var c := progress.chapter
			_end_battle()
			stages.open(progress, c)
			_show(SCREEN_STAGES)).call_deferred()
	else:
		show_home.call_deferred()


func _end_battle() -> void:
	if battle:
		remove_child(battle)
		battle.queue_free()
		battle = null


func _on_gacha_cue(cue_name: StringName) -> void:
	match cue_name:
		&"charge":
			sound.play(&"powerup")
		&"burst":
			sound.play(&"critical")
		&"ssr":
			sound.play(&"special")
		&"card":
			sound.play(&"button", -4.0, 1.4)
