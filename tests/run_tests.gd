extends SceneTree
## 自動テスト（ゲームを実際に起動して遊ばせる統合テスト）。
##
## 実行:
##   godot --headless --path . -s res://tests/run_tests.gd
## スクリーンショット付き（画面のある環境で）:
##   godot --path . -s res://tests/run_tests.gd -- --shots
##
## 終了コード 0 = 全テスト成功

const MAIN_SCENE := "res://scenes/main.tscn"
const SHOT_DIR := "res://tests/output/"

var manager: BattleManager
var passed := 0
var failed := 0
var take_shots := false


func _initialize() -> void:
	take_shots = OS.get_cmdline_user_args().has("--shots")
	_run.call_deferred()


func _run() -> void:
	print("=== DICE BATTLE tests ===")
	await _test_dice_face_mapping()
	await _test_damage_table()
	await _test_dice_physics_rolls()
	await _test_enemy_models()

	var scene: PackedScene = load(MAIN_SCENE)
	manager = scene.instantiate() as BattleManager
	root.add_child(manager)
	await _frames(10)

	await _test_launch()
	await _test_full_turn()
	await _test_defeat_stage1()
	await _test_stage_progression()
	await _test_defeat_later_stage()

	print("")
	print("=== RESULT: %d passed, %d failed ===" % [passed, failed])
	quit(1 if failed > 0 else 0)


# ------------------------------------------------------------------
func _check(cond: bool, label: String) -> void:
	if cond:
		passed += 1
		print("  [PASS] ", label)
	else:
		failed += 1
		printerr("  [FAIL] ", label)


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _seconds(s: float) -> void:
	await create_timer(s).timeout


func _wait_state(target: BattleState.State, timeout: float) -> bool:
	# 画面描画ありの実行（--shots）はソフトウェア描画で遅くなるため待ち時間を延ばす
	if take_shots:
		timeout *= 3.0
	var start := Time.get_ticks_msec()
	while manager.state != target:
		if Time.get_ticks_msec() - start > timeout * 1000.0:
			return false
		await process_frame
	return true


func _shot(file_name: String) -> void:
	if not take_shots:
		return
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	img.save_png(ProjectSettings.globalize_path(SHOT_DIR + file_name))
	print("  (screenshot) ", file_name)


# ------------------------------------------------------------------
func _test_dice_face_mapping() -> void:
	print("\n[Unit] Dice face mapping")
	var d := Dice.new()
	root.add_child(d)
	await _frames(2)
	var ok := true
	for i in Dice.FACE_NORMALS.size():
		var n: Vector3 = Dice.FACE_NORMALS[i]
		var face_up := Basis.IDENTITY
		if n.is_equal_approx(Vector3.DOWN):
			face_up = Basis(Vector3.RIGHT, PI)
		elif not n.is_equal_approx(Vector3.UP):
			face_up = Basis(Quaternion(n, Vector3.UP))
		# 少し傾けても判定が変わらないこと
		var tilt := Basis(Vector3(1, 0, 1).normalized(), deg_to_rad(20.0))
		d.global_transform = Transform3D(tilt * face_up, Vector3(0, 3, 0))
		var v := d.get_top_value()
		if v != d.face_values[i]:
			ok = false
			printerr("    face %d expected %d got %d" % [i, d.face_values[i], v])
		# その面に表示されている数字ラベルも一致すること
		var label := d._face_labels[d.get_top_face_index()]
		if label.text != str(v):
			ok = false
			printerr("    label mismatch: %s vs %d" % [label.text, v])
	_check(ok, "each face normal pointing up yields its own number (and label)")
	var sums_ok := true
	for i in range(0, 6, 2):
		if d.face_values[i] + d.face_values[i + 1] != 7:
			sums_ok = false
	_check(sums_ok, "opposite faces sum to 7")
	d.queue_free()
	await _frames(2)


func _test_damage_table() -> void:
	print("\n[Unit] Damage table")
	var calc := DamageCalculator.new()
	var p := PlayerActor.new()
	var e := EnemyActor.new()
	e.setup(EnemyDatabase.get_enemy(&"slime"))
	var expected := {1: 5, 2: 10, 3: 15, 4: 20, 5: 30, 6: 50}
	var ok := true
	for v in expected:
		var r := calc.calculate_player_attack(DiceResult.new(v), p, e)
		if r.amount != expected[v]:
			ok = false
			printerr("    roll %d -> %d (expected %d)" % [v, r.amount, expected[v]])
		if r.is_critical != (v == 6):
			ok = false
	_check(ok, "roll 1..6 -> 5/10/15/20/30/50 damage, 6 is CRITICAL")
	_check(calc.calculate_enemy_attack(e, p).amount == 10, "slime attack deals 10 damage")
	_check(e.max_hp == 100 and e.attack == 10 and e.defense == 0, "slime stats HP100 ATK10 DEF0")
	_check(p.max_hp == 100 and p.attack == 1 and p.defense == 0, "player stats HP100 ATK1 DEF0")
	p.free()
	e.free()


