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
	await _test_bestiary()
	await _test_custom_models()
	_test_special_gauge_math()
	_test_equipment_data()
	_test_balance()
	_test_economy()

	_test_gacha_math()
	manager = BattleManager.new()
	manager.use_save = false
	root.add_child(manager)
	await _frames(10)

	await _test_launch()
	await _test_full_turn()
	await _test_special()
	await _test_equipment()
	await _test_charge_and_groups()
	await _test_defeat_stage1()
	await _test_stage_progression()
	await _test_defeat_later_stage()
	manager.queue_free()
	await _frames(3)
	await _test_app()

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
	e.setup(EnemyDatabase.get_enemy(1))
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
	_check(calc.calculate_enemy_attack(e, p).amount == e.attack, "enemy attack deals its ATK as damage")
	_check(e.display_name == "スライム" and e.max_hp == Balance.enemy_hp(1, 1) and e.attack == Balance.enemy_attack(1, 1) and e.defense == 0, "No.1 スライム (1-1): HP%d ATK%d DEF0" % [e.max_hp, e.attack])
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
func _wait_overlay() -> void:
	var limit := 6000.0 * (3.0 if take_shots else 1.0)
	var t0 := Time.get_ticks_msec()
	while not manager.ui.is_overlay_visible() and Time.get_ticks_msec() - t0 < limit:
		await process_frame


func _press_overlay(action: StringName) -> bool:
	await _wait_overlay()
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
	for e in manager.enemies:
		e.hp = 1
	manager.request_roll()
	return await _wait_state(expected_state, 25.0)


func _test_bestiary() -> void:
	print("\n[Unit] Enemy bestiary (240)")
	var all := EnemyDatabase.all()
	_check(all.size() == 240, "240 enemies registered (%d)" % all.size())
	var numbers_ok := true
	var ids := {}
	var names := {}
	var mobs := 0
	var bosses := 0
	var mob_species := {}
	var boss_species := {}
	for i in all.size():
		var e: EnemyData = all[i]
		if e.no != i + 1:
			numbers_ok = false
		ids[e.id] = true
		names[e.display_name] = true
		if e.is_boss:
			bosses += 1
			boss_species[e.species_id] = boss_species.get(e.species_id, 0) + 1
		else:
			mobs += 1
			mob_species[e.species_id] = mob_species.get(e.species_id, 0) + 1
	_check(numbers_ok, "No.1 - No.240 are sequential")
	_check(ids.size() == 240 and names.size() == 240, "ids and names are unique")
	_check(mobs == 180 and mob_species.size() == 60 and mob_species.values().all(func(c): return c == 3), "60 normal species x 3 colors = 180")
	_check(bosses == 60 and boss_species.size() == 20 and boss_species.values().all(func(c): return c == 3), "20 boss species x 3 colors = 60")
	# ステージ 1-1 → 10-10 の順に、敵はなめらかに強くなる（ボスはその前後の雑魚より強い）
	var stronger := true
	var prev_mob: EnemyData = null
	var stage_ok := true
	for c in range(1, 21):
		for i in 10:
			var st := StageDatabase.get_stage(i, c)
			var e := EnemyDatabase.get_enemy(st.enemy_no)
			if e.chapter != c or e.is_boss != st.is_boss or st.title != "%d-%d" % [c, i + 1]:
				stage_ok = false
			if st.is_boss:
				if not (e.max_hp > prev_mob.max_hp and e.attack > prev_mob.attack):
					stronger = false
				continue
			if prev_mob and not (e.max_hp > prev_mob.max_hp and e.attack >= prev_mob.attack):
				stronger = false
				printerr("    %s No.%d is not stronger than No.%d" % [st.title, e.no, prev_mob.no])
			prev_mob = e
	_check(stage_ok, "20 chapters x 10 stages (c-1..c-9 = the chapter's 9 mobs, c-10 = its boss)")
	_check(stronger, "enemies get gradually stronger from 1-1 to 20-10 (bosses stronger still)")
	_check(StageDatabase.recommended_level(20, 10) >= 70 and StageDatabase.recommended_level(20, 10) <= 80, "20-10 is for about Lv%d" % StageDatabase.recommended_level(20, 10))
	var first := EnemyDatabase.get_enemy(StageDatabase.get_stage(0, 1).enemy_no)
	var last := EnemyDatabase.get_enemy(StageDatabase.get_stage(9, 10).enemy_no)
	_check(first.max_hp <= 50 and first.attack <= 6, "1-1 %s is weak (HP %d, ATK %d)" % [first.display_name, first.max_hp, first.attack])
	_check(last.max_hp > 100000, "10-10 %s is huge (HP %d, ATK %d) -- dice multiply" % [last.display_name, last.max_hp, last.attack])

	# 全 240 体のモデルが作れて、パレットの色指定もれが無く、大きさが範囲内
	var model_ok := true
	var size_ok := true
	var roles_ok := true
	for e in all:
		var actor := EnemyActor.new()
		actor.setup(e)
		root.add_child(actor)
		var meshes := actor.find_children("*", "MeshInstance3D", true, false).size()
		if meshes < 8:
			model_ok = false
			printerr("    No.%d %s has only %d meshes" % [e.no, e.display_name, meshes])
		var sz := actor.get_model_size()
		if sz.y > e.target_height + 0.01 or sz.x > e.max_width + 0.01 or sz.y < 0.7:
			size_ok = false
			printerr("    No.%d size %s" % [e.no, sz])
		var kit := ModelKit.new(e.palette)
		EnemyModels.build(e.model_type, kit, Node3D.new())
		if not kit.missing_roles.is_empty():
			roles_ok = false
			printerr("    No.%d missing palette roles %s" % [e.no, kit.missing_roles])
		actor.queue_free()
	await _frames(2)
	_check(model_ok, "all 240 models build")
	_check(size_ok, "all models fit their target size")
	_check(roles_ok, "no missing palette colors")


