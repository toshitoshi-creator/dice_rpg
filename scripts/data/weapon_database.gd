class_name WeaponDatabase
extends RefCounted
## 武器の一覧（そうびガチャで手に入る）。武器ごとにスペシャル技が決まる。
##
## rarity: 1 = N, 2 = R, 3 = SR, 4 = SSR
## atk: 攻撃のダメージに足される値
## icon: アイコン（assets/icons/ の中の "セット/番号"。一覧は docs/ICONS.md）
## スペシャル技は SPECIALS から "special" で選ぶ（special_name などは get_weapon() で自動的に入る）。
##
## special_type（スペシャル技の種類）:
##   &"dice_faces"    … サイコロの 6 面の数字を special_faces に変えて振る
##   &"double_damage" … 次の攻撃のダメージが special_multiplier 倍になる
##   &"heal"          … HP を最大 HP の special_heal 倍だけ回復してから、ふつうに振る
## 新しい種類を増やすときは BattleManager._activate_special() に処理を追加する。

const DEFAULT_WEAPON := &"brave_sword"

const SPECIALS := {
	&"brave_roll": {
		"special_name": "ブレイブ・ロール", "special_type": &"dice_faces",
		"special_desc": "サイコロの目が 4・5・6 だけになる！", "special_message": "サイコロが 4・5・6 だけになった！",
		# Dice.FACE_NORMALS の順（上, 下, 右, 左, 手前, 奥）
		"special_faces": [5, 4, 6, 4, 5, 6], "color": Color(1.0, 0.8, 0.3),
	},
	&"step_roll": {
		"special_name": "ステップ・ロール", "special_type": &"dice_faces",
		"special_desc": "サイコロの目が 3〜6 だけになる！", "special_message": "サイコロが 3〜6 だけになった！",
		"special_faces": [3, 6, 4, 5, 3, 6], "color": Color(0.6, 0.9, 1.0),
	},
	&"all_or_nothing": {
		"special_name": "イチかバチか", "special_type": &"dice_faces",
		"special_desc": "サイコロの目が 1 か 6 だけになる！", "special_message": "サイコロが 1 と 6 だけになった！",
		"special_faces": [6, 1, 6, 1, 6, 1], "color": Color(1.0, 0.45, 0.25),
	},
	&"flame_roll": {
		"special_name": "フレイム・ロール", "special_type": &"dice_faces",
		"special_desc": "サイコロの目が 5 か 6 だけになる！", "special_message": "サイコロが 5 と 6 だけになった！",
		"special_faces": [5, 6, 6, 5, 5, 6], "color": Color(1.0, 0.4, 0.15),
	},
	&"royal_six": {
		"special_name": "ロイヤル・シックス", "special_type": &"dice_faces",
		"special_desc": "サイコロの目が ぜんぶ 6 になる！", "special_message": "サイコロが ぜんぶ 6 になった！",
		"special_faces": [6, 6, 6, 6, 6, 6], "color": Color(1.0, 0.9, 0.45),
	},
	&"magic_boost": {
		"special_name": "マジック・ブースト", "special_type": &"double_damage",
		"special_desc": "つぎの攻撃のダメージが 2 ばいになる！", "special_message": "ダメージが 2 ばいになる！",
		"special_multiplier": 2.0, "color": Color(0.55, 0.6, 1.0),
	},
	&"angel_strike": {
		"special_name": "エンジェル・ストライク", "special_type": &"double_damage",
		"special_desc": "つぎの攻撃のダメージが 3 ばいになる！", "special_message": "ダメージが 3 ばいになる！",
		"special_multiplier": 3.0, "color": Color(1.0, 0.85, 1.0),
	},
	&"second_wind": {
		"special_name": "ひとやすみ", "special_type": &"heal",
		"special_desc": "HP を 30% かいふくしてから攻撃！", "special_message": "HP が かいふくした！",
		"special_heal": 0.3, "color": Color(0.5, 1.0, 0.55),
	},
	&"blessing": {
		"special_name": "うみのめぐみ", "special_type": &"heal",
		"special_desc": "HP を 60% かいふくしてから攻撃！", "special_message": "HP が たくさん かいふくした！",
		"special_heal": 0.6, "color": Color(0.4, 0.85, 1.0),
	},
}

