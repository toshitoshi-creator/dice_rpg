class_name Gacha
extends RefCounted
## ガチャ（そうびガチャ・ダイスガチャ）。ジェムを使って装備やサイコロを引く。
##
## - レア度の確率: RATES（N 60% / R 30% / SR 8% / SSR 2%）
## - 10 連は SR 以上が 1 つ確定（10 個目が R 以下なら SR 以上に引き直す）
## - すでに持っているものが出たら、レア度に応じたジェムに変わる（DUPLICATE_GEMS）

const BANNER_EQUIPMENT := &"equipment"
const BANNER_DICE := &"dice"

const BANNERS := {
	BANNER_EQUIPMENT: {
		"name": "そうびガチャ",
		"desc": "ぶき・たて・よろいが出る！",
		"slots": [EquipmentDatabase.SLOT_WEAPON, EquipmentDatabase.SLOT_SHIELD, EquipmentDatabase.SLOT_ARMOR],
	},
	BANNER_DICE: {
		"name": "ダイスガチャ",
		"desc": "いろいろなサイコロが出る！",
		"slots": [EquipmentDatabase.SLOT_DICE],
	},
}

const SINGLE_COST := 100
const TEN_COST := 900
## レア度 → 確率（合計 1.0）
const RATES := {1: 0.6, 2: 0.3, 3: 0.08, 4: 0.02}
## かぶったときにもらえるジェム
const DUPLICATE_GEMS := {1: 10, 2: 30, 3: 100, 4: 300}

var rng := RandomNumberGenerator.new()


func _init() -> void:
	rng.randomize()


## バナーから出るもの [[slot, id], ...]（rarity を指定するとそのレア度だけ。最初から持っている装備はのぞく）。
static func pool(banner: StringName, rarity: int = 0) -> Array:
	var result := []
	for slot in BANNERS[banner]["slots"]:
		for id in EquipmentDatabase.items(slot):
			# 最初から持っている装備は出ない
			if EquipmentDatabase.STARTER.get(slot) == id:
				continue
			if rarity == 0 or EquipmentDatabase.rarity(slot, id) == rarity:
				result.append([slot, id])
	return result


static func cost(count: int) -> int:
	return TEN_COST if count >= 10 else SINGLE_COST * count


## 確率表の文字列（画面に出す用）
static func rates_text() -> String:
	var parts := []
	for r in [4, 3, 2, 1]:
		parts.append("%s %d%%" % [EquipmentDatabase.RARITY_NAMES[r], roundi(RATES[r] * 100.0)])
	return " / ".join(parts)


func _roll_rarity(min_rarity: int = 1) -> int:
	var x := rng.randf()
	var acc := 0.0
	for r in [4, 3, 2, 1]:
		acc += RATES[r]
		if x < acc:
			return maxi(r, min_rarity)
	return maxi(1, min_rarity)


## 1 回分を引く（ジェムは使わない）。{"slot", "id", "rarity"}
func draw_one(banner: StringName, min_rarity: int = 1) -> Dictionary:
	var r := _roll_rarity(min_rarity)
	var candidates := pool(banner, r)
	while candidates.is_empty() and r > 1:
		r -= 1
		candidates = pool(banner, r)
	var pick: Array = candidates[rng.randi() % candidates.size()]
	return {"slot": pick[0], "id": pick[1], "rarity": r}


## count 回（1 か 10）引いて持ち物に入れる。ジェムが足りなければ空の配列。
## 結果: [{"slot", "id", "rarity", "new": bool, "gems": かぶりでもらったジェム}, ...]
func pull(progress: GameProgress, banner: StringName, count: int) -> Array:
	if not progress.spend_gems(cost(count)):
		return []
	var results := []
	for i in count:
		var guaranteed := count >= 10 and i == count - 1 and results.all(func(d: Dictionary) -> bool: return d["rarity"] < 3)
		var d := draw_one(banner, 3 if guaranteed else 1)
		d["new"] = progress.add_item(d["slot"], d["id"])
		d["gems"] = 0 if d["new"] else DUPLICATE_GEMS[d["rarity"]]
		results.append(d)
	var refund := 0
	for d in results:
		refund += d["gems"]
	progress.add_gems(refund)
	return results