func _test_custom_models() -> void:
	print("\n[Unit] Blender (.glb) models")
	# tests/fixtures の .glb は tools/blender/*.py を Blender で実行して書き出したもの
	var holder := Node3D.new()
	root.add_child(holder)
	var berry := EnemyDatabase.get_enemy(4)
	var kit := ModelKit.new(berry.palette)
	var slime := CustomModels.attach("res://tests/fixtures/fixture_slime.glb", holder, kit)
	_check(slime != null and slime.find_children("*", "MeshInstance3D", true, false).size() >= 8, "slime .glb from make_enemy_slime.py loads")
	_check(kit._cache.has(&"body") and kit._cache.has(&"body2"), "materials named body / body2 are recolored for %s" % berry.display_name)
	_check(kit.materials.size() >= 5, "all materials registered for hit flash / fade")
	var kit2 := ModelKit.new({})
	var player := CustomModels.attach("res://tests/fixtures/fixture_player.glb", holder, kit2)
	var weapon: Node3D = kit2.parts.get("weapon")
	_check(player != null and weapon != null and String(weapon.name).begins_with("Weapon"), "player .glb loads and its Weapon node swings")
	var size := ModelKit.compute_aabb(slime).size
	_check(size.x > size.y * 0.5 and ModelKit.compute_aabb(slime).end.y > 0.5, "glb is Y-up after import (height %.2f)" % ModelKit.compute_aabb(slime).end.y)
	_check(CustomModels.enemy_path(EnemyDatabase.get_enemy(1)) == "", "enemies without a .glb keep their built-in models")
	var hero := PlayerActor.new()
	holder.add_child(hero)
	var uses_hero := hero.find_child("CustomModel", true, false) != null
	_check(CustomModels.player_path() != "" and uses_hero and hero._sword_pivot != null and String(hero._sword_pivot.name).begins_with("Weapon"), "the hero (assets/models/player.glb) is used as the player and swings his sword")
	holder.queue_free()
	await _frames(2)


func _test_special_gauge_math() -> void:
	print("\n[Unit] Special gauge")
	var p := GameProgress.new()
	# 雑魚 3 体を倒しきったとき（ダメージを受けないとしても）
	for i in 3:
		p.charge_on_attack(100, 100)
	_check(p.special_gauge > 90.0 and not p.is_special_ready(), "after 3 enemies the gauge is %d%% (almost full)" % p.special_gauge)
	p.charge_on_hurt(12, 160)
	p.charge_on_attack(15, 135)
	_check(p.is_special_ready(), "it fills up early in the 4th fight")
	p.use_special()
	_check(p.special_gauge == 0.0, "using the special empties the gauge")
	var w := WeaponDatabase.get_weapon(p.weapon_id)
	var faces: Array = w["special_faces"]
	_check(w["special_type"] == &"dice_faces" and faces.size() == 6 and faces.all(func(v): return v >= 4 and v <= 6), "default sword (%s): special '%s' makes every face 4-6" % [w["name"], w["special_name"]])


func _test_balance() -> void:
	print("\n[Unit] Levels, multiple dice and balance")
	_check(Balance.dice_count(1) == 1 and Balance.dice_count(9) == 1 and Balance.dice_count(10) == 2 and Balance.dice_count(20) == 3 and Balance.dice_count(50) == 6, "dice: Lv1 = 1, Lv10 = 2, Lv20 = 3 ... Lv50 = 6")
	var table := DamageCalculator.new().dice_damage
	_check(Balance.dice_damage([6, 4, 2], table) == 400 and Balance.dice_damage([3], table) == 15 and Balance.dice_damage([1, 2], table) == 10, "dice multiply: 6x4x2 -> 50x4x2 = 400")
	var calc := DamageCalculator.new()
	var hero := BattleActor.new()
	var foe := BattleActor.new()
	hero.power = 2.0
	_check(calc.calculate_player_attack(DiceResult.from_values([5, 6] as Array[int]), hero, foe).amount == 600, "damage = dice x level power (30 x 10 x 2 = 600)")
	foe.attack = 100
	hero.damage_cut = 0.15
	_check(calc.calculate_enemy_attack(foe, hero).amount == 85, "shield cuts damage by %% (100 -> 85 with 15%%)")
	hero.free()
	foe.free()
	var p := GameProgress.new()
	var ups := p.add_exp(Balance.exp_to_next(1) + Balance.exp_to_next(2))
	_check(ups == 2 and p.level == 3 and p.exp_points == 0, "EXP levels you up (Lv1 -> Lv3)")
	_check(p.total_max_hp() == Balance.player_hp(3), "max HP grows with level (%d)" % p.total_max_hp())
	p.start_stage_at(1, 0)
	var r := p.claim_stage_clear(40)
	_check(r["exp"] == 40 and p.is_stage_cleared(1, 1) and p.is_stage_unlocked(1, 2) and not p.is_stage_unlocked(1, 3), "clearing 1-1 unlocks 1-2 (not 1-3)")
	# 目安: 10-10 は Lv50 くらいから
	var boss := EnemyDatabase.get_enemy(StageDatabase.get_stage(9, 10).enemy_no)
	var lv40 := _expected_turns(40, boss)
	var lv50 := _expected_turns(50, boss)
	_check(lv50 < 12.0 and lv40 > lv50 * 3.0, "10-10 boss: about %.0f turns at Lv50, %.0f turns at Lv40" % [lv50, lv40])


