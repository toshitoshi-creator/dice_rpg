class_name GameProgress
extends RefCounted
## プレイヤーのデータ。
## - いまのぼうけん: chapter / stage_index（0 = c-1）、スペシャルゲージ
## - ずっと残るもの（save_path に保存）: レベル・経験値、ジェム、持っている装備・サイコロ、装備中のもの、
##   クリアしたステージ
## プレイヤーの強さはレベルで決まる（Balance）。各ステージの開始時に HP は全回復する。

## スペシャルゲージ（0〜SPECIAL_MAX）。ステージをまたいで持ち越す。
const SPECIAL_MAX := 100.0
## 敵 1 体分の HP を削りきると溜まる量（ダメージの割合に応じて溜まる）。3 体ほどで満タン
const SPECIAL_PER_ENEMY := 32.0
## 自分の最大 HP ぶんのダメージを受けたときに溜まる量
const SPECIAL_ON_HURT := 20.0

## 最初に持っているジェム（10 連ガチャ 1 回分）
const START_GEMS := 1000
## ステージクリアでもらえるジェム（ボスは BOSS_GEMS）
const STAGE_GEMS := 50
const BOSS_GEMS := 150
## はじめてチャプターをクリアしたときのボーナス
const FIRST_CLEAR_GEMS := 300

## いまのぼうけんのチャプター（1〜）とステージ（0 = c-1）
var chapter: int = 1
var stage_index: int = 0
var level: int = 1
## いまのレベルでためた経験値（exp_to_next() で次のレベル）
var exp_points: int = 0
var gems: int = START_GEMS
## チャプター → クリアした一番先のステージ（1〜10。10 ならチャプタークリア）
var cleared_stages: Dictionary = {}
## 装備中のもの {slot: id}（slot は EquipmentDatabase.SLOTS）
var equipped: Dictionary = _default_equipment()
## 持っている装備 {slot: [id, ...]}
var owned: Dictionary = _default_owned()
## 今装備している武器（equipped の weapon と同じ）
var weapon_id: StringName:
	get:
		return equipped[EquipmentDatabase.SLOT_WEAPON]
	set(value):
		equipped[EquipmentDatabase.SLOT_WEAPON] = value
## 今のサイコロ（equipped の dice と同じ）
var dice_id: StringName:
	get:
		return equipped[EquipmentDatabase.SLOT_DICE]
## 保存するファイル（空なら保存しない）
var save_path := ""
var special_gauge: float = 0.0
## ステージ開始時のゲージ（再挑戦のときに戻す）
var stage_start_gauge: float = 0.0


## ぼうけんを始めるときの準備（ゲージを空にする）。
func reset() -> void:
	special_gauge = 0.0
	stage_start_gauge = 0.0


static func _default_equipment() -> Dictionary:
	var d := {}
	for slot in EquipmentDatabase.SLOTS:
		d[slot] = EquipmentDatabase.default_item(slot)
	return d


static func _default_owned() -> Dictionary:
	var d := {}
	for slot in EquipmentDatabase.SLOTS:
		var ids: Array[StringName] = [EquipmentDatabase.default_item(slot)]
		d[slot] = ids
	return d


func weapon() -> Dictionary:
	return WeaponDatabase.get_weapon(weapon_id)


func dice() -> Dictionary:
	return DiceDatabase.get_dice(dice_id)


# ------------------------------------------------------------------
# スペシャルゲージ
# ------------------------------------------------------------------
func is_special_ready() -> bool:
	return special_gauge >= SPECIAL_MAX - 0.001


## 敵に dealt ダメージを与えた（enemy_max_hp はその敵の最大 HP）。
func charge_on_attack(dealt: int, enemy_max_hp: int) -> void:
	_add_special(SPECIAL_PER_ENEMY * dealt / maxf(enemy_max_hp, 1.0))


## taken ダメージを受けた。
func charge_on_hurt(taken: int, player_max: int) -> void:
	_add_special(SPECIAL_ON_HURT * taken / maxf(player_max, 1.0))


