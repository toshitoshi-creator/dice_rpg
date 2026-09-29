class_name WeaponDatabase
extends RefCounted
## 武器の一覧。武器ごとにスペシャル技が決まる。
##
## special_type（スペシャル技の種類）:
##   &"dice_faces" … サイコロの 6 面の数字を special_faces に変えて振る
## 新しい種類を増やすときは BattleManager._activate_special() に処理を追加する。

const DEFAULT_WEAPON := &"brave_sword"

const WEAPONS := {
	&"brave_sword": {
		"name": "ゆうしゃのつるぎ",
		"special_name": "ブレイブ・ロール",
		"special_desc": "サイコロの目が 4・5・6 だけになる！",
		"special_type": &"dice_faces",
		# Dice.FACE_NORMALS の順（上, 下, 右, 左, 手前, 奥）。どの面が上になっても 4〜6
		"special_faces": [5, 4, 6, 4, 5, 6],
		"color": Color(1.0, 0.8, 0.3),
	},
}


static func get_weapon(id: StringName) -> Dictionary:
	return WEAPONS.get(id, WEAPONS[DEFAULT_WEAPON])