func _test_economy() -> void:
	print("\n[Unit] Gold, upgrades, selling, zorome, critical, groups")
	var s11 := StageDatabase.get_stage(0, 1)
	_check(s11.enemy_nos.size() == 1 and StageDatabase.enemy_stats(s11, 0)["gold"] == 10000, "1-1: one enemy that gives 10,000 gold")
	var sizes := {}
	var species := {}
	for c in range(1, 21):
		for i in 10:
			var st := StageDatabase.get_stage(i, c)
			sizes[st.enemy_nos.size()] = true
			for no in st.enemy_nos:
				species[EnemyDatabase.get_enemy(no).species_id] = true
	_check(sizes.has(1) and sizes.has(2) and sizes.has(3), "stages have groups of 1, 2 and 3 enemies")
	_check(species.size() >= 80, "%d species appear across the stages" % species.size())
	_check(Balance.exp_to_next(45) > Balance.exp_to_next(44) * 1.2, "leveling slows down after Lv40")
	# ゾロ目・クリティカル
	_check(Balance.zorome_multiplier([3, 3]) == 4 and Balance.zorome_multiplier([3, 3, 1]) == 2 and Balance.zorome_multiplier([2, 2, 5, 5]) == 4 and Balance.zorome_multiplier([6, 6, 6]) == 8, "zorome: pair x2, triple x4, all-same x2 more")
	_check(Balance.is_critical([6]) and not Balance.is_critical([5]) and Balance.is_critical([6, 1]) and not Balance.is_critical([6, 1, 2]) and Balance.is_critical([6, 6, 1]), "critical: sixes on at least half of the dice")
	var table := DamageCalculator.new().dice_damage
	_check(Balance.dice_damage([5, 5], table) == 30 * 6 * 4, "5-5 zorome: 30 x 6 x (2 x 2) = 720")
	# 強化・売却
	var p := GameProgress.new()
	var cheapest := 1 << 60
	for slot in EquipmentDatabase.SLOTS:
		for id in EquipmentDatabase.items(slot):
			cheapest = mini(cheapest, EquipmentDatabase.upgrade_cost(slot, id, 1))
	_check(cheapest == 100000, "cheapest upgrade costs 100,000 gold")
	_check(EquipmentDatabase.upgrade_cost(&"weapon", &"brave_sword", 5) > EquipmentDatabase.upgrade_cost(&"weapon", &"brave_sword", 4), "upgrades cost more at higher levels")
	_check(not p.upgrade(&"weapon", &"brave_sword"), "cannot upgrade without gold")
	p.gold = 150000
	var before := p.damage_bonus()
	_check(p.upgrade(&"weapon", &"brave_sword") and p.gold == 50000 and p.item_level(&"weapon", &"brave_sword") == 2 and p.damage_bonus() > before, "upgrade: -100,000 gold, Lv2, more damage")
	p.add_item(&"weapon", &"steel_sword")
	p.add_item(&"dice", &"silver_die")
	_check(not p.can_sell(&"weapon", &"brave_sword") and not p.can_sell(&"shield", &"trainee_shield"), "cannot sell equipped / starter items or shields")
	_check(p.sell_price(&"dice", &"silver_die") > p.sell_price(&"weapon", &"flame_sword"), "dice sell for more than weapons of the same rarity")
	var g0 := p.gold
	var price := p.sell(&"weapon", &"steel_sword")
	_check(price > 0 and p.gold == g0 + price and not p.is_owned(&"weapon", &"steel_sword"), "selling a weapon gives %s gold" % UIStyle.big_number(price))
	# あふれたダメージ
	var calc := DamageCalculator.new()
	_check(calc.calculate_player_attack(DiceResult.from_values([6, 6] as Array[int]), BattleActor.new(), BattleActor.new()).zorome_multiplier == 4, "6-6 gives zorome x4 (pair x2, all-same x2)")


## そのレベルでステージ（10-10）の敵を全部倒すのにかかる平均ターン数
func _expected_turns(level: int, _e: EnemyData) -> float:
	var stage := StageDatabase.get_stage(9, 10)
	var total := 0
	for i in stage.enemy_nos.size():
		total += StageDatabase.enemy_stats(stage, i)["max_hp"]
	var avg: float = Balance.AVERAGE_DAMAGE[Balance.dice_count(level)] * Balance.power(level)
	return total / avg