func use_special() -> void:
	special_gauge = 0.0


func _add_special(amount: float) -> void:
	special_gauge = clampf(special_gauge + amount, 0.0, SPECIAL_MAX)


# ------------------------------------------------------------------
# ステージ
# ------------------------------------------------------------------
func current_stage() -> StageData:
	return StageDatabase.get_stage(stage_index, chapter)


func stage_count() -> int:
	return StageDatabase.count(chapter)


func is_final_stage() -> bool:
	return stage_index >= stage_count() - 1


func advance() -> void:
	stage_index = mini(stage_index + 1, stage_count() - 1)


## チャプター c のステージ index（0 = c-1）から始める準備をする。
func start_stage_at(c: int, index: int = 0) -> void:
	chapter = c
	stage_index = clampi(index, 0, StageDatabase.count(c) - 1)
	reset()


## チャプターを最初から始める準備をする。
func start_chapter(c: int) -> void:
	start_stage_at(c, 0)


## チャプター c でクリアした一番先のステージ（0 = まだ）
func cleared_stage(c: int) -> int:
	return int(cleared_stages.get(c, 0))


func is_stage_cleared(c: int, stage: int) -> bool:
	return cleared_stage(c) >= stage


func is_chapter_cleared(c: int) -> bool:
	return cleared_stage(c) >= StageDatabase.count(c)


## チャプター c を遊べるか: ステージが用意されていて、ひとつ前のチャプターをクリアしていること。
func is_chapter_unlocked(c: int) -> bool:
	return StageDatabase.is_playable(c) and (c == 1 or is_chapter_cleared(c - 1))


## ステージ c-stage を遊べるか: ひとつ前のステージをクリアしていること。
func is_stage_unlocked(c: int, stage: int) -> bool:
	return is_chapter_unlocked(c) and stage <= cleared_stage(c) + 1


## 次に遊ぶとよいステージ（まだクリアしていない最初のステージ。全部クリアなら 10）
func next_stage(c: int) -> int:
	return mini(cleared_stage(c) + 1, StageDatabase.count(c))


# ------------------------------------------------------------------
# レベル
# ------------------------------------------------------------------
func dice_count() -> int:
	return Balance.dice_count(level)


func power() -> float:
	return Balance.power(level)


func exp_to_next() -> int:
	return Balance.exp_to_next(level)


## 経験値をもらう。上がったレベルの数を返す。
func add_exp(amount: int) -> int:
	var before := level
	exp_points += amount
	while level < Balance.MAX_LEVEL and exp_points >= exp_to_next():
		exp_points -= exp_to_next()
		level += 1
	if level >= Balance.MAX_LEVEL:
		exp_points = 0
	return level - before


# ------------------------------------------------------------------
# 装備の能力
# ------------------------------------------------------------------
## 武器の攻撃力（1 こ目の出目のダメージに足される）
func attack_bonus() -> int:
	return int(EquipmentDatabase.get_item(EquipmentDatabase.SLOT_WEAPON, weapon_id).get("atk", 0))


## たての「ぼうぎょ」（受けるダメージを何 % 減らすか）
func defense_bonus() -> int:
	return int(EquipmentDatabase.get_item(EquipmentDatabase.SLOT_SHIELD, equipped[EquipmentDatabase.SLOT_SHIELD]).get("def", 0))


## 受けるダメージを減らす割合（0.0〜）
func damage_cut() -> float:
	return defense_bonus() / 100.0


## よろいで増える最大 HP（%）
func hp_bonus() -> int:
	return int(EquipmentDatabase.get_item(EquipmentDatabase.SLOT_ARMOR, equipped[EquipmentDatabase.SLOT_ARMOR]).get("hp", 0))


## レベルとよろい込みの最大 HP。
func total_max_hp() -> int:
	return roundi(Balance.player_hp(level) * (1.0 + hp_bonus() / 100.0))


# ------------------------------------------------------------------
# 持ち物・ジェム
# ------------------------------------------------------------------
func is_owned(slot: StringName, id: StringName) -> bool:
	return owned.has(slot) and (owned[slot] as Array).has(id)


