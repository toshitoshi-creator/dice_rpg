class_name DamageCalculator
extends RefCounted
## ダメージ計算。数値はすべてここにまとめ、後から簡単に調整できるようにする。

## 出目 → 基礎ダメージ
var dice_damage := {
	1: 5,
	2: 10,
	3: 15,
	4: 20,
	5: 30,
	6: 50,
}

## クリティカルになる出目
var critical_faces: Array[int] = [6]
## クリティカル時の倍率（6 = 50 ダメージのまま演出だけ付けたい場合は 1.0）
var critical_multiplier: float = 1.0
## 防御力でダメージが 0 にならないようにする最低値
var minimum_damage: int = 1


## プレイヤーのサイコロ攻撃。
func calculate_player_attack(roll: DiceResult, attacker: BattleActor, defender: BattleActor) -> AttackResult:
	var base: int = dice_damage.get(roll.value, 0)
	var is_critical := critical_faces.has(roll.value)
	var raw := float(base * attacker.attack)
	if is_critical:
		raw *= critical_multiplier
	var result := AttackResult.new(0, is_critical, roll.value)
	_apply_dice_abilities(roll, result)
	result.amount = maxi(roundi(raw) - defender.defense, minimum_damage)
	return result


## 敵の通常攻撃。
func calculate_enemy_attack(attacker: BattleActor, defender: BattleActor) -> AttackResult:
	return AttackResult.new(maxi(attacker.attack - defender.defense, minimum_damage))


## サイコロ固有能力のフック。
## 例: Fire Dice なら 5 以上で "burn" タグ、Poison Dice なら 1 で "poison" タグ など。
func _apply_dice_abilities(roll: DiceResult, result: AttackResult) -> void:
	match roll.dice_type:
		&"normal":
			pass
		_:
			pass