func _test_equipment_data() -> void:
	print("\n[Unit] Equipment data")
	var p := GameProgress.new()
	var ok := true
	for slot in EquipmentDatabase.SLOTS:
		if EquipmentDatabase.items(slot).size() < 3 or not p.is_owned(slot, p.equipped[slot]):
			ok = false
	_check(ok, "4 slots (weapon / shield / armor / dice), each with 3+ items and a starting item equipped")
	var icons_ok := true
	for slot in EquipmentDatabase.SLOTS:
		for id in EquipmentDatabase.items(slot):
			if EquipmentDatabase.get_icon(slot, id) == null:
				icons_ok = false
				printerr("    no icon: %s" % id)
	_check(icons_ok, "every item has an icon")
	var sets_ok := true
	for icon_set in EquipmentDatabase.ICON_SETS:
		for n in range(1, EquipmentDatabase.ICON_SETS[icon_set] + 1):
			if not ResourceLoader.exists(EquipmentDatabase.icon_path(icon_set, n)):
				sets_ok = false
	_check(sets_ok, "all 200 icons (weapons / swords / armors / shields x 50) are available")
	_check(p.attack_bonus() == 0 and p.defense_bonus() == 0 and p.hp_bonus() == 0 and p.weapon_id == WeaponDatabase.DEFAULT_WEAPON, "starting equipment adds nothing (base stats)")
	_check(not p.equip(&"shield", &"steel_shield"), "cannot equip an item you do not have")
	_check(p.add_item(&"shield", &"steel_shield") and not p.add_item(&"shield", &"steel_shield"), "items are added once (a second copy is a duplicate)")
	_check(p.equip(&"shield", &"steel_shield") and p.defense_bonus() == 6 and is_equal_approx(p.damage_cut(), 0.06), "equipping はがねのたて cuts damage by 6%")
	p.add_item(&"armor", &"hero_armor")
	p.add_item(&"weapon", &"steel_axe")
	p.add_item(&"weapon", &"magic_staff")
	p.equip(&"armor", &"hero_armor")
	p.equip(&"weapon", &"steel_axe")
	_check(p.total_max_hp() == 130 and p.attack_bonus() == 5, "ゆうしゃのよろい: max HP +30%, はがねのオノ: ATK +5")
	var rar_ok := true
	for slot in EquipmentDatabase.SLOTS:
		var seen := {}
		for id in EquipmentDatabase.items(slot):
			seen[EquipmentDatabase.rarity(slot, id)] = true
		if seen.size() != 4:
			rar_ok = false
	_check(rar_ok, "every slot has N / R / SR / SSR items")
	var faces_ok := true
	for id in DiceDatabase.DICE:
		var f: Array = DiceDatabase.DICE[id]["faces"]
		if f.size() != 6 or not f.all(func(v): return v >= 1 and v <= 6):
			faces_ok = false
	_check(faces_ok and DiceDatabase.DICE.size() >= 6, "%d dice, each with 6 faces of 1-6" % DiceDatabase.DICE.size())
	var axe := p.weapon()
	_check(axe["special_type"] == &"dice_faces" and (axe["special_faces"] as Array).all(func(v): return v == 1 or v == 6), "each weapon has its own special (axe: %s)" % axe["special_name"])
	var calc := DamageCalculator.new()
	var hero := BattleActor.new()
	hero.attack_bonus = 5
	var foe := BattleActor.new()
	_check(calc.calculate_player_attack(DiceResult.new(3), hero, foe).amount == 20, "weapon ATK is added to the dice damage (3 -> 15 + 5)")
	hero.free()
	foe.free()
	var path := "user://test_save.cfg"
	p.save_path = path
	p.save()
	var q := GameProgress.new()
	q.load_save(path)
	_check(q.weapon_id == &"steel_axe" and q.equipped[&"armor"] == &"hero_armor" and q.is_owned(&"weapon", &"magic_staff") and q.gems == p.gems, "gems, equipment and items are saved and loaded")
	p.reset()
	_check(p.is_owned(&"armor", &"hero_armor") and p.weapon_id == &"steel_axe", "starting an adventure keeps your items")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _test_equipment() -> void:
	print("\n[Test] Equipment screen")
	await _wait_state(BattleState.State.PLAYER_TURN, 10.0)
	_check(manager.ui.special_button.text == "SP", "special button says SP")
	_check(not manager.ui.equip_button.disabled, "equipment button is usable on your turn")
	manager.ui.equip_button.pressed.emit()
	await _frames(3)
	var screen := manager.ui.equipment
	_check(manager.ui.is_equipment_open(), "equipment screen opens")
	manager.request_roll()
	_check(manager.state == BattleState.State.PLAYER_TURN, "cannot roll while the equipment screen is open")
	_check(screen.get_card(&"steel_axe") != null and screen.get_card(&"steel_axe").text.contains("？？？"), "items you do not have yet are shown as ？？？")
	for pair in [[&"armor", &"chain_mail"], [&"shield", &"hero_shield"], [&"weapon", &"magic_staff"], [&"dice", &"gold_die"]]:
		manager.progress.add_item(pair[0], pair[1])
	var hp_before := manager.player.hp
	var max_before := manager.player.max_hp
	screen.show_slot(&"armor")
	screen.get_card(&"chain_mail").pressed.emit()
	var gain := manager.player.max_hp - max_before
	_check(manager.progress.equipped[&"armor"] == &"chain_mail" and gain == roundi(max_before * 0.1) and manager.player.hp == hp_before + gain, "くさりかたびら: max HP +10% right away")
	screen.show_slot(&"shield")
	screen.get_card(&"hero_shield").pressed.emit()
	_check(is_equal_approx(manager.player.damage_cut, 0.15), "ゆうしゃのたて: damage -15% right away")
	screen.show_slot(&"dice")
	screen.get_card(&"gold_die").pressed.emit()
	_check(manager.dice.face_values == [4, 6, 5, 6, 5, 6] and manager.progress.dice_id == &"gold_die", "おうごんのサイコロ: the die changes right away")
	screen.show_slot(&"weapon")
	screen.get_card(&"magic_staff").pressed.emit()
	_check(manager.player.attack_bonus == 2 and manager.progress.weapon()["special_type"] == &"double_damage", "まほうのつえ: ATK +2 and a different special")
	await _seconds(0.3)
	await _shot("13_equipment.png")
	screen.close()
	_check(not manager.ui.is_equipment_open(), "equipment screen closes")

	# まほうのつえのスペシャル技: ダメージ 2 倍
	_make_enemy_tough()
	var enemy_hp := manager.enemy.hp
	manager.progress.special_gauge = GameProgress.SPECIAL_MAX
	manager.request_special()
	var ok := await _wait_state(BattleState.State.ENEMY_TURN, 25.0)
	var v := manager.last_dice_result.value
	var expected: int = (manager.damage_calculator.dice_damage[v] + 2) * 2
	_check(ok and enemy_hp - manager.enemy.hp == expected, "マジック・ブースト doubles the damage (%d -> %d)" % [v, enemy_hp - manager.enemy.hp])
	await _wait_state(BattleState.State.PLAYER_TURN, 10.0)
	# 元の装備に戻す（以降のテストは基本の能力で行う）
	for slot in EquipmentDatabase.SLOTS:
		manager.change_equipment(slot, EquipmentDatabase.default_item(slot))
	_check(manager.player.attack_bonus == 0 and manager.player.damage_cut == 0.0 and manager.player.max_hp == 100 and manager.dice.face_values == [1, 6, 2, 5, 3, 4], "back to the starting equipment (and the normal die)")
	manager.progress.special_gauge = 0.0
	manager._update_special_ui()


