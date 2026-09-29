class_name DiceDatabase
extends RefCounted
## サイコロの一覧（ダイスガチャで手に入る）。
##
## faces: Dice.FACE_NORMALS の順（上, 下, 右, 左, 手前, 奥）の 6 面の数字（1〜6）。
##        出た数字でダメージが決まる（1:5, 2:10, 3:15, 4:20, 5:30, 6:50）
## rarity: 1 = N, 2 = R, 3 = SR, 4 = SSR（EquipmentDatabase.RARITY_NAMES）
## body / number / one: サイコロの色 / 数字の色 / 1 の数字の色
## metal: 金属っぽさ（0〜1）
## icon: アイコン（assets/icons/dice/<id>.png。tools/make_dice_icons.gd で作る）

const DEFAULT_DICE := &"normal_die"

const DICE := {
	&"normal_die": {
		"name": "ふつうのサイコロ", "rarity": 1, "icon": "dice/normal_die",
		"desc": "どこにでもある、ふつうのサイコロ。",
		"faces": [1, 6, 2, 5, 3, 4],
		"body": Color(0.97, 0.95, 0.9), "number": Color(0.1, 0.1, 0.12), "one": Color(0.85, 0.1, 0.1),
	},
	&"wood_die": {
		"name": "きのサイコロ", "rarity": 1, "icon": "dice/wood_die",
		"desc": "1 は出ないけれど、6 も出ない。",
		"faces": [2, 5, 2, 5, 3, 4],
		"body": Color(0.72, 0.5, 0.3), "number": Color(0.25, 0.12, 0.05), "one": Color(0.25, 0.12, 0.05),
	},
	&"lucky_die": {
		"name": "ラッキーダイス", "rarity": 2, "icon": "dice/lucky_die",
		"desc": "6 の面が 2 つある、ちょっとお得なサイコロ。",
		"faces": [1, 6, 2, 6, 3, 4],
		"body": Color(0.45, 0.85, 0.5), "number": Color(0.05, 0.25, 0.1), "one": Color(0.85, 0.1, 0.1),
	},
	&"hilo_die": {
		"name": "ハイローダイス", "rarity": 2, "icon": "dice/hilo_die",
		"desc": "1 か 6 しか出ない。運だめし！",
		"faces": [1, 6, 1, 6, 1, 6],
		"body": Color(0.18, 0.16, 0.2), "number": Color(1.0, 0.85, 0.3), "one": Color(1.0, 0.3, 0.25),
	},
	&"silver_die": {
		"name": "ぎんのサイコロ", "rarity": 3, "icon": "dice/silver_die",
		"desc": "1 が出ない。6 の面が 2 つある。",
		"faces": [2, 6, 3, 6, 4, 5],
		"body": Color(0.82, 0.85, 0.9), "number": Color(0.15, 0.2, 0.35), "one": Color(0.15, 0.2, 0.35), "metal": 0.7,
	},
	&"flame_die": {
		"name": "ほのおのサイコロ", "rarity": 3, "icon": "dice/flame_die",
		"desc": "3 より小さい目が出ない、熱いサイコロ。",
		"faces": [3, 6, 4, 5, 5, 6],
		"body": Color(0.95, 0.4, 0.15), "number": Color(1.0, 0.95, 0.6), "one": Color(1.0, 0.95, 0.6),
	},
	&"gold_die": {
		"name": "おうごんのサイコロ", "rarity": 4, "icon": "dice/gold_die",
		"desc": "4 より小さい目が出ない。6 が 3 面もある伝説のサイコロ。",
		"faces": [4, 6, 5, 6, 5, 6],
		"body": Color(1.0, 0.78, 0.3), "number": Color(0.45, 0.2, 0.02), "one": Color(0.45, 0.2, 0.02), "metal": 0.6,
	},
	&"rainbow_die": {
		"name": "にじいろダイス", "rarity": 4, "icon": "dice/rainbow_die",
		"desc": "6 が 3 面。ふしぎな光をはなつサイコロ。",
		"faces": [3, 6, 6, 4, 5, 6],
		"body": Color(0.75, 0.6, 1.0), "number": Color(1.0, 1.0, 1.0), "one": Color(1.0, 1.0, 1.0), "metal": 0.3,
	},
}


static func get_dice(id: StringName) -> Dictionary:
	return DICE.get(id, DICE[DEFAULT_DICE])


## 面の数字をまとめた説明（例: "1 2 3 4 5 6"）。
static func faces_text(id: StringName) -> String:
	var faces: Array = (get_dice(id)["faces"] as Array).duplicate()
	faces.sort()
	return " ".join(faces.map(func(v: int) -> String: return str(v)))
