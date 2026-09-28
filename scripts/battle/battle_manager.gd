class_name BattleManager
extends Node3D
## バトル全体の進行役。
## フィールド・キャラクター・サイコロ・UI を生成し、状態遷移に従ってターンを進める。
## ステージ進行は GameProgress、ゲームルール（ダメージ計算）は DamageCalculator、
## 表示は BattleUI に任せる。

signal state_changed(new_state: BattleState.State)
signal turn_finished
signal stage_started(stage: StageData)

var state: BattleState.State = BattleState.State.SETUP
var damage_calculator := DamageCalculator.new()
var progress := GameProgress.new()
var stage: StageData

var field: BattleField
var dice: Dice
var player: PlayerActor
var enemy: EnemyActor
var ui: BattleUI
var camera: BattleCamera
var sound: SoundManager
var last_dice_result: DiceResult
var last_attack: AttackResult

## リトライで古いコルーチンが動き続けないようにするための世代番号
var _battle_id := 0
var _actors_root: Node3D
var _fx_root: Node3D


func _ready() -> void:
	randomize()
	field = BattleField.new()
	field.name = "BattleField"
	add_child(field)

	_actors_root = Node3D.new()
	_actors_root.name = "Actors"
	add_child(_actors_root)
	_fx_root = Node3D.new()
	_fx_root.name = "Effects"
	add_child(_fx_root)

	dice = Dice.new()
	dice.name = "Dice"
	dice.rest_position = field.dice_rest_position
	add_child(dice)
	dice.impact.connect(_on_dice_impact)

	camera = BattleCamera.new()
	camera.name = "Camera"
	add_child(camera)

	sound = SoundManager.new()
	sound.name = "Sound"
	add_child(sound)

	ui = BattleUI.new()
	ui.name = "BattleUI"
	add_child(ui)
	ui.roll_pressed.connect(request_roll)
	ui.overlay_action.connect(_on_overlay_action)

	start_stage(0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if BattleState.can_roll(state):
			request_roll()
		elif BattleState.is_battle_over(state):
			ui.press_primary_overlay_button()


# ------------------------------------------------------------------
# ステージ開始・リトライ
# ------------------------------------------------------------------
## 指定ステージから開始する（0 = STAGE 1）。
func start_stage(index: int) -> void:
	progress.stage_index = clampi(index, 0, progress.stage_count() - 1)
	start_battle()


## 現在のステージのバトルを最初から始める。
func start_battle() -> void:
	_battle_id += 1
	var id := _battle_id
	stage = progress.current_stage()
	field.apply_theme(stage.theme)
	_spawn_actors()
	dice.reset_to_rest()
	camera.snap_default()
	ui.reset_view()
	ui.bind_actors(player, enemy)
	ui.set_stage_info("%s  (%d / %d)" % [stage.title, stage.index + 1, progress.stage_count()], stage.is_boss)
	last_dice_result = null
	last_attack = null
	_set_state(BattleState.State.SETUP)
	ui.show_message("")
	stage_started.emit(stage)

	await ui.play_stage_intro(stage.title, stage.area_name, stage.is_boss)
	if id != _battle_id:
		return
	_set_state(BattleState.State.PLAYER_TURN)
	ui.show_message("%s があらわれた！" % enemy.display_name)


## 結果画面のボタン。
func _on_overlay_action(action: StringName) -> void:
	if not BattleState.is_battle_over(state):
		return
	sound.play(&"button")
	match action:
		&"next":
			progress.advance()
			start_battle()
		&"retry":
			start_battle()
		&"restart":
			start_stage(0)


func _spawn_actors() -> void:
	for child in _actors_root.get_children():
		_actors_root.remove_child(child)
		child.queue_free()
	for child in _fx_root.get_children():
		child.queue_free()

	player = PlayerActor.new()
	player.name = "Player"
	player.setup_stats("PLAYER", progress.player_max_hp(), 1, 0)
	player.position = field.player_spot
	_actors_root.add_child(player)

	enemy = EnemyActor.new()
	enemy.name = "Enemy"
	enemy.setup(EnemyDatabase.get_enemy(stage.enemy_id))
	enemy.position = field.enemy_spot
	_actors_root.add_child(enemy)


func _set_state(new_state: BattleState.State) -> void:
	state = new_state
	ui.set_roll_enabled(BattleState.can_roll(state))
	state_changed.emit(state)


# ------------------------------------------------------------------
# ターン進行
# ------------------------------------------------------------------
## 「サイコロを振る」。PLAYER_TURN 以外では何もしない（連打・割り込み対策）。
func request_roll() -> void:
	if not BattleState.can_roll(state):
		return
	_set_state(BattleState.State.ROLLING)
	_run_player_turn(_battle_id)


func _run_player_turn(id: int) -> void:
	ui.show_message("サイコロを振った！")
	camera.focus_dice()
	sound.play(&"dice_roll")
	dice.roll()
	var roll: DiceResult = await dice.roll_finished
	if id != _battle_id:
		return
	last_dice_result = roll

	# --- 出目確定：一瞬タメる ---
	_set_state(BattleState.State.RESULT)
	var attack_result := damage_calculator.calculate_player_attack(roll, player, enemy)
	last_attack = attack_result
	sound.play(&"critical" if attack_result.is_critical else &"button")
	await dice.play_result_highlight(Color(1, 0.7, 0.1) if attack_result.is_critical else Color(1, 1, 0.6))
	if id != _battle_id:
		return
	ui.show_dice_result(roll.value, attack_result.is_critical)
	ui.show_message("出目は %d！" % roll.value)
	if attack_result.is_critical:
		camera.shake(0.35)
	await _wait(1.0)
	if id != _battle_id:
		return

	# --- プレイヤーの攻撃 ---
	_set_state(BattleState.State.PLAYER_ATTACK)
	camera.focus_enemy()
	sound.play(&"attack")
	await player.lunge_to(enemy.position, 0.62)
	if id != _battle_id:
		return
	_apply_damage(enemy, attack_result, Vector3(0, 0, -1))
	player.return_home()
	await enemy.play_hit(Vector3(0, 0, -1), 0.8 if attack_result.is_critical else 0.5)
	if id != _battle_id:
		return
	await _wait(0.35)
	if id != _battle_id:
		return

	if enemy.is_dead():
		await _run_victory(id)
		return

	camera.focus_default()
	await _wait(0.35)
	if id != _battle_id:
		return
	await _run_enemy_turn(id)


func _run_enemy_turn(id: int) -> void:
	_set_state(BattleState.State.ENEMY_TURN)
	ui.show_message("%s の%s！" % [enemy.display_name, enemy.data.attack_name])
	await _wait(0.45)
	if id != _battle_id:
		return
	camera.focus_player()
	sound.play(&"enemy_attack")
	await enemy.lunge_to(player.position, enemy.get_lunge_ratio())
	if id != _battle_id:
		return
	var result := damage_calculator.calculate_enemy_attack(enemy, player)
	_apply_damage(player, result, Vector3(0, 0, 1))
	enemy.return_home()
	await player.play_hit(Vector3(0, 0, 1), 0.45)
	if id != _battle_id:
		return
	await _wait(0.4)
	if id != _battle_id:
		return

	if player.is_dead():
		await _run_defeat(id)
		return

	camera.focus_default()
	dice.reset_to_rest()
	_set_state(BattleState.State.PLAYER_TURN)
	ui.show_message("あなたのターン")
	turn_finished.emit()


func _apply_damage(target: BattleActor, result: AttackResult, knock_dir: Vector3) -> void:
	target.take_damage(result.amount)
	var is_enemy := target == enemy
	var fx_color := Color(1.0, 0.75, 0.2) if result.is_critical else (Color(1.0, 0.95, 0.8) if is_enemy else Color(1.0, 0.3, 0.25))
	HitEffect.spawn(_fx_root, target.get_hit_point() - knock_dir * 0.6, fx_color, 1.5 if result.is_critical else 1.0)
	var text := "-%d" % result.amount
	var popup_color := Color(1.0, 0.85, 0.2) if result.is_critical else (Color(1, 1, 1) if is_enemy else Color(1.0, 0.4, 0.35))
	DamagePopup.spawn(_fx_root, target.get_hit_point() + Vector3(0, 1.0, 0), text, popup_color, result.is_critical)
	if result.is_critical:
		DamagePopup.spawn(_fx_root, target.get_hit_point() + Vector3(0, 2.0, 0), "CRITICAL!", Color(1.0, 0.5, 0.15), false)
	camera.shake(0.8 if result.is_critical else 0.5)
	sound.play(&"damage")


func _run_victory(id: int) -> void:
	var is_final := progress.is_final_stage()
	_set_state(BattleState.State.GAME_CLEAR if is_final else BattleState.State.VICTORY)
	ui.show_message("")
	sound.play(&"enemy_die")
	await enemy.play_death(Vector3(0, 0, -1))
	if id != _battle_id:
		return
	camera.focus_default()
	sound.play(&"victory")
	if is_final:
		ui.show_game_clear(enemy.display_name)
	else:
		ui.show_stage_clear(enemy.display_name, progress.player_max_hp(), progress.player_max_hp(progress.stage_index + 1))


func _run_defeat(id: int) -> void:
	_set_state(BattleState.State.DEFEAT)
	ui.show_message("")
	await player.play_death(Vector3(0, 0, 1))
	if id != _battle_id:
		return
	camera.focus_default()
	sound.play(&"defeat")
	ui.show_defeat(progress.stage_index > 0)


func _on_dice_impact(strength: float) -> void:
	sound.play(&"dice_hit", linear_to_db(clampf(strength, 0.15, 1.0)), randf_range(0.9, 1.15))
	if strength > 0.5:
		camera.shake(0.15)


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