func _test_charge_and_groups() -> void:
	print("\n[Test] Hold-to-spin and enemy groups")
	await _wait_state(BattleState.State.PLAYER_TURN, 10.0)
	_make_enemy_tough()
	manager.ui.roll_button.button_down.emit()
	_check(manager.is_charging, "holding the roll button starts charging")
	var rest := manager.dice.rest_position
	await _seconds(0.6)
	_check(manager.dice.global_position.y > rest.y + 0.3 and manager.charge_ratio() > 0.3, "the die floats up and spins while held (charge %d%%)" % roundi(manager.charge_ratio() * 100))
	await _shot("14_charge.png")
	manager.ui.roll_button.button_up.emit()
	_check(manager.state == BattleState.State.ROLLING and not manager.is_charging, "releasing throws the die")
	await _wait_state(BattleState.State.PLAYER_TURN, 20.0)
	# グループ: 1-7 は 3 体。1 回の攻撃であふれたダメージが次の敵へ
	manager.start_stage(6)
	await _launch_intro_done()
	_check(manager.enemies.size() == 3 and manager.ui.enemy_bars.size() == 3, "1-7: three enemies with three HP bars")
	await _shot("15_group.png")
	for e in manager.enemies:
		e.hp = 3
	var dealt := manager._deal_damage(AttackResult.new(8))
	_check(dealt.size() == 3 and manager.enemies[0].is_dead() and manager.enemies[1].is_dead() and manager.enemies[2].hp == 1, "8 damage kills 3 HP + 3 HP and spills 2 into the third")
	manager.start_stage(0)
	await _launch_intro_done()


func _test_gacha_math() -> void:
	print("\n[Unit] Gacha and gems")
	var p := GameProgress.new()
	_check(p.gems == GameProgress.START_GEMS, "you start with %d gems" % p.gems)
	var g := Gacha.new()
	g.rng.seed = 12345
	var counts := {1: 0, 2: 0, 3: 0, 4: 0}
	for i in 20000:
		counts[g.draw_one(Gacha.BANNER_EQUIPMENT)["rarity"]] += 1
	var rates_ok := true
	for r in counts:
		if absf(counts[r] / 20000.0 - Gacha.RATES[r]) > 0.01:
			rates_ok = false
	_check(rates_ok, "rarity rates N/R/SR/SSR = %s" % str(counts))
	var results := g.pull(p, Gacha.BANNER_EQUIPMENT, 10)
	var refund := 0
	var has_sr := false
	var owned_ok := true
	for d in results:
		refund += d["gems"]
		has_sr = has_sr or d["rarity"] >= 3
		if not p.is_owned(d["slot"], d["id"]) or d["slot"] == EquipmentDatabase.SLOT_DICE:
			owned_ok = false
	_check(results.size() == 10 and has_sr, "10-pull gives 10 items with at least one SR or better")
	_check(owned_ok, "pulled equipment is added to your items (no dice from the equipment gacha)")
	_check(p.gems == GameProgress.START_GEMS - Gacha.TEN_COST + refund, "10-pull costs %d gems (duplicates refunded %d)" % [Gacha.TEN_COST, refund])
	var before := p.gems
	p.gems = 50
	_check(g.pull(p, Gacha.BANNER_DICE, 1).is_empty() and p.gems == 50, "cannot pull without enough gems")
	p.gems = 1000
	var dice_results := g.pull(p, Gacha.BANNER_DICE, 1)
	_check(dice_results.size() == 1 and dice_results[0]["slot"] == EquipmentDatabase.SLOT_DICE, "dice gacha gives a die")
	var dup := {"slot": &"weapon", "id": &"brave_sword"}
	_check(not p.add_item(dup["slot"], dup["id"]), "a duplicate is not added twice")
	p.gems = before
	# ステージクリアのジェム
	var q := GameProgress.new()
	q.start_chapter(1)
	var r1 := q.claim_stage_clear()
	q.stage_index = q.stage_count() - 1
	var r2 := q.claim_stage_clear()
	var r3 := q.claim_stage_clear()
	_check(r1["gems"] == GameProgress.STAGE_GEMS and r2["gems"] == GameProgress.BOSS_GEMS + GameProgress.FIRST_CLEAR_GEMS and r2["first_clear"] and r3["gems"] == GameProgress.BOSS_GEMS, "stage clear gems: %d / boss %d (+%d first clear)" % [GameProgress.STAGE_GEMS, GameProgress.BOSS_GEMS, GameProgress.FIRST_CLEAR_GEMS])
	_check(q.is_chapter_cleared(1) and q.is_chapter_unlocked(1) and not GameProgress.new().is_chapter_unlocked(2), "chapter 1 is cleared; chapter 2 is locked")


