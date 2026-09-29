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
## 次のステージへ歩いて進んでいる途中か
var is_marching := false

## 次のステージへ進む演出の長さ（秒）
const MARCH_DURATION := 2.6
## この攻撃がスペシャル技によるものか
var special_active := false

## リトライで古いコルーチンが動き続けないようにするための世代番号
var _battle_id := 0
var _actors_root: Node3D
var _fx_root: Node3D
## カットインで使う主人公のイラスト
const CUTIN_PORTRAIT := preload("res://assets/images/hero_cutin.jpg")
## 装備の保存先（Web 版ではブラウザの中に保存される）
const SAVE_PATH := "user://save.cfg"
## false にすると装備を保存・読み込みしない（テスト用。add_child 前に設定する）
var use_save := true
## スペシャル技でダメージが何倍になるか（マジック・ブーストなど）
var _special_multiplier := 1.0


func _ready() -> void:
	randomize()
	if use_save:
		progress.load_save(SAVE_PATH)
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
	ui.special_pressed.connect(request_special)
	ui.equip_pressed.connect(open_equipment)
	ui.equipment.equip_requested.connect(change_equipment)

	ui.overlay_action.connect(_on_overlay_action)

	start_stage(0)


func _unhandled_input(event: InputEvent) -> void:
	if ui.is_equipment_open():
		return
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
	is_marching = false
	special_active = false
	_special_multiplier = 1.0
	progress.stage_start_gauge = progress.special_gauge
	dice.restore_normal_faces()
	field.apply_theme(stage.theme)
	_spawn_actors()
	dice.visible = true
	dice.reset_to_rest()
	camera.snap_default()
	ui.reset_view()
	ui.bind_actors(player, enemy)
	ui.set_stage_info("CHAPTER %d  %s  (%d / %d)" % [stage.chapter, stage.title, stage.index + 1, progress.stage_count()], stage.is_boss)
	last_dice_result = null
	last_attack = null
	_set_state(BattleState.State.SETUP)
	ui.show_message("")
	stage_started.emit(stage)

	ui.show_road(stage.index, progress.stage_count())
	await ui.play_stage_intro(stage.title, stage.area_name, stage.is_boss)
	if id != _battle_id:
		return
	ui.hide_road()
	_set_state(BattleState.State.PLAYER_TURN)
	ui.show_message("%sが あらわれた！" % enemy.display_name)


## 結果画面のボタン。
func _on_overlay_action(action: StringName) -> void:
	if not BattleState.is_battle_over(state):
		return
	sound.play(&"button")
	match action:
		&"next":
			progress.advance()
			_march_to_next_stage()
		&"retry":
			progress.special_gauge = progress.stage_start_gauge
			start_battle()
		&"restart":
			progress.reset()
			start_stage(0)