func _test_dice_physics_rolls() -> void:
	print("\n[Physics] Standalone dice rolls")
	var holder := Node3D.new()
	root.add_child(holder)
	var field := BattleField.new()
	holder.add_child(field)
	var d := Dice.new()
	holder.add_child(d)
	await _frames(3)
	var counts := {}
	var all_valid := true
	var all_physical := true
	var all_match := true
	var rolls := 12
	for n in rolls:
		d.roll()
		var start_pos := d.global_position
		var max_y := 0.0
		var max_speed := 0.0
		var finished := [false, null]
		var cb := func(r: DiceResult) -> void:
			finished[0] = true
			finished[1] = r
		d.roll_finished.connect(cb, CONNECT_ONE_SHOT)
		var t0 := Time.get_ticks_msec()
		while not finished[0] and Time.get_ticks_msec() - t0 < 15000:
			await physics_frame
			max_y = maxf(max_y, d.global_position.y)
			max_speed = maxf(max_speed, d.linear_velocity.length())
		if not finished[0]:
			all_valid = false
			printerr("    roll %d did not finish" % n)
			continue
		var r: DiceResult = finished[1]
		counts[r.value] = counts.get(r.value, 0) + 1
		if r.value < 1 or r.value > 6:
			all_valid = false
		if max_y < 1.5 or max_speed < 3.0:
			all_physical = false
		if r.value != d.get_top_value() or r.up_alignment < 0.95:
			all_match = false
		print("    roll %2d -> %d  (peak height %.2f, align %.3f, %.2fs)" % [n + 1, r.value, max_y, r.up_alignment, (Time.get_ticks_msec() - t0) / 1000.0])
		await _frames(2)
	_check(all_valid, "all %d rolls settled with a value in 1..6" % rolls)
	_check(all_physical, "dice actually flew and moved (physics driven)")
	_check(all_match, "result equals the face that is physically on top and die is flat")
	_check(counts.size() >= 3, "results vary between rolls (%s)" % str(counts))
	holder.queue_free()
	await _frames(3)


# ------------------------------------------------------------------
func _press_overlay(action: StringName) -> bool:
	var t0 := Time.get_ticks_msec()
	while not manager.ui.is_overlay_visible() and Time.get_ticks_msec() - t0 < 6000:
		await process_frame
	var b := manager.ui.get_overlay_button(action)
	if b == null:
		return false
	b.pressed.emit()
	b.pressed.emit() # 連打
	await _frames(3)
	return true


## 実際にサイコロを振って、敵の HP を 1 にしてから倒す（時間短縮）。
func _win_current_stage(expected_state: BattleState.State) -> bool:
	if not await _wait_state(BattleState.State.PLAYER_TURN, 8.0):
		return false
	manager.enemy.hp = 1
	manager.request_roll()
	return await _wait_state(expected_state, 25.0)


func _test_enemy_models() -> void:
	print("\n[Unit] Enemy models & stages")
	var ok := true
	for id in EnemyDatabase.ENEMIES:
		var e := EnemyActor.new()
		e.setup(EnemyDatabase.get_enemy(id))
		root.add_child(e)
		var meshes := e.find_children("*", "MeshInstance3D", true, false).size()
		if meshes < 5:
			ok = false
			printerr("    %s has only %d meshes" % [id, meshes])
		e.queue_free()
	await _frames(2)
	_check(ok, "every enemy type builds its 3D model")
	_check(StageDatabase.count() == 4, "4 stages")
	var boss := StageDatabase.get_stage(3)
	_check(boss.is_boss and boss.enemy_id == &"dragon", "stage 4 is the DRAGON boss")
	var weak := true
	for i in 3:
		var st := StageDatabase.get_stage(i)
		if st.is_boss or not EnemyDatabase.has_enemy(st.enemy_id):
			weak = false
	_check(weak, "stages 1-3 are normal enemies")