func _test_app() -> void:
	print("\n[Test] Home / chapters / gacha / equipment screens")
	var app := (load(MAIN_SCENE) as PackedScene).instantiate() as GameApp
	app.use_save = false
	root.add_child(app)
	await _frames(5)
	_check(app.current_screen == GameApp.SCREEN_HOME and app.home.visible and app.battle == null, "the game starts on the HOME screen")
	await _shot("20_home.png")
	var car := app.home.carousel
	_check(car.page_count() == 20 and car.selected_chapter() == 1 and not app.home.adventure_button.disabled, "HOME shows the chapter cards (CHAPTER 1 selected, playable)")
	_check(car.get_boss_rect(1).texture != null and car.is_silhouette(1), "an uncleared chapter shows its boss as a silhouette")
	# 左へスワイプ → CHAPTER 2
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = Vector2(500, 300)
	car._gui_input(press)
	var drag := InputEventMouseMotion.new()
	drag.button_mask = MOUSE_BUTTON_MASK_LEFT
	drag.position = Vector2(300, 300)
	car._gui_input(drag)
	var release := press.duplicate() as InputEventMouseButton
	release.pressed = false
	release.position = drag.position
	car._gui_input(release)
	await _seconds(0.5)
	_check(car.selected_chapter() == 2 and app.home.adventure_button.disabled, "swiping left shows CHAPTER 2 (locked: cannot start)")
	await _shot("21_home_chapter2.png")
	car.go_to(0, false)
	app.progress.cleared_stages[1] = 10
	app.home.refresh(app.progress)
	_check(not car.is_silhouette(1) and car.is_silhouette(2), "after clearing, the boss is shown in color")
	await _seconds(0.3)
	await _shot("21_home_cleared.png")
	app.progress.cleared_stages.clear()
	app.home.refresh(app.progress)
	app.home.gacha_button.pressed.emit()
	await _frames(3)
	_check(app.current_screen == GameApp.SCREEN_GACHA and not app.gacha_screen.ten_button.disabled, "gacha screen opens (10-pull available with the starting gems)")
	await _shot("22_gacha.png")
	app.gacha.rng.seed = 7
	app.gacha_screen.ten_button.pressed.emit()
	_check(app.progress.gems < GameProgress.START_GEMS and app.gacha_screen.result_view.visible, "10-pull spends gems and shows the result")
	var t0 := Time.get_ticks_msec()
	while app.gacha_screen.result_view.is_running() and Time.get_ticks_msec() - t0 < 15000:
		await process_frame
	await _seconds(0.4)
	await _shot("23_gacha_result.png")
	app.gacha_screen.result_view.close()
	app.gacha_screen.show_banner(Gacha.BANNER_DICE)
	await _frames(2)
	await _shot("24_gacha_dice.png")
	app.gacha_screen.back_pressed.emit()
	await _frames(2)
	app.home.equipment_button.pressed.emit()
	await _frames(3)
	_check(app.current_screen == GameApp.SCREEN_EQUIPMENT and app.equipment.visible, "equipment screen opens from HOME")
	app.progress.add_item(&"dice", &"flame_die")
	app.equipment.show_slot(&"dice")
	app.equipment.get_card(&"flame_die").pressed.emit()
	_check(app.progress.dice_id == &"flame_die", "equip a die from the equipment screen")
	await _frames(2)
	await _shot("25_equipment_dice.png")
	app.equipment.close()
	await _frames(2)
	_check(app.current_screen == GameApp.SCREEN_HOME, "closing equipment goes back HOME")
	app.home.carousel.go_to(0, false)
	app.home.adventure_button.pressed.emit()
	await _frames(3)
	_check(app.current_screen == GameApp.SCREEN_STAGES and app.stages.current_chapter() == 1, "'adventure' opens the stage select for CHAPTER 1")
	_check(not app.stages.get_button(1).disabled and app.stages.get_button(2).disabled and app.stages.get_button(10) != null, "1-1 playable, 1-2 locked, up to 1-10")
	await _shot("27_stage_select.png")
	app.stages.get_button(1).pressed.emit()
	await _frames(5)
	_check(app.current_screen == GameApp.SCREEN_BATTLE and app.battle != null and app.battle.stage.chapter == 1, "choosing CHAPTER 1 starts the battle")
	var b := app.battle
	var t1 := Time.get_ticks_msec()
	while b.state != BattleState.State.PLAYER_TURN and Time.get_ticks_msec() - t1 < 8000:
		await process_frame
	_check(b.dice.face_values == [3, 6, 4, 5, 5, 6], "the equipped die (ほのおのサイコロ) is used in battle")
	await _shot("26_battle_flame_die.png")
	b.ui.home_button.pressed.emit()
	await _frames(3)
	_check(app.current_screen == GameApp.SCREEN_HOME and app.battle == null, "HOME button leaves the battle")
	app.queue_free()
	await _frames(2)


