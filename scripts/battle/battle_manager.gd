class_name BattleManager
extends Node3D
## バトル全体の進行役。
## フィールド・キャラクター・サイコロ・UI を生成し、状態遷移に従ってターンを進める。
## ステージ進行は GameProgress、ゲームルール（ダメージ計算）は DamageCalculator、
## 表示は BattleUI に任せる。

signal state_changed(new_state: BattleState.State)
signal turn_finished
signal stage_started(stage: StageData)
## バトルをやめる（to = &"home": ホームへ, &"stages": ステージ選択へ）。GameApp が画面を切りかえる
signal exit_requested(to: StringName)

var state: BattleState.State = BattleState.State.SETUP
var damage_calculator := DamageCalculator.new()
var progress := GameProgress.new()
var stage: StageData

var field: BattleField
## 1 こ目のサイコロ（dice_list[0]）
var dice: Dice
## 振るサイコロ全部（レベル 10 ごとに 1 こ増える）
var dice_list: Array[Dice] = []
var player: PlayerActor
## いま攻撃が当たる敵（生きている中でいちばん左）
var enemy: EnemyActor
## このステージの敵全部（左から順。たおれた敵も入ったまま）
var enemies: Array[EnemyActor] = []
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
## さいごにクリアしたときのごほうび（GameProgress.claim_stage_clear() の結果）
var last_reward: Dictionary = {}

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
## 「サイコロを振る」を長押し中（サイコロが宙で高速回転する）
var is_charging := false
var _charge_time := 0.0
var _spin_angle := 0.0
## 長押しでためきるまでの秒数
const CHARGE_FULL_TIME := 1.2


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
	dice_list = [dice]

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
	ui.roll_down.connect(begin_charge)
	ui.roll_up.connect(func() -> void:
		if is_charging:
			request_roll())
	ui.special_pressed.connect(request_special)
	ui.equip_pressed.connect(open_equipment)
	ui.home_pressed.connect(request_exit)
	ui.equipment.equip_requested.connect(change_equipment)
	ui.equipment.items_changed.connect(func() -> void: _refresh_player_stats())

	ui.overlay_action.connect(_on_overlay_action)

	start_stage(progress.stage_index)


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
	field.apply_theme(stage.theme)
	_spawn_actors()
	_sync_dice()
	camera.snap_default()
	ui.reset_view()
	ui.bind_actors(player, enemies)
	_retarget()
	ui.set_stage_info("STAGE %s  %s" % [stage.title, StageDatabase.chapter_name(stage.chapter)], stage.is_boss)
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
	ui.show_message(_appear_message())


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
		&"stages", &"home":
			exit_requested.emit(action)


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
	_set_dice_visible(false)
	camera.focus_default()

	# 次の敵たちを先のアリーナに置いておき、地面と一緒に近づいてくるようにする
	var nos := stage.enemy_nos if not stage.enemy_nos.is_empty() else [stage.enemy_no]
	for i in nos.size():
		var next_enemy := EnemyActor.new()
		next_enemy.name = "NextEnemy%d" % i
		var data := EnemyDatabase.get_enemy(nos[i])
		next_enemy.setup(data)
		next_enemy.size_scale = _enemy_scale(nos.size(), data)
		var spot := _enemy_spot(i, nos.size())
		next_enemy.position = spot - Vector3(0, 0, field.SEGMENT_LENGTH)
		_actors_root.add_child(next_enemy)
		var t := create_tween()
		t.tween_property(next_enemy, "position:z", spot.z, MARCH_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

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
	player.setup_stats("ゆうしゃ  Lv%d" % progress.level, progress.total_max_hp(), 1, 0)
	player.attack_bonus = progress.attack_bonus()
	player.power = progress.power() * progress.damage_bonus()
	player.damage_cut = progress.damage_cut()
	player.position = field.player_spot
	_actors_root.add_child(player)

	# 敵のグループ（左から順）
	enemies.clear()
	var nos := stage.enemy_nos if not stage.enemy_nos.is_empty() else [stage.enemy_no]
	for i in nos.size():
		var e := EnemyActor.new()
		e.name = "Enemy%d" % (i + 1)
		var data := EnemyDatabase.get_enemy(nos[i])
		e.setup(data)
		e.apply_stats(StageDatabase.enemy_stats(stage, i))
		e.size_scale = _enemy_scale(nos.size(), data)
		e.position = _enemy_spot(i, nos.size())
		_actors_root.add_child(e)
		enemies.append(e)
	enemy = enemies[0]


## グループの i 番目の敵の立ち位置（左から）
func _enemy_spot(i: int, n: int) -> Vector3:
	var xs := [0.0]
	if n == 2:
		xs = [-1.7, 1.7]
	elif n >= 3:
		xs = [-2.8, 0.0, 2.8]
	var spot := field.enemy_spot + Vector3(xs[mini(i, xs.size() - 1)], 0, 0)
	if n >= 3 and i != 1:
		spot.z += 0.5
	return spot


## 何体も並ぶときは少し小さく
func _enemy_scale(n: int, data: EnemyData) -> float:
	if n <= 1:
		return 1.0
	if data.is_boss:
		return 0.9
	return 0.85 if n == 2 else 0.75


func alive_enemies() -> Array[EnemyActor]:
	var list: Array[EnemyActor] = []
	for e in enemies:
		if not e.is_dead():
			list.append(e)
	return list


func all_enemies_dead() -> bool:
	return alive_enemies().is_empty()


## 攻撃が当たる敵を、生きている中でいちばん左の敵にする。
func _retarget() -> void:
	var alive := alive_enemies()
	if not alive.is_empty():
		enemy = alive[0]
	var flags: Array = []
	for e in enemies:
		flags.append(not e.is_dead())
	ui.set_target(enemies.find(enemy), flags)


func _appear_message() -> String:
	var lead := EnemyDatabase.get_enemy(stage.enemy_no)
	if enemies.size() <= 1:
		return "%sが あらわれた！" % lead.display_name
	return "%sたちが あらわれた！" % lead.display_name


func _set_state(new_state: BattleState.State) -> void:
	state = new_state
	ui.set_roll_enabled(BattleState.can_roll(state))
	ui.set_equip_enabled(can_change_equipment())
	ui.set_home_enabled(can_change_equipment())
	_update_special_ui()
	state_changed.emit(state)


func _update_special_ui() -> void:
	ui.update_special(progress.special_gauge, progress.is_special_ready(), BattleState.can_roll(state))


# ------------------------------------------------------------------
# ターン進行
# ------------------------------------------------------------------
## 「サイコロを振る」。PLAYER_TURN 以外では何もしない（連打・割り込み対策）。
## 長押ししていたら、ためた分だけ強く・速く回して投げる。
func request_roll() -> void:
	var charge := charge_ratio() if is_charging else 0.0
	_end_charge()
	if not BattleState.can_roll(state) or ui.is_equipment_open():
		return
	_set_state(BattleState.State.ROLLING)
	_run_player_turn(_battle_id, charge)


## 「サイコロを振る」を押しはじめた: サイコロが浮かんで回りはじめる（はなすと投げる）。
func begin_charge() -> void:
	if not BattleState.can_roll(state) or ui.is_equipment_open() or is_charging:
		return
	is_charging = true
	_charge_time = 0.0
	sound.play(&"dice_roll", -8.0, 1.4)


func charge_ratio() -> float:
	return clampf(_charge_time / CHARGE_FULL_TIME, 0.0, 1.0)


func _end_charge() -> void:
	if not is_charging:
		return
	is_charging = false
	ui.set_charge(-1.0)
	for d in dice_list:
		if not d.is_rolling:
			d.reset_to_rest()


func _process(delta: float) -> void:
	if not is_charging:
		return
	if not BattleState.can_roll(state):
		_end_charge()
		return
	_charge_time += delta
	var ratio := charge_ratio()
	# ためるほど高く浮かんで、速く回る
	_spin_angle += delta * lerpf(8.0, 40.0, ratio)
	for i in dice_list.size():
		var d := dice_list[i]
		var axis := Vector3(1, 0.6 + 0.2 * i, 0.3).normalized()
		var lift := 0.4 + 0.5 * ratio + 0.08 * sin(_spin_angle * 0.3 + i)
		d.global_transform = Transform3D(Basis(axis, _spin_angle + i), d.rest_position + Vector3(0, lift, 0))
	ui.set_charge(ratio)


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
			for d in dice_list:
				d.set_face_values(faces, true)
				HitEffect.spawn(_fx_root, d.global_position, color, 1.8)
			sound.play(&"critical")
			ui.show_message(weapon.get("special_message", ""))
			await _highlight_dice(color)
			await _wait(0.5)
		&"heal":
			var amount := roundi(player.max_hp * float(weapon.get("special_heal", 0.3)))
			player.heal(amount)
			HitEffect.spawn(_fx_root, player.global_position + Vector3(0, 1.2, 0), color, 1.6)
			player.flash(color, 0.8)
			sound.play(&"powerup")
			ui.show_message("%s（+%d）" % [weapon.get("special_message", ""), amount])
			await _wait(0.9)
		&"double_damage":
			_special_multiplier = float(weapon.get("special_multiplier", 2.0))
			HitEffect.spawn(_fx_root, player.global_position + Vector3(0, 1.2, 0), color, 1.8)
			player.flash(color, 0.8)
			sound.play(&"critical")
			ui.show_message(weapon.get("special_message", ""))
			await _wait(0.9)


func _run_player_turn(id: int, charge: float = 0.0) -> void:
	ui.show_message("スペシャル技で サイコロを振った！" if special_active else "サイコロを振った！")
	camera.focus_dice()
	sound.play(&"dice_roll")
	var roll := await _roll_all(id, 1.0 + 0.35 * charge)
	if id != _battle_id or roll == null:
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
	await _highlight_dice(Color(1, 0.7, 0.1) if attack_result.is_critical else Color(1, 1, 0.6))
	if id != _battle_id:
		return
	ui.show_dice_result(roll.values, attack_result.is_critical)
	if roll.values.size() > 1:
		ui.show_message("%s ＝ %d ダメージ！" % [" × ".join(roll.values.map(func(v: int) -> String: return str(v))), attack_result.amount])
	else:
		ui.show_message("出目は %d！" % roll.value)
	if attack_result.is_critical or attack_result.zorome_multiplier > 1:
		await _play_roll_effects(attack_result)
	else:
		await _wait(1.0)
	if id != _battle_id:
		return

	# --- プレイヤーの攻撃（あふれたダメージは次の敵へ） ---
	_set_state(BattleState.State.PLAYER_ATTACK)
	camera.focus_enemy()
	sound.play(&"attack")
	await player.lunge_to(enemy.position, 0.62)
	if id != _battle_id:
		return
	var hp_before := _group_hp()
	var hit := _deal_damage(attack_result)
	if not special_active:
		progress.charge_on_attack(hp_before - _group_hp(), _group_max_hp())
	special_active = false
	for d in dice_list:
		d.restore_normal_faces()
	_update_special_ui()
	player.return_home()
	var strength := 0.8 if attack_result.is_critical else 0.5
	for i in hit.size():
		if i < hit.size() - 1:
			hit[i].play_hit(Vector3(0, 0, -1), strength)
		else:
			await hit[i].play_hit(Vector3(0, 0, -1), strength)
	if id != _battle_id:
		return
	# たおれた敵（最後の 1 体は勝利の演出でたおれる）
	var finished := all_enemies_dead()
	var last_dead: EnemyActor = null
	for e in hit:
		if e.is_dead():
			last_dead = e
	for e in hit:
		if e.is_dead() and not (finished and e == last_dead):
			e.play_death(Vector3(0, 0, -1))
	if not finished and last_dead:
		sound.play(&"enemy_die")
	_retarget()
	await _wait(0.35)
	if id != _battle_id:
		return

	if finished:
		await _run_victory(id, last_dead)
		return

	camera.focus_default()
	await _wait(0.35)
	if id != _battle_id:
		return
	await _run_enemy_turn(id)


func _run_enemy_turn(id: int) -> void:
	_set_state(BattleState.State.ENEMY_TURN)
	var attackers := alive_enemies()
	for e in attackers:
		ui.show_message("%sの %s！" % [e.display_name, e.data.attack_name])
		await _wait(0.45 if attackers.size() == 1 else 0.25)
		if id != _battle_id:
			return
		camera.focus_player()
		sound.play(&"enemy_attack")
		await e.lunge_to(player.position, e.get_lunge_ratio(player.position))
		if id != _battle_id:
			return
		var result := damage_calculator.calculate_enemy_attack(e, player)
		var player_hp_before := player.hp
		_apply_damage(player, result, Vector3(0, 0, 1))
		progress.charge_on_hurt(player_hp_before - player.hp, player.max_hp)
		_update_special_ui()
		e.return_home()
		await player.play_hit(Vector3(0, 0, 1), 0.45)
		if id != _battle_id:
			return
		if player.is_dead():
			await _wait(0.3)
			await _run_defeat(id)
			return
	await _wait(0.3)
	if id != _battle_id:
		return

	camera.focus_default()
	for d in dice_list:
		d.reset_to_rest()
	_set_state(BattleState.State.PLAYER_TURN)
	ui.show_message("あなたのターン")
	turn_finished.emit()


func _group_hp() -> int:
	var total := 0
	for e in enemies:
		total += e.hp
	return total


func _group_max_hp() -> int:
	var total := 0
	for e in enemies:
		total += e.max_hp
	return total


## プレイヤーの攻撃を、ねらっている敵から順に当てる（あふれた分は次の敵へ）。当たった敵を返す。
func _deal_damage(result: AttackResult) -> Array[EnemyActor]:
	var remaining := result.amount
	var hit: Array[EnemyActor] = []
	var order := alive_enemies()
	var start := order.find(enemy)
	if start > 0:
		order = order.slice(start) + order.slice(0, start)
	for e in order:
		var dealt := mini(remaining, e.hp)
		var r := AttackResult.new(dealt, result.is_critical, result.dice_value)
		# 1 体目には攻撃の全ダメージを表示（あふれた分は次の敵に「+」で表示）
		_apply_damage(e, r, Vector3(0, 0, -1), result.amount if hit.is_empty() else dealt, not hit.is_empty())
		hit.append(e)
		remaining -= dealt
		if remaining <= 0:
			break
	return hit


## クリティカル・ゾロ目の派手な演出。
func _play_roll_effects(result: AttackResult) -> void:
	# 出目の大きな数字が消えてから
	await _wait(0.85)
	var zorome := result.zorome_multiplier > 1
	var color := Color(1.0, 0.55, 0.15)
	if zorome:
		color = Color(0.85, 0.45, 1.0) if result.zorome_multiplier < 8 else Color(1.0, 0.8, 0.25)
		# そろったサイコロを光らせる
		for d in dice_list:
			if result.zorome_groups.has(d.get_top_value()):
				d.play_result_highlight(color)
				HitEffect.spawn(_fx_root, d.global_position + Vector3(0, 0.6, 0), color, 1.4)
	var title := "CRITICAL!!"
	var subtitle := ""
	var strength := 1.5
	if result.all_zorome:
		title = "オールゾロ目！！"
		subtitle = "ダメージ ×%d" % result.zorome_multiplier
		strength = 2.5
	elif zorome:
		title = "ゾロ目！"
		subtitle = "ダメージ ×%d" % result.zorome_multiplier
		strength = 1.0 + log(result.zorome_multiplier) / log(2.0) * 0.3
	if result.is_critical and zorome:
		subtitle += "  CRITICAL!!"
		strength += 0.5
	sound.play(&"special" if result.all_zorome or strength >= 2.0 else &"critical")
	if result.is_critical:
		sound.play(&"critical", 2.0)
	camera.shake(0.4 + 0.2 * strength)
	if result.is_critical or result.all_zorome:
		_slow_motion(0.35)
	await ui.play_burst(title, subtitle, color, result.all_zorome, strength)


## 一瞬スローモーションにする（実時間 duration 秒）
func _slow_motion(duration: float) -> void:
	Engine.time_scale = 0.3
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0


func _exit_tree() -> void:
	Engine.time_scale = 1.0


## shown: 表示するダメージの数字（-1 なら result.amount）、spill: あふれたダメージ
func _apply_damage(target: BattleActor, result: AttackResult, knock_dir: Vector3, shown: int = -1, spill: bool = false) -> void:
	target.take_damage(result.amount)
	var is_enemy := target is EnemyActor
	var fx_color := Color(1.0, 0.75, 0.2) if result.is_critical else (Color(1.0, 0.95, 0.8) if is_enemy else Color(1.0, 0.3, 0.25))
	var power := 1.5 if result.is_critical else 1.0
	if special_active and is_enemy:
		fx_color = Color(1.0, 0.8, 0.3)
		power = 2.2
	HitEffect.spawn(_fx_root, target.get_hit_point() - knock_dir * 0.6, fx_color, power)
	var text := ("+%d" if spill else "-%d") % (result.amount if shown < 0 else shown)
	var popup_color := Color(1.0, 0.85, 0.2) if result.is_critical else (Color(1, 1, 1) if is_enemy else Color(1.0, 0.4, 0.35))
	DamagePopup.spawn(_fx_root, target.get_hit_point() + Vector3(0, 1.0, 0), text, popup_color, result.is_critical)
	if result.is_critical and not spill:
		DamagePopup.spawn(_fx_root, target.get_hit_point() + Vector3(0, 2.0, 0), "CRITICAL!", Color(1.0, 0.5, 0.15), false)
		# クリティカルは光のかけらを多めに
		for i in 3:
			var off := Vector3(randf_range(-0.8, 0.8), randf_range(0.2, 1.2), randf_range(-0.3, 0.3))
			HitEffect.spawn(_fx_root, target.get_hit_point() + off, Color(1.0, 0.85, 0.3), 1.8)
	camera.shake(1.1 if result.is_critical else 0.5)
	sound.play(&"damage")


func _run_victory(id: int, last: EnemyActor = null) -> void:
	var is_final := progress.is_final_stage()
	_set_state(BattleState.State.GAME_CLEAR if is_final else BattleState.State.VICTORY)
	ui.show_message("")
	sound.play(&"enemy_die")
	await (last if last else enemy).play_death(Vector3(0, 0, -1))
	if id != _battle_id:
		return
	camera.focus_default()
	sound.play(&"victory")
	var total_exp := 0
	var total_gold := 0
	for e in enemies:
		total_exp += e.reward_exp
		total_gold += e.reward_gold
	var reward := progress.claim_stage_clear(total_exp, total_gold)
	last_reward = reward
	var rewards: Array[String] = ["EXP +%d" % reward["exp"], "ゴールド +%s" % UIStyle.big_number(reward["gold"])]
	if reward["level"] > reward["level_before"]:
		rewards.append("LEVEL UP!  Lv%d → Lv%d" % [reward["level_before"], reward["level"]])
		sound.play(&"powerup")
	if reward["dice"] > reward["dice_before"]:
		rewards.append("サイコロが %d こに ふえた！" % reward["dice"])
	rewards.append("ジェム +%d" % (reward["gems"] - (GameProgress.FIRST_CLEAR_GEMS if reward["first_clear"] else 0)))
	if reward["first_clear"]:
		rewards.append("はじめてクリア！ ボーナス +%d" % GameProgress.FIRST_CLEAR_GEMS)
	var defeated := EnemyDatabase.get_enemy(stage.enemy_no).display_name + ("たち" if enemies.size() > 1 and not stage.is_boss else "")
	if is_final:
		ui.show_game_clear(defeated, rewards)
	else:
		ui.show_stage_clear(defeated, rewards)


func _run_defeat(id: int) -> void:
	_set_state(BattleState.State.DEFEAT)
	ui.show_message("")
	await player.play_death(Vector3(0, 0, 1))
	if id != _battle_id:
		return
	camera.focus_default()
	sound.play(&"defeat")
	ui.show_defeat()


# ------------------------------------------------------------------
# 装備
# ------------------------------------------------------------------
## 装備を変えられるのは、自分のターン中と結果画面（勝ち・負け）のとき。
func can_change_equipment() -> bool:
	return BattleState.can_roll(state) or BattleState.is_battle_over(state)


## 「ホーム」ボタン。自分のターン中・結果画面でだけ戻れる。
func request_exit() -> void:
	if not can_change_equipment() or ui.is_equipment_open():
		return
	sound.play(&"button")
	exit_requested.emit(&"home")


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
	_refresh_player_stats(slot)


## 装備・強化レベルが変わったとき、プレイヤーの能力にすぐ反映する。
func _refresh_player_stats(slot: StringName = &"") -> void:
	if player == null:
		return
	if slot == EquipmentDatabase.SLOT_DICE and not dice.is_rolling:
		for d in dice_list:
			d.apply_dice(progress.dice())
	player.attack_bonus = progress.attack_bonus()
	player.damage_cut = progress.damage_cut()
	player.power = progress.power() * progress.damage_bonus()
	var new_max := progress.total_max_hp()
	if new_max != player.max_hp and not player.is_dead():
		# 最大 HP が増えた分（減った分）だけ今の HP も増やす（1 は残す）
		player.hp = clampi(player.hp + new_max - player.max_hp, 1, new_max)
		player.max_hp = new_max
		ui.player_bar.set_values(player.hp, player.max_hp)


# ------------------------------------------------------------------
# サイコロ（複数）
# ------------------------------------------------------------------
## レベルに合わせてサイコロの数をそろえ、装備しているサイコロの見た目にして定位置へ並べる。
func _sync_dice() -> void:
	var count := progress.dice_count()
	while dice_list.size() < count:
		var d := Dice.new()
		d.name = "Dice%d" % (dice_list.size() + 1)
		add_child(d)
		d.impact.connect(_on_dice_impact)
		dice_list.append(d)
	while dice_list.size() > count:
		var d: Dice = dice_list.pop_back()
		remove_child(d)
		d.queue_free()
	var rows := ceili(count / 5.0)
	for i in dice_list.size():
		var d := dice_list[i]
		var row := i / 5
		var in_row := mini(count - row * 5, 5)
		var col := i % 5
		d.rest_position = field.dice_rest_position + Vector3((col - (in_row - 1) * 0.5) * 1.1, 0, (row - (rows - 1) * 0.5) * 1.15)
		d.apply_dice(progress.dice())
		d.restore_normal_faces()
		d.visible = true
		d.reset_to_rest()


func _set_dice_visible(value: bool) -> void:
	for d in dice_list:
		d.visible = value


## 全部のサイコロを投げて、全部止まるまで待つ。
func _roll_all(id: int, strength: float = 1.0) -> DiceResult:
	var n := dice_list.size()
	var cols := mini(n, 5)
	for i in n:
		# 横に最大 5 こ並べ、うしろの列は少し奥・高いところから（投げた瞬間にぶつからないように）
		var lane := 0.0 if cols == 1 else lerpf(-2.0, 2.0, (i % 5) / float(cols - 1))
		var offset := Vector3(lane, 0.9 * (i % 2) + 1.2 * (i / 5), -1.1 * (i / 5))
		dice_list[i].roll(strength, offset, 0.8 if n == 1 else 0.08)
	while true:
		await get_tree().physics_frame
		if id != _battle_id:
			return null
		var rolling := false
		for d in dice_list:
			if d.is_rolling:
				rolling = true
		if not rolling:
			break
	var values: Array[int] = []
	for d in dice_list:
		values.append(d.get_top_value())
	return DiceResult.from_values(values, dice.dice_type)


## 全部のサイコロの上の面を光らせる（終わるまで await できる）。
func _highlight_dice(color: Color) -> void:
	for i in range(1, dice_list.size()):
		dice_list[i].play_result_highlight(color)
	await dice.play_result_highlight(color)


func _on_dice_impact(strength: float) -> void:
	sound.play(&"dice_hit", linear_to_db(clampf(strength, 0.15, 1.0)), randf_range(0.9, 1.15))
	if strength > 0.5:
		camera.shake(0.15)


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
