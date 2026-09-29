class_name GameProgress
extends RefCounted
## 1 回のプレイ（ステージ 1 → ボス）の進行状況。
## ステージをクリアするたびにプレイヤーの最大 HP が上がり、各ステージ開始時に全回復する。

const BASE_MAX_HP := 100
const MAX_HP_PER_CLEAR := 20

## スペシャルゲージ（0〜SPECIAL_MAX）。チャプター中はステージをまたいで持ち越す。
const SPECIAL_MAX := 100.0
## 敵 1 体分の HP を削りきると溜まる量（ダメージの割合に応じて溜まる）。
## 3 体 × 32 = 96 なので、チュートリアルではボス戦の始まりごろに満タンになる。
const SPECIAL_PER_ENEMY := 32.0
## 自分の最大 HP ぶんのダメージを受けたときに溜まる量
const SPECIAL_ON_HURT := 20.0

var stage_index: int = 0
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
## 装備を保存するファイル（空なら保存しない）
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
	return StageDatabase.get_stage(stage_index)


func stage_count() -> int:
	return StageDatabase.count()


func is_final_stage() -> bool:
	return stage_index >= StageDatabase.count() - 1


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


## ステージ（0 = STAGE 1）をクリアしたごほうびを受け取る。新しく手に入った [[slot, id], ...] を返す。
func claim_stage_rewards(index: int) -> Array:
	var got := []
	for pair in EquipmentDatabase.rewards_for_stage(index):
		if not is_owned(pair[0], pair[1]):
			(owned[pair[0]] as Array).append(pair[1])
			got.append(pair)
	if not got.is_empty():
		save()
	return got


## 装備を保存する（Web 版ではブラウザに保存される）。
func save() -> void:
	if save_path == "":
		return
	var cfg := ConfigFile.new()
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
	for slot in EquipmentDatabase.SLOTS:
		for id in cfg.get_value("owned", slot, []):
			if EquipmentDatabase.has_item(slot, StringName(id)) and not is_owned(slot, StringName(id)):
				(owned[slot] as Array).append(StringName(id))
		var eq := StringName(cfg.get_value("equipped", slot, ""))
		if is_owned(slot, eq):
			equipped[slot] = eq


func advance() -> void:
	stage_index = mini(stage_index + 1, StageDatabase.count() - 1)
