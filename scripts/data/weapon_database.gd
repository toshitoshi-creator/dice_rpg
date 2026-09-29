class_name WeaponDatabase
extends RefCounted
## 武器の一覧。武器ごとにスペシャル技が決まる。
##
## atk: 攻撃のダメージに足される値
## icon: アイコン（assets/icons/ の中の "セット/番号"。一覧は docs/ICONS.md）
## unlock: 手に入る条件（-1 = 最初から持っている, 0 以上 = そのステージ（0 = STAGE 1）をクリアすると手に入る）
## special_type（スペシャル技の種類）:
##   &"dice_faces"    … サイコロの 6 面の数字を special_faces に変えて振る
##   &"double_damage" … 次の攻撃のダメージが special_multiplier 倍になる
## 新しい種類を増やすときは BattleManager._activate_special() に処理を追加する。

const DEFAULT_WEAPON := &"brave_sword"

## 並び順 = 装備画面での表示順
const WEAPONS := {
	&"brave_sword": {
		"name": "ゆうしゃのつるぎ",
		"icon": "swords/02",
		"desc": "勇者が旅立ちの日に受けついだ剣。",
		"atk": 0,
		"unlock": -1,
		"special_name": "ブレイブ・ロール",
		"special_desc": "サイコロの目が 4・5・6 だけになる！",
		"special_message": "サイコロが 4・5・6 だけになった！",
		"special_type": &"dice_faces",
		# Dice.FACE_NORMALS の順（上, 下, 右, 左, 手前, 奥）。どの面が上になっても 4〜6
		"special_faces": [5, 4, 6, 4, 5, 6],
		"color": Color(1.0, 0.8, 0.3),
	},
	&"steel_axe": {
		"name": "はがねのオノ",
		"icon": "weapons/06",
		"desc": "重くて強い。ふりまわすには勇気がいる。",
		"atk": 5,
		"unlock": 1,
		"special_name": "イチかバチか",
		"special_desc": "サイコロの目が 1 か 6 だけになる！",
		"special_message": "サイコロが 1 と 6 だけになった！",
		"special_type": &"dice_faces",
		"special_faces": [6, 1, 6, 1, 6, 1],
		"color": Color(1.0, 0.45, 0.25),
	},
	&"magic_staff": {
		"name": "まほうのつえ",
		"icon": "weapons/15",
		"desc": "魔力をこめた杖。スペシャル技がたのもしい。",
		"atk": 2,
		"unlock": 3,
		"special_name": "マジック・ブースト",
		"special_desc": "つぎの攻撃のダメージが 2 ばいになる！",
		"special_message": "ダメージが 2 ばいになる！",
		"special_type": &"double_damage",
		"special_multiplier": 2.0,
		"color": Color(0.55, 0.6, 1.0),
	},
}


static func get_weapon(id: StringName) -> Dictionary:
	return WEAPONS.get(id, WEAPONS[DEFAULT_WEAPON])