func _test_special() -> void:
	print("\n[Test] Special move")
	_make_enemy_tough()
	await _wait_state(BattleState.State.PLAYER_TURN, 5.0)
	_check(manager.ui.special_button.disabled, "special button is disabled while the gauge is not full")
	manager.request_special()
	_check(manager.state == BattleState.State.PLAYER_TURN, "cannot use the special without a full gauge")
	manager.progress.special_gauge = GameProgress.SPECIAL_MAX
	manager._update_special_ui()
	_check(not manager.ui.special_button.disabled, "special button becomes available when the gauge is full")
	manager.ui.special_button.pressed.emit()
	manager.ui.special_button.pressed.emit()
	manager.request_roll()
	_check(manager.state == BattleState.State.ROLLING and manager.special_active, "special started (mashing does not start it twice)")
	_check(manager.progress.special_gauge == 0.0, "gauge is used up")
	await _seconds(0.9)
	_check(manager.ui.is_cutin_playing(), "flashy cut-in is playing")
	await _shot("11_special_cutin.png")
	var t0 := Time.get_ticks_msec()
	while not manager.dice.is_rolling and Time.get_ticks_msec() - t0 < 12000 * (3 if take_shots else 1):
		await process_frame
	var faces_ok := manager.dice.is_special
	for v in manager.dice.face_values:
		if v < 4:
			faces_ok = false
	_check(faces_ok, "the golden die only has 4, 5 and 6 (%s)" % str(manager.dice.face_values))
	await _seconds(0.3)
	await _shot("12_special_roll.png")
	var ok := await _wait_state(BattleState.State.RESULT, 15.0)
	_check(ok and manager.last_dice_result.value >= 4, "special roll result is %d (4 or more)" % manager.last_dice_result.value)
	_check(manager.last_dice_result.value == manager.dice.get_top_value(), "result still matches the physical top face")
	ok = await _wait_state(BattleState.State.ENEMY_TURN, 10.0)
	_check(ok and not manager.dice.is_special and manager.dice.face_values == [1, 6, 2, 5, 3, 4], "die returns to normal after the special attack")
	_check(manager.progress.special_gauge == 0.0, "the special attack itself does not charge the gauge")
	await _wait_state(BattleState.State.PLAYER_TURN, 10.0)
	_check(manager.progress.special_gauge > 0.0, "taking damage charges the gauge a little")


func _launch_intro_done() -> bool:
	return await _wait_state(BattleState.State.PLAYER_TURN, 6.0)


## 敵がうっかり倒れないように HP を増やす（反撃・敗北のテスト用）。
func _make_enemy_tough() -> void:
	manager.enemy.max_hp = 9999
	manager.enemy.hp = 9999


func _test_launch() -> void:
	print("\n[Test 1] Launch")
	_check(manager.state == BattleState.State.SETUP, "battle starts with the stage intro (SETUP)")
	manager.request_roll()
	_check(manager.state == BattleState.State.SETUP, "cannot roll during the stage intro")
	await _seconds(0.5)
	await _shot("00_stage_intro.png")
	var ok := await _launch_intro_done()
	_check(ok, "intro ends -> PLAYER_TURN")
	_check(manager.stage.index == 0 and manager.enemy.data.no == 1 and manager.enemy.hp == EnemyDatabase.get_enemy(1).max_hp, "1-1: No.1 スライム (HP %d)" % manager.enemy.hp)
	_check(manager.player.hp == 100 and manager.player.max_hp == 100, "player has 100 HP")
	_check(not manager.ui.roll_button.disabled, "roll button is enabled")
	await _seconds(0.6)
	await _shot("01_start.png")


func _test_full_turn() -> void:
	print("\n[Test 2-7] Roll -> damage -> enemy counterattack")
	_make_enemy_tough()
	var enemy_hp := manager.enemy.hp
	var player_hp := manager.player.hp
	var enemy_atk := manager.enemy.attack
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
	var expected_damage: int = maxi(manager.damage_calculator.dice_damage[value] - manager.enemy.defense, 1)
	_check(manager.enemy.hp == enemy_hp - expected_damage, "enemy HP %d -> %d (dice %d = %d dmg)" % [enemy_hp, manager.enemy.hp, value, expected_damage])
	manager.request_roll()
	_check(manager.state == BattleState.State.ENEMY_TURN, "cannot roll during ENEMY_TURN")
	await _seconds(0.9)
	await _shot("04_enemy_attack.png")

	ok = await _wait_state(BattleState.State.PLAYER_TURN, 10.0)
	_check(ok, "back to PLAYER_TURN")
	_check(manager.player.hp == player_hp - enemy_atk, "enemy counterattacked: player HP %d -> %d" % [player_hp, manager.player.hp])
	_check(not manager.ui.roll_button.disabled, "button re-enabled on player turn")


func _test_defeat_stage1() -> void:
	print("\n[Test 9] Defeat (stage 1) -> retry")
	_make_enemy_tough()
	manager.enemy.attack = 999
	manager.request_roll()
	var ok := await _wait_state(BattleState.State.DEFEAT, 25.0)
	_check(ok and manager.player.hp == 0, "player HP 0 -> DEFEAT")
	manager.request_roll()
	_check(manager.state == BattleState.State.DEFEAT, "cannot roll after defeat")
	await _wait_overlay()
	_check(manager.ui.get_overlay_button(&"retry") != null and manager.ui.get_overlay_button(&"stages") != null, "defeat offers retry and stage select")
	await _seconds(0.6)
	await _shot("05_defeat.png")
	var start_gauge := manager.progress.stage_start_gauge
	_check(await _press_overlay(&"retry"), "press retry")
	var slime := EnemyDatabase.get_enemy(1)
	_check(manager.stage.index == 0 and manager.enemy.hp == slime.max_hp and manager.enemy.attack == slime.attack, "retry restarts 1-1 with a fresh スライム")
	_check(is_equal_approx(manager.progress.special_gauge, start_gauge), "retry puts the SP gauge back to its value at the stage start")
	_check(manager.player.hp == manager.player.max_hp and manager.player.visible, "player restored")