## 並び順 = 装備画面での表示順
const WEAPONS := {
	# --- N ---
	&"brave_sword": {"name": "ゆうしゃのつるぎ", "rarity": 1, "icon": "swords/02", "atk": 0, "special": &"brave_roll",
		"desc": "勇者が旅立ちの日に受けついだ剣。"},
	&"copper_sword": {"name": "どうのつるぎ", "rarity": 1, "icon": "swords/01", "atk": 1, "special": &"step_roll",
		"desc": "かけだしの冒険者が使う、手ごろな剣。"},
	&"iron_spear": {"name": "てつのやり", "rarity": 1, "icon": "weapons/11", "atk": 2, "special": &"second_wind",
		"desc": "長くてあつかいやすい、鉄のやり。"},
	&"hunter_dagger": {"name": "かりゅうどのナイフ", "rarity": 1, "icon": "weapons/31", "atk": 1, "special": &"all_or_nothing",
		"desc": "小さいけれど、ねらいがするどい。"},
	# --- R ---
	&"steel_sword": {"name": "はがねのつるぎ", "rarity": 2, "icon": "swords/04", "atk": 4, "special": &"brave_roll",
		"desc": "よくきたえられた、はがねの剣。"},
	&"steel_axe": {"name": "はがねのオノ", "rarity": 2, "icon": "weapons/06", "atk": 5, "special": &"all_or_nothing",
		"desc": "重くて強い。ふりまわすには勇気がいる。"},
	&"magic_staff": {"name": "まほうのつえ", "rarity": 2, "icon": "weapons/15", "atk": 2, "special": &"magic_boost",
		"desc": "魔力をこめた杖。スペシャル技がたのもしい。"},
	&"war_hammer": {"name": "ウォーハンマー", "rarity": 2, "icon": "weapons/09", "atk": 5, "special": &"step_roll",
		"desc": "岩もくだく大きなハンマー。"},
	# --- SR ---
	&"flame_sword": {"name": "ほのおのつるぎ", "rarity": 3, "icon": "swords/09", "atk": 7, "special": &"flame_roll",
		"desc": "刃がほのおにつつまれた剣。"},
	&"ice_sword": {"name": "こおりのつるぎ", "rarity": 3, "icon": "swords/08", "atk": 6, "special": &"magic_boost",
		"desc": "つめたく青く光る、氷の剣。"},
	&"sea_trident": {"name": "うみのトライデント", "rarity": 3, "icon": "weapons/12", "atk": 7, "special": &"blessing",
		"desc": "海の神がもっていたという三つまたのやり。"},
	&"dark_axe": {"name": "やみのオノ", "rarity": 3, "icon": "weapons/08", "atk": 9, "special": &"all_or_nothing",
		"desc": "やみの力がやどる、赤黒いオノ。"},
	# --- SSR ---
	&"sun_sword": {"name": "たいようのつるぎ", "rarity": 4, "icon": "swords/40", "atk": 10, "special": &"royal_six",
		"desc": "太陽の光をあつめてきたえた伝説の剣。"},
	&"angel_sword": {"name": "てんしのつるぎ", "rarity": 4, "icon": "swords/50", "atk": 10, "special": &"angel_strike",
		"desc": "天使のはねがかざられた、きよらかな剣。"},
	&"blaze_blade": {"name": "ごうえんのけん", "rarity": 4, "icon": "weapons/50", "atk": 12, "special": &"flame_roll",
		"desc": "すべてをやきつくす、ほのおの大剣。"},
}


## 武器のデータ（スペシャル技の中身も入れて返す）。知らない ID ならデフォルトの武器。
static func get_weapon(id: StringName) -> Dictionary:
	var w: Dictionary = WEAPONS.get(id, WEAPONS[DEFAULT_WEAPON]).duplicate()
	w.merge(SPECIALS.get(w.get("special", &""), {}))
	return w
