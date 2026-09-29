class_name EquipmentDatabase
extends RefCounted
## 装備の一覧（ぶき・たて・よろい・ダイス）。ガチャで手に入る。
## 武器の中身は WeaponDatabase、サイコロの中身は DiceDatabase にある。
##
## たて: def = 受けるダメージを減らす値 / よろい: hp = 最大 HP に足される値
## rarity: 1 = N, 2 = R, 3 = SR, 4 = SSR
## icon: アイコン（assets/icons/ の中の "セット/番号"。セットは weapons / swords / armors / shields、番号は 01〜50）

const SLOT_WEAPON := &"weapon"
const SLOT_SHIELD := &"shield"
const SLOT_ARMOR := &"armor"
const SLOT_DICE := &"dice"
const SLOTS: Array[StringName] = [SLOT_WEAPON, SLOT_SHIELD, SLOT_ARMOR, SLOT_DICE]
const SLOT_NAMES := {SLOT_WEAPON: "ぶき", SLOT_SHIELD: "たて", SLOT_ARMOR: "よろい", SLOT_DICE: "ダイス"}

const RARITY_NAMES := {1: "N", 2: "R", 3: "SR", 4: "SSR"}
const RARITY_COLORS := {
	1: Color(0.75, 0.75, 0.8),
	2: Color(0.35, 0.65, 1.0),
	3: Color(0.8, 0.45, 1.0),
	4: Color(1.0, 0.8, 0.25),
}

const ICON_DIR := "res://assets/icons/"
## アイコンのセットと枚数（art/icon_sheets/ の元画像から tools/slice_icon_sheet.py で作ったもの）
const ICON_SETS := {&"weapons": 50, &"swords": 50, &"armors": 50, &"shields": 50}

## 最初から持っている装備
const STARTER := {
	SLOT_WEAPON: &"brave_sword",
	SLOT_SHIELD: &"trainee_shield",
	SLOT_ARMOR: &"travel_clothes",
	SLOT_DICE: &"normal_die",
}

const SHIELDS := {
	&"trainee_shield": {"name": "みならいのたて", "rarity": 1, "icon": "shields/01", "def": 0, "desc": "旅立ちのときに持たされた小さな盾。"},
	&"wood_shield": {"name": "きのたて", "rarity": 1, "icon": "shields/15", "def": 1, "desc": "木の板を鉄でとめた、じょうぶな盾。"},
	&"iron_shield": {"name": "てつのたて", "rarity": 1, "icon": "shields/07", "def": 1, "desc": "鉄のわくで守られた盾。"},
	&"steel_shield": {"name": "はがねのたて", "rarity": 2, "icon": "shields/03", "def": 2, "desc": "かたい鋼の盾。敵の攻撃を少しふせぐ。"},
	&"star_shield": {"name": "ほしのたて", "rarity": 2, "icon": "shields/06", "def": 2, "desc": "星の紋章がかがやく丸い盾。"},
	&"lion_shield": {"name": "しし王のたて", "rarity": 3, "icon": "shields/20", "def": 3, "desc": "ライオンの顔がきざまれた、王の盾。"},
	&"frost_shield": {"name": "こおりのたて", "rarity": 3, "icon": "shields/19", "def": 4, "desc": "とけない氷でできた盾。"},
	&"hero_shield": {"name": "ゆうしゃのたて", "rarity": 4, "icon": "shields/02", "def": 5, "desc": "金の鳥の紋章がきざまれた伝説の盾。"},
	&"angel_shield": {"name": "てんしのたて", "rarity": 4, "icon": "shields/17", "def": 6, "desc": "天使のはねが守ってくれる聖なる盾。"},
}

const ARMORS := {
	&"travel_clothes": {"name": "たびびとのふく", "rarity": 1, "icon": "armors/01", "hp": 0, "desc": "動きやすい旅の服。"},
	&"leather_armor": {"name": "かわのよろい", "rarity": 1, "icon": "armors/45", "hp": 10, "desc": "なめした革のよろい。"},
	&"forest_cloak": {"name": "もりのマント", "rarity": 1, "icon": "armors/05", "hp": 10, "desc": "森のかりゅうどが着る、みどりのマント。"},
	&"chain_mail": {"name": "くさりかたびら", "rarity": 2, "icon": "armors/21", "hp": 25, "desc": "鎖を編んだよろい。体力が上がる。"},
	&"knight_armor": {"name": "きしのよろい", "rarity": 2, "icon": "armors/10", "hp": 30, "desc": "青いマントの騎士のよろい。"},
	&"flame_armor": {"name": "ほのおのよろい", "rarity": 3, "icon": "armors/09", "hp": 50, "desc": "ほのおの力がやどる赤いよろい。"},
	&"frost_armor": {"name": "こおりのよろい", "rarity": 3, "icon": "armors/15", "hp": 50, "desc": "氷のけっしょうでできたよろい。"},
	&"hero_armor": {"name": "ゆうしゃのよろい", "rarity": 4, "icon": "armors/07", "hp": 80, "desc": "勇者だけが着られる光のよろい。"},
	&"holy_armor": {"name": "せいなるよろい", "rarity": 4, "icon": "armors/19", "hp": 90, "desc": "金色にかがやく聖なるよろい。"},
}


static func _table(slot: StringName) -> Dictionary:
	match slot:
		SLOT_WEAPON:
			return WeaponDatabase.WEAPONS
		SLOT_SHIELD:
			return SHIELDS
		SLOT_ARMOR:
			return ARMORS
		SLOT_DICE:
			return DiceDatabase.DICE
	return {}


## その部位の装備 ID（表示順）。
static func items(slot: StringName) -> Array[StringName]:
	var ids: Array[StringName] = []
	for id in _table(slot):
		ids.append(id)
	return ids


static func has_item(slot: StringName, id: StringName) -> bool:
	return _table(slot).has(id)


## 装備のデータ。武器はスペシャル技の中身も入る。
static func get_item(slot: StringName, id: StringName) -> Dictionary:
	if slot == SLOT_WEAPON and WeaponDatabase.WEAPONS.has(id):
		return WeaponDatabase.get_weapon(id)
	return _table(slot).get(id, {})


static func rarity(slot: StringName, id: StringName) -> int:
	return int(get_item(slot, id).get("rarity", 1))


## 最初から装備しているもの。
static func default_item(slot: StringName) -> StringName:
	return STARTER.get(slot, items(slot)[0])


## アイコン画像のパス（例: icon_path(&"swords", 2) → res://assets/icons/swords/02.png）。
static func icon_path(icon_set: StringName, number: int) -> String:
	return "%s%s/%02d.png" % [ICON_DIR, icon_set, number]


## 装備のアイコン。未設定・ファイルが無いときは null。
static func get_icon(slot: StringName, id: StringName) -> Texture2D:
	var icon := String(get_item(slot, id).get("icon", ""))
	var path := ICON_DIR + icon + ".png"
	if icon == "" or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


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
		SLOT_DICE:
			return "め: %s" % DiceDatabase.faces_text(id)
	return ""
