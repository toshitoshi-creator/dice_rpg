class_name EquipmentDatabase
extends RefCounted
## 装備の一覧（ぶき・たて・よろい）。武器の中身は WeaponDatabase にある。
##
## たて: def = 受けるダメージを減らす値 / よろい: hp = 最大 HP に足される値
## unlock: -1 = 最初から持っている, 0 以上 = そのステージ（0 = STAGE 1）をクリアすると手に入る

const SLOT_WEAPON := &"weapon"
const SLOT_SHIELD := &"shield"
const SLOT_ARMOR := &"armor"
const SLOTS: Array[StringName] = [SLOT_WEAPON, SLOT_SHIELD, SLOT_ARMOR]
const SLOT_NAMES := {SLOT_WEAPON: "ぶき", SLOT_SHIELD: "たて", SLOT_ARMOR: "よろい"}

const SHIELDS := {
	&"trainee_shield": {"name": "みならいのたて", "desc": "旅立ちのときに持たされた小さな盾。", "def": 0, "unlock": -1},
	&"steel_shield": {"name": "はがねのたて", "desc": "かたい鋼の盾。敵の攻撃を少しふせぐ。", "def": 2, "unlock": 0},
	&"hero_shield": {"name": "ゆうしゃのたて", "desc": "金の鳥の紋章がきざまれた伝説の盾。", "def": 4, "unlock": 3},
}

const ARMORS := {
	&"travel_clothes": {"name": "たびびとのふく", "desc": "動きやすい青い服。", "hp": 0, "unlock": -1},
	&"chain_mail": {"name": "くさりかたびら", "desc": "鎖を編んだよろい。体力が上がる。", "hp": 30, "unlock": 2},
	&"hero_armor": {"name": "ゆうしゃのよろい", "desc": "勇者だけが着られる光のよろい。", "hp": 60, "unlock": 3},
}


static func _table(slot: StringName) -> Dictionary:
	match slot:
		SLOT_WEAPON:
			return WeaponDatabase.WEAPONS
		SLOT_SHIELD:
			return SHIELDS
		SLOT_ARMOR:
			return ARMORS
	return {}


## その部位の装備 ID（表示順）。
static func items(slot: StringName) -> Array[StringName]:
	var ids: Array[StringName] = []
	for id in _table(slot):
		ids.append(id)
	return ids


static func has_item(slot: StringName, id: StringName) -> bool:
	return _table(slot).has(id)


static func get_item(slot: StringName, id: StringName) -> Dictionary:
	return _table(slot).get(id, {})


## 最初から装備しているもの。
static func default_item(slot: StringName) -> StringName:
	for id in items(slot):
		if int(get_item(slot, id).get("unlock", -1)) < 0:
			return id
	return items(slot)[0]


## ステージ（0 = STAGE 1）をクリアしたときに手に入る装備 [[slot, id], ...]。
static func rewards_for_stage(stage_index: int) -> Array:
	var result := []
	for slot in SLOTS:
		for id in items(slot):
			if int(get_item(slot, id).get("unlock", -1)) == stage_index:
				result.append([slot, id])
	return result


## 手に入れ方の説明（まだ持っていない装備に表示する）。
static func unlock_text(slot: StringName, id: StringName) -> String:
	var index := int(get_item(slot, id).get("unlock", -1))
	if index < 0:
		return ""
	if index >= StageDatabase.count() - 1:
		return "ボスをたおすと てにはいる"
	return "ステージ %d をクリアすると てにはいる" % (index + 1)


## 能力を短く表した文字列（例: "こうげき +5"）。
static func stat_text(slot: StringName, id: StringName) -> String:
	var item := get_item(slot, id)
	match slot:
		SLOT_WEAPON:
			return "こうげき +%d" % int(item.get("atk", 0))
		SLOT_SHIELD:
			return "ぼうぎょ +%d" % int(item.get("def", 0))
		SLOT_ARMOR:
			return "最大HP +%d" % int(item.get("hp", 0))
	return ""