## 敵を倒したあと、プレイヤーが次のステージへ歩いて進む演出。
## 地面（アリーナ）がスクロールし、先に待っている次の敵が近づいてくる。空の色も次のステージへ変わっていく。
func _march_to_next_stage() -> void:
	_battle_id += 1
	var id := _battle_id
	var from_index := progress.stage_index - 1
	stage = progress.current_stage()
	is_marching = true
	_set_state(BattleState.State.SETUP)
	ui.hide_overlay()
	ui.show_message("つぎのステージへ すすもう！")
	ui.show_road(from_index, progress.stage_count())
	ui.advance_road(stage.index, MARCH_DURATION)
	dice.visible = false
	camera.focus_default()

	# 次の敵を先のアリーナに置いておき、地面と一緒に近づいてくるようにする
	var next_enemy := EnemyActor.new()
	next_enemy.name = "NextEnemy"
	next_enemy.setup(EnemyDatabase.get_enemy(stage.enemy_no))
	next_enemy.position = field.enemy_spot - Vector3(0, 0, field.SEGMENT_LENGTH)
	_actors_root.add_child(next_enemy)
	var t := create_tween()
	t.tween_property(next_enemy, "position:z", field.enemy_spot.z, MARCH_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	field.tween_theme(stage.theme, MARCH_DURATION)
	player.play_walk(MARCH_DURATION, func() -> void: sound.play(&"step", -6.0, randf_range(0.85, 1.15)))
	await field.play_advance(MARCH_DURATION)
	if id != _battle_id:
		return
	start_battle()


func _spawn_actors() -> void:
	for child in _actors_root.get_children():
		_actors_root.remove_child(child)
		child.queue_free()
	for child in _fx_root.get_children():
		child.queue_free()

	player = PlayerActor.new()
	player.name = "Player"
	player.setup_stats("PLAYER", progress.total_max_hp(), 1, progress.defense_bonus())
	player.attack_bonus = progress.attack_bonus()
	player.position = field.player_spot
	_actors_root.add_child(player)

	enemy = EnemyActor.new()
	enemy.name = "Enemy"
	enemy.setup(EnemyDatabase.get_enemy(stage.enemy_no))
	enemy.position = field.enemy_spot
	_actors_root.add_child(enemy)


func _set_state(new_state: BattleState.State) -> void:
	state = new_state
	ui.set_roll_enabled(BattleState.can_roll(state))
	ui.set_equip_enabled(can_change_equipment())
	_update_special_ui()
	state_changed.emit(state)


func _update_special_ui() -> void:
	ui.update_special(progress.special_gauge, progress.is_special_ready(), BattleState.can_roll(state))


# ------------------------------------------------------------------
# ターン進行
# ------------------------------------------------------------------
## 「サイコロを振る」。PLAYER_TURN 以外では何もしない（連打・割り込み対策）。
func request_roll() -> void:
	if not BattleState.can_roll(state) or ui.is_equipment_open():
		return
	_set_state(BattleState.State.ROLLING)
	_run_player_turn(_battle_id)


## スペシャル技。ゲージが満タンのプレイヤーのターンだけ使える。
func request_special() -> void:
	if not BattleState.can_roll(state) or not progress.is_special_ready() or ui.is_equipment_open():
		return
	_set_state(BattleState.State.ROLLING)
	_run_special(_battle_id)


func _run_special(id: int) -> void:
	var weapon := progress.weapon()
	var color: Color = weapon.get("color", Color(1.0, 0.8, 0.3))
	progress.use_special()
	special_active = true
	_update_special_ui()
	ui.show_message("")
	# 1. 主人公に光が集まる
	camera.focus_player(0.4)
	sound.play(&"powerup")
	SpecialAura.spawn(_fx_root, player.position, color)
	player.flash(color, 1.2)
	await _wait(0.55)
	if id != _battle_id:
		return
	# 2. カットイン
	sound.play(&"special")
	camera.shake(0.4)
	await ui.play_special_cutin(weapon["special_name"] + "！", weapon["special_desc"], CUTIN_PORTRAIT, color)
	if id != _battle_id:
		return
	# 3. 武器ごとの効果
	await _activate_special(weapon, color)
	if id != _battle_id:
		return
	_run_player_turn(id)


## 武器のスペシャル技の効果。種類を増やすときはここに追加する。
func _activate_special(weapon: Dictionary, color: Color) -> void:
	match weapon.get("special_type", &""):
		&"dice_faces":
			camera.focus_dice(0.3)
			var faces: Array[int] = []
			faces.assign(weapon["special_faces"])
			dice.set_face_values(faces, true)
			HitEffect.spawn(_fx_root, dice.global_position, color, 1.8)
			sound.play(&"critical")
			ui.show_message(weapon.get("special_message", ""))
			await dice.play_result_highlight(color)
			await _wait(0.5)
		&"double_damage":
			_special_multiplier = float(weapon.get("special_multiplier", 2.0))
			HitEffect.spawn(_fx_root, player.global_position + Vector3(0, 1.2, 0), color, 1.8)
			player.flash(color, 0.8)
			sound.play(&"critical")
			ui.show_message(weapon.get("special_message", ""))
			await _wait(0.9)


func _run_player_turn(id: int) -> void:
	ui.show_message("スペシャル技で サイコロを振った！" if special_active else "サイコロを振った！")
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
	if _special_multiplier != 1.0:
		attack_result.amount = roundi(attack_result.amount * _special_multiplier)
		_special_multiplier = 1.0
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
	var enemy_hp_before := enemy.hp
	_apply_damage(enemy, attack_result, Vector3(0, 0, -1))
	if not special_active:
		progress.charge_on_attack(enemy_hp_before - enemy.hp, enemy.max_hp)
	special_active = false
	dice.restore_normal_faces()
	_update_special_ui()
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
	ui.show_message("%sの %s！" % [enemy.display_name, enemy.data.attack_name])
	await _wait(0.45)
	if id != _battle_id:
		return
	camera.focus_player()
	sound.play(&"enemy_attack")
	await enemy.lunge_to(player.position, enemy.get_lunge_ratio(player.position))
	if id != _battle_id:
		return
	var result := damage_calculator.calculate_enemy_attack(enemy, player)
	var player_hp_before := player.hp
	_apply_damage(player, result, Vector3(0, 0, 1))
	progress.charge_on_hurt(player_hp_before - player.hp, player.max_hp)
	_update_special_ui()
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
	var power := 1.5 if result.is_critical else 1.0
	if special_active and is_enemy:
		fx_color = Color(1.0, 0.8, 0.3)
		power = 2.2
	HitEffect.spawn(_fx_root, target.get_hit_point() - knock_dir * 0.6, fx_color, power)
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
	var rewards: Array[String] = []
	for pair in progress.claim_stage_rewards(progress.stage_index):
		rewards.append(String(EquipmentDatabase.get_item(pair[0], pair[1])["name"]))
	if not rewards.is_empty():
		sound.play(&"powerup")
	if is_final:
		ui.show_game_clear(enemy.display_name, rewards)
	else:
		ui.show_stage_clear(enemy.display_name, progress.total_max_hp(), progress.total_max_hp(progress.stage_index + 1), rewards)


func _run_defeat(id: int) -> void:
	_set_state(BattleState.State.DEFEAT)
	ui.show_message("")
	await player.play_death(Vector3(0, 0, 1))
	if id != _battle_id:
		return
	camera.focus_default()
	sound.play(&"defeat")
	ui.show_defeat(progress.stage_index > 0)


# ------------------------------------------------------------------
# 装備
# ------------------------------------------------------------------
## 装備を変えられるのは、自分のターン中と結果画面（勝ち・負け）のとき。
func can_change_equipment() -> bool:
	return BattleState.can_roll(state) or BattleState.is_battle_over(state)


func open_equipment() -> void:
	if not can_change_equipment() or ui.is_equipment_open():
		return
	sound.play(&"button")
	ui.open_equipment(progress)


## 装備を付けかえ、戦闘中ならすぐにプレイヤーの能力へ反映する。
func change_equipment(slot: StringName, id: StringName) -> void:
	if not can_change_equipment() or not progress.equip(slot, id):
		return
	sound.play(&"button", 0.0, 1.3)
	if player == null:
		return
	player.attack_bonus = progress.attack_bonus()
	player.defense = progress.defense_bonus()
	var new_max := progress.total_max_hp()
	if new_max != player.max_hp and not player.is_dead():
		# 最大 HP が増えた分（減った分）だけ今の HP も増やす（1 は残す）
		player.hp = clampi(player.hp + new_max - player.max_hp, 1, new_max)
		player.max_hp = new_max
		ui.player_bar.set_values(player.hp, player.max_hp)


func _on_dice_impact(strength: float) -> void:
	sound.play(&"dice_hit", linear_to_db(clampf(strength, 0.15, 1.0)), randf_range(0.9, 1.15))
	if strength > 0.5:
		camera.shake(0.15)


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