func _test_stage_progression() -> void:
	print("\n[Test 8/10] 1-1 -> 1-2 -> ... -> 1-10 (BOSS) -> CHAPTER CLEAR")
	var level_start := manager.progress.level
	for i in 9:
		var expected := EnemyDatabase.get_enemy(StageDatabase.get_stage(i).enemy_no)
		var nos: Array = manager.enemies.map(func(e: EnemyActor) -> int: return e.data.no)
		_check(manager.stage.index == i and manager.stage.enemy_no == i + 1 and nos.has(i + 1) and manager.stage.title == "1-%d" % (i + 1), "stage 1-%d: No.%d %s and %d enemies %s" % [i + 1, expected.no, expected.display_name, nos.size(), str(nos)])
		_check(manager.player.max_hp == manager.progress.total_max_hp() and manager.player.hp == manager.player.max_hp, "Lv%d: max HP %d, full HP at stage start" % [manager.progress.level, manager.player.max_hp])
		var ok := await _win_current_stage(BattleState.State.VICTORY)
		_check(ok, "stage 1-%d cleared (VICTORY)" % [i + 1])
		manager.request_roll()
		_check(manager.state == BattleState.State.VICTORY, "cannot roll after stage clear")
		await _wait_overlay()
		_check(manager.last_reward.get("exp", 0) > 0 and manager.progress.is_stage_unlocked(1, i + 2), "EXP +%d, 1-%d unlocked" % [manager.last_reward.get("exp", 0), i + 2])
		if i == 0:
			_check(not manager.enemy.visible, "enemy faded out")
			await _seconds(0.6)
			await _shot("06_stage_clear.png")
		_check(await _press_overlay(&"next"), "press 'next stage'")
		if i == 0:
			# 前へ進む演出
			_check(manager.is_marching and manager.state == BattleState.State.SETUP, "player marches toward 1-2")
			_check(manager.stage.index == 1, "only one stage advanced even with button mashing")
			manager.request_roll()
			_check(manager.state == BattleState.State.SETUP, "cannot roll while marching")
			_check(not manager.dice.visible and manager.ui.is_road_visible(), "dice hidden and road map shown while marching")
			# 描画が遅い環境でも、歩き終わる前に確認できるよう少しずつ見る
			var moved := false
			var tm := Time.get_ticks_msec()
			while Time.get_ticks_msec() - tm < 2400 and manager.is_marching:
				if manager.field.get_scroll_offset() > 1.0 and manager.ui.get_road_progress() > i:
					moved = true
					break
				await process_frame
			_check(moved, "ground scrolls and road marker moves forward")
			await _shot("06b_march.png")
		await _launch_intro_done()
		if i == 0:
			_check(not manager.is_marching and manager.dice.visible and is_zero_approx(manager.field.get_scroll_offset()), "arrived: field reset, dice back")
			await _seconds(0.3)
			await _shot("07_stage2.png")

	_check(manager.progress.level > level_start, "leveled up while clearing stages (Lv%d -> Lv%d)" % [level_start, manager.progress.level])
	_check(manager.stage.is_boss and manager.stage.title == "1-10" and manager.enemy.data.no == 10 and manager.enemy.data.is_boss, "1-10 BOSS: No.10 %s (HP %d)" % [manager.enemy.display_name, manager.enemy.max_hp])
	await _launch_intro_done()
	await _seconds(0.3)
	await _shot("08_boss.png")
	var boss_atk := manager.enemy.attack
	var max_hp := manager.player.max_hp
	_make_enemy_tough()
	var boss_hp := manager.enemy.hp
	manager.request_roll()
	var ok := await _wait_state(BattleState.State.PLAYER_TURN, 25.0)
	_check(ok and manager.enemy.hp < boss_hp and manager.player.hp == max_hp - boss_atk, "a full turn against the boss works (boss hits for %d)" % boss_atk)
	await _shot("09_boss_fight.png")
	ok = await _win_current_stage(BattleState.State.GAME_CLEAR)
	_check(ok, "boss defeated -> CHAPTER CLEAR")
	await _wait_overlay()
	_check(manager.ui.get_overlay_button(&"home") != null and manager.ui.get_overlay_button(&"next") == null, "CHAPTER CLEAR screen offers 'home' (no next stage)")
	_check(manager.progress.is_chapter_cleared(1) and manager.progress.is_chapter_unlocked(2), "chapter 1 cleared -> chapter 2 unlocked")
	await _seconds(0.6)
	await _shot("10_game_clear.png")
	var exits: Array = []
	manager.exit_requested.connect(func(to: StringName) -> void: exits.append(to))
	_check(await _press_overlay(&"home"), "press 'home'")
	_check(exits == [&"home"], "the battle asks to go back HOME")
	manager.start_stage(0)
	await _frames(2)
	_check(manager.stage.index == 0 and manager.enemy.data.no == 1, "back to 1-1")


func _test_defeat_later_stage() -> void:
	print("\n[Test 9b] Defeat on 1-2 -> retry same stage / stage select")
	manager.start_stage(1)
	await _launch_intro_done()
	_make_enemy_tough()
	manager.enemy.attack = 99999
	manager.request_roll()
	var ok := await _wait_state(BattleState.State.DEFEAT, 25.0)
	_check(ok, "DEFEAT on 1-2")
	_check(await _press_overlay(&"retry"), "press retry")
	_check(manager.stage.index == 1 and manager.enemy.data.no == 2 and manager.player.hp == manager.player.max_hp, "retry keeps 1-2 (No.2) with full HP")
	await _launch_intro_done()
	_make_enemy_tough()
	manager.enemy.attack = 99999
	manager.request_roll()
	ok = await _wait_state(BattleState.State.DEFEAT, 25.0)
	_check(ok, "DEFEAT again")
	var exits: Array = []
	manager.exit_requested.connect(func(to: StringName) -> void: exits.append(to))
	_check(await _press_overlay(&"stages"), "press 'choose a stage'")
	_check(exits == [&"stages"], "the battle asks to open the stage select")
	manager.start_stage(0)
	ok = await _launch_intro_done()
	_make_enemy_tough()
	var atk := manager.enemy.attack
	var max_hp := manager.player.max_hp
	manager.request_roll()
	ok = ok and await _wait_state(BattleState.State.PLAYER_TURN, 25.0)
	_check(ok and manager.enemy.hp < 9999 and manager.player.hp == max_hp - atk, "a full turn works after that")