## 持っている装備に付けかえる。成功したら true。
func equip(slot: StringName, id: StringName) -> bool:
	if not is_owned(slot, id):
		return false
	equipped[slot] = id
	save()
	return true


## 装備・サイコロを持ち物に加える。新しく手に入ったら true（持っていたら false）。
func add_item(slot: StringName, id: StringName) -> bool:
	if not EquipmentDatabase.has_item(slot, id) or is_owned(slot, id):
		return false
	(owned[slot] as Array).append(id)
	return true


func can_spend(amount: int) -> bool:
	return gems >= amount


## ジェムを使う。足りなければ false。
func spend_gems(amount: int) -> bool:
	if gems < amount:
		return false
	gems -= amount
	save()
	return true


func add_gems(amount: int) -> void:
	gems += amount
	save()


## 今のステージをクリアしたごほうび（経験値・ジェム）を受け取り、クリアを記録する。
## {"gems", "first_clear"（はじめてチャプタークリア）, "exp", "level_before", "level", "dice_before", "dice"} を返す。
func claim_stage_clear(enemy_exp: int = -1) -> Dictionary:
	var stage := current_stage()
	var s := stage.index + 1
	var amount := BOSS_GEMS if stage.is_boss else STAGE_GEMS
	var first := false
	if stage.is_boss and not is_chapter_cleared(chapter):
		amount += FIRST_CLEAR_GEMS
		first = true
	if s > cleared_stage(chapter):
		cleared_stages[chapter] = s
	var got_exp := enemy_exp if enemy_exp >= 0 else Balance.exp_reward(chapter, s, stage.is_boss)
	var level_before := level
	var dice_before := dice_count()
	add_exp(got_exp)
	gems += amount
	save()
	return {
		"gems": amount, "first_clear": first, "exp": got_exp,
		"level_before": level_before, "level": level, "dice_before": dice_before, "dice": dice_count(),
	}


# ------------------------------------------------------------------
# セーブ
# ------------------------------------------------------------------
## 保存する（Web 版ではブラウザに保存される）。
func save() -> void:
	if save_path == "":
		return
	var cfg := ConfigFile.new()
	cfg.set_value("player", "gems", gems)
	cfg.set_value("player", "level", level)
	cfg.set_value("player", "exp", exp_points)
	for c in cleared_stages:
		cfg.set_value("cleared", str(c), cleared_stages[c])
	for slot in EquipmentDatabase.SLOTS:
		cfg.set_value("equipped", slot, String(equipped[slot]))
		cfg.set_value("owned", slot, (owned[slot] as Array).map(func(id: StringName) -> String: return String(id)))
	cfg.save(save_path)


## 保存したデータを読み込む。知らない ID は無視する。
func load_save(path: String) -> void:
	save_path = path
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return
	gems = int(cfg.get_value("player", "gems", START_GEMS))
	level = clampi(int(cfg.get_value("player", "level", 1)), 1, Balance.MAX_LEVEL)
	exp_points = maxi(int(cfg.get_value("player", "exp", 0)), 0)
	if cfg.has_section("cleared"):
		for key in cfg.get_section_keys("cleared"):
			cleared_stages[int(key)] = clampi(int(cfg.get_value("cleared", key, 0)), 0, Balance.STAGES_PER_CHAPTER)
	# 前のバージョン（チャプター単位のクリア）のデータ
	for c in cfg.get_value("player", "cleared_chapters", []):
		cleared_stages[int(c)] = Balance.STAGES_PER_CHAPTER
	for slot in EquipmentDatabase.SLOTS:
		for id in cfg.get_value("owned", slot, []):
			if EquipmentDatabase.has_item(slot, StringName(id)) and not is_owned(slot, StringName(id)):
				(owned[slot] as Array).append(StringName(id))
		var eq := StringName(cfg.get_value("equipped", slot, ""))
		if is_owned(slot, eq):
			equipped[slot] = eq
