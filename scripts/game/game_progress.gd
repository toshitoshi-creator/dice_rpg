class_name GameProgress
extends RefCounted
## プレイヤーのデータ。
## - 1 回のぼうけん（チャプターのステージ 1 → ボス）の進行: stage_index, special_gauge など
##   ステージをクリアするたびにプレイヤーの最大 HP が上がり、各ステージ開始時に全回復する。
## - ずっと残るもの（save_path に保存）: ジェム、持っている装備・サイコロ、装備中のもの、クリアしたチャプター

const BASE_MAX_HP := 100
const MAX_HP_PER_CLEAR := 20

## スペシャルゲージ（0〜SPECIAL_MAX）。チャプター中はステージをまたいで持ち越す。
const SPECIAL_MAX := 100.0
## 敵 1 体分の HP を削りきると溜まる量（ダメージの割合に応じて溜まる）。
## 3 体 × 32 = 96 なので、チュートリアルではボス戦の始まりごろに満タンになる。
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

## 今のぼうけんのチャプター（1〜）とステージ（0 = STAGE 1）
var chapter: int = 1
var stage_index: int = 0
var gems: int = START_GEMS
## クリアしたチャプター番号
var cleared_chapters: Array[int] = []
## 装備中のもの {slot: id}（slot は EquipmentDatabase.SLOTS）
var equipped: Dictionary = _default_equipment()
## 持っている装備 {slot: [id, ...]}。「最初から」を選んでもなくならない
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


func reset() -> void:
	stage_index = 0
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


func current_stage() -> StageData:
	return StageDatabase.get_stage(stage_index, chapter)


func stage_count() -> int:
	return StageDatabase.count(chapter)


func is_final_stage() -> bool:
	return stage_index >= stage_count() - 1


## ステージ番号から決まるプレイヤーの最大 HP（再挑戦しても同じ値になる）。
func player_max_hp(index: int = stage_index) -> int:
	return BASE_MAX_HP + MAX_HP_PER_CLEAR * index


## 装備の能力（すべての部位の合計）
func attack_bonus() -> int:
	return int(EquipmentDatabase.get_item(EquipmentDatabase.SLOT_WEAPON, weapon_id).get("atk", 0))


func defense_bonus() -> int:
	return int(EquipmentDatabase.get_item(EquipmentDatabase.SLOT_SHIELD, equipped[EquipmentDatabase.SLOT_SHIELD]).get("def", 0))


func hp_bonus() -> int:
	return int(EquipmentDatabase.get_item(EquipmentDatabase.SLOT_ARMOR, equipped[EquipmentDatabase.SLOT_ARMOR]).get("hp", 0))


## 装備込みの最大 HP。
func total_max_hp(index: int = stage_index) -> int:
	return player_max_hp(index) + hp_bonus()


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


## 今のステージをクリアしたごほうび（ジェム）。はじめてチャプターをクリアしたらボーナスも。
## {"gems": もらった合計, "first_clear": bool} を返す。
func claim_stage_clear() -> Dictionary:
	var amount := BOSS_GEMS if current_stage().is_boss else STAGE_GEMS
	var first := false
	if is_final_stage() and not cleared_chapters.has(chapter):
		cleared_chapters.append(chapter)
		amount += FIRST_CLEAR_GEMS
		first = true
	add_gems(amount)
	return {"gems": amount, "first_clear": first}


func is_chapter_cleared(c: int) -> bool:
	return cleared_chapters.has(c)


## 装備を保存する（Web 版ではブラウザに保存される）。
func save() -> void:
	if save_path == "":
		return
	var cfg := ConfigFile.new()
	cfg.set_value("player", "gems", gems)
	cfg.set_value("player", "cleared_chapters", cleared_chapters)
	for slot in EquipmentDatabase.SLOTS:
		cfg.set_value("equipped", slot, String(equipped[slot]))
		cfg.set_value("owned", slot, (owned[slot] as Array).map(func(id: StringName) -> String: return String(id)))
	cfg.save(save_path)


## 保存した装備を読み込む。知らない ID は無視する。
func load_save(path: String) -> void:
	save_path = path
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return
	gems = int(cfg.get_value("player", "gems", START_GEMS))
	cleared_chapters.assign(cfg.get_value("player", "cleared_chapters", []))
	for slot in EquipmentDatabase.SLOTS:
		for id in cfg.get_value("owned", slot, []):
			if EquipmentDatabase.has_item(slot, StringName(id)) and not is_owned(slot, StringName(id)):
				(owned[slot] as Array).append(StringName(id))
		var eq := StringName(cfg.get_value("equipped", slot, ""))
		if is_owned(slot, eq):
			equipped[slot] = eq


func advance() -> void:
	stage_index = mini(stage_index + 1, stage_count() - 1)


## チャプターを最初から始める準備をする。
func start_chapter(c: int) -> void:
	chapter = c
	reset()