func _test_launch() -> void:
	print("\n[Test 1] Launch")
	_check(manager.state == BattleState.State.SETUP, "battle starts with the stage intro (SETUP)")
	manager.request_roll()
	_check(manager.state == BattleState.State.SETUP, "cannot roll during the stage intro")
	await _seconds(0.5)
	await _shot("00_stage_intro.png")
	var ok := await _wait_state(BattleState.State.PLAYER_TURN, 6.0)
	_check(ok, "intro ends -> PLAYER_TURN")
	_check(manager.stage.index == 0 and manager.enemy.display_name == "SLIME" and manager.enemy.hp == 100, "STAGE 1: SLIME with 100 HP")
	_check(manager.player.hp == 100 and manager.player.max_hp == 100, "player has 100 HP")
	_check(not manager.ui.roll_button.disabled, "roll button is enabled")
	await _seconds(0.6)
	await _shot("01_start.png")


func _test_full_turn() -> void:
	print("\n[Test 2-7] Roll -> damage -> enemy counterattack")
	var enemy_hp := manager.enemy.hp
	var player_hp := manager.player.hp
	manager.ui.roll_button.pressed.emit()
	_check(manager.state == BattleState.State.ROLLING, "pressing the button starts ROLLING")
	_check(manager.ui.roll_button.disabled, "button disabled while rolling")
	for i in 5:
		manager.ui.roll_button.pressed.emit()
		manager.request_roll()
	_check(manager.state == BattleState.State.ROLLING, "button mashing does not break state")
	await _seconds(0.35)
	await _shot("02_rolling.png")
	_check(manager.dice.is_rolling and manager.dice.linear_velocity.length() > 0.5, "dice is physically moving")

	var ok := await _wait_state(BattleState.State.RESULT, 15.0)
	_check(ok, "dice stopped and result was decided")
	var value := manager.last_dice_result.value
	_check(value >= 1 and value <= 6, "roll value %d is in 1..6" % value)
	_check(value == manager.dice.get_top_value(), "roll value matches the physical top face")
	await _seconds(0.5)
	await _shot("03_result.png")
	manager.request_roll()
	_check(manager.state != BattleState.State.ROLLING, "cannot roll during RESULT")

	ok = await _wait_state(BattleState.State.ENEMY_TURN, 10.0)
	_check(ok, "enemy turn starts after player attack")
	var expected_damage: int = manager.damage_calculator.dice_damage[value]
	_check(manager.enemy.hp == enemy_hp - expected_damage, "enemy HP %d -> %d (dice %d = %d dmg)" % [enemy_hp, manager.enemy.hp, value, expected_damage])
	manager.request_roll()
	_check(manager.state == BattleState.State.ENEMY_TURN, "cannot roll during ENEMY_TURN")
	await _seconds(0.9)
	await _shot("04_enemy_attack.png")

	ok = await _wait_state(BattleState.State.PLAYER_TURN, 10.0)
	_check(ok, "back to PLAYER_TURN")
	_check(manager.player.hp == player_hp - 10, "enemy counterattacked: player HP %d -> %d" % [player_hp, manager.player.hp])
	_check(not manager.ui.roll_button.disabled, "button re-enabled on player turn")


func _test_defeat_stage1() -> void:
	print("\n[Test 9] Defeat (stage 1) -> retry")
	manager.enemy.attack = 999
	manager.request_roll()
	var ok := await _wait_state(BattleState.State.DEFEAT, 25.0)
	_check(ok and manager.player.hp == 0, "player HP 0 -> DEFEAT")
	manager.request_roll()
	_check(manager.state == BattleState.State.DEFEAT, "cannot roll after defeat")
	var t0 := Time.get_ticks_msec()
	while not manager.ui.is_overlay_visible() and Time.get_ticks_msec() - t0 < 5000:
		await process_frame
	_check(manager.ui.get_overlay_button(&"retry") != null and manager.ui.get_overlay_button(&"restart") == null, "stage 1 defeat offers retry only")
	await _seconds(0.6)
	await _shot("05_defeat.png")
	_check(await _press_overlay(&"retry"), "press retry")
	_check(manager.stage.index == 0 and manager.enemy.hp == 100 and manager.enemy.attack == 10, "retry restarts stage 1 with a fresh SLIME")
	_check(manager.player.hp == 100 and manager.player.visible, "player restored")


func _test_stage_progression() -> void:
	print("\n[Test 8/10] Stage 1 -> 2 -> 3 -> BOSS -> GAME CLEAR")
	var names := ["SLIME", "GOBLIN", "SKELETON", "DRAGON"]
	for i in 3:
		_check(manager.stage.index == i and manager.enemy.display_name == names[i], "stage %d: %s" % [i + 1, names[i]])
		_check(manager.player.max_hp == 100 + 20 * i and manager.player.hp == manager.player.max_hp, "player max HP %d, full HP at stage start" % manager.player.max_hp)
		var ok := await _win_current_stage(BattleState.State.VICTORY)
		_check(ok, "stage %d cleared (VICTORY)" % [i + 1])
		manager.request_roll()
		_check(manager.state == BattleState.State.VICTORY, "cannot roll after stage clear")
		var t0 := Time.get_ticks_msec()
		while not manager.ui.is_overlay_visible() and Time.get_ticks_msec() - t0 < 5000:
			await process_frame
		_check(not manager.enemy.visible, "enemy faded out")
		if i == 0:
			await _seconds(0.6)
			await _shot("06_stage_clear.png")
		_check(await _press_overlay(&"next"), "press 'next stage'")
		if i == 1:
			await _seconds(0.3)
			await _wait_state(BattleState.State.PLAYER_TURN, 6.0)
			await _seconds(0.3)
			await _shot("07_stage3_skeleton.png")
		if i == 0:
			await _wait_state(BattleState.State.PLAYER_TURN, 6.0)
			await _seconds(0.3)
			await _shot("07_stage2_goblin.png")

	_check(manager.stage.is_boss and manager.enemy.display_name == "DRAGON", "stage 4: DRAGON boss")
	_check(manager.enemy.max_hp == 220, "boss has 220 HP")
	_check(manager.player.max_hp == 160 and manager.player.hp == 160, "player max HP 160 at the boss")
	await _wait_state(BattleState.State.PLAYER_TURN, 6.0)
	await _seconds(0.3)
	await _shot("08_boss.png")
	# ボスとは実際に 1 ターン戦う
	var boss_hp := manager.enemy.hp
	manager.request_roll()
	var ok := await _wait_state(BattleState.State.PLAYER_TURN, 25.0)
	_check(ok and manager.enemy.hp < boss_hp and manager.player.hp == 160 - 14, "a full turn against the boss works (boss hits for 14)")
	await _shot("09_boss_fight.png")
	ok = await _win_current_stage(BattleState.State.GAME_CLEAR)
	_check(ok, "boss defeated -> GAME_CLEAR")
	var t0 := Time.get_ticks_msec()
	while not manager.ui.is_overlay_visible() and Time.get_ticks_msec() - t0 < 5000:
		await process_frame
	_check(manager.ui.get_overlay_button(&"restart") != null and manager.ui.get_overlay_button(&"next") == null, "GAME CLEAR screen offers 'play again'")
	await _seconds(0.6)
	await _shot("10_game_clear.png")
	_check(await _press_overlay(&"restart"), "press 'play again'")
	_check(manager.stage.index == 0 and manager.enemy.display_name == "SLIME" and manager.player.max_hp == 100, "back to STAGE 1 with base stats")


func _test_defeat_later_stage() -> void:
	print("\n[Test 9b] Defeat on stage 2 -> retry same stage / restart from stage 1")
	manager.start_stage(1)
	await _wait_state(BattleState.State.PLAYER_TURN, 6.0)
	manager.enemy.attack = 999
	manager.request_roll()
	var ok := await _wait_state(BattleState.State.DEFEAT, 25.0)
	_check(ok, "DEFEAT on stage 2")
	_check(await _press_overlay(&"retry"), "press retry")
	_check(manager.stage.index == 1 and manager.enemy.display_name == "GOBLIN" and manager.player.max_hp == 120, "retry keeps stage 2 (GOBLIN, max HP 120)")
	await _wait_state(BattleState.State.PLAYER_TURN, 6.0)
	manager.enemy.attack = 999
	manager.request_roll()
	ok = await _wait_state(BattleState.State.DEFEAT, 25.0)
	_check(ok, "DEFEAT again")
	_check(await _press_overlay(&"restart"), "press 'restart from stage 1'")
	_check(manager.stage.index == 0 and manager.enemy.display_name == "SLIME" and manager.player.max_hp == 100, "restart goes back to STAGE 1")
	ok = await _wait_state(BattleState.State.PLAYER_TURN, 6.0)
	manager.request_roll()
	ok = ok and await _wait_state(BattleState.State.PLAYER_TURN, 25.0)
	_check(ok and manager.enemy.hp < 100 and manager.player.hp == 90, "a full turn works after restart")
