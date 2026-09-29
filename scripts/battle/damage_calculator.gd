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


## プレイヤーのサイコロ攻撃。サイコロが複数なら、2 こ目以降の倍率をかけ算する（Balance.dice_damage）。
func calculate_player_attack(roll: DiceResult, attacker: BattleActor, defender: BattleActor) -> AttackResult:
	var values: Array = roll.values if not roll.values.is_empty() else [roll.value]
	var base := Balance.dice_damage(values, dice_damage, attacker.attack_bonus)
	var is_critical := false
	for v in values:
		if critical_faces.has(v):
			is_critical = true
	var raw := float(base * attacker.attack) * attacker.power
	if is_critical:
		raw *= critical_multiplier
	var result := AttackResult.new(0, is_critical, roll.value)
	_apply_dice_abilities(roll, result)
	result.amount = maxi(roundi(raw) - defender.defense, minimum_damage)
	return result


## 敵の通常攻撃。
func calculate_enemy_attack(attacker: BattleActor, defender: BattleActor) -> AttackResult:
	var raw := attacker.attack * attacker.power * (1.0 - defender.damage_cut)
	return AttackResult.new(maxi(roundi(raw) - defender.defense, minimum_damage))


## サイコロ固有能力のフック。
## 例: Fire Dice なら 5 以上で "burn" タグ、Poison Dice なら 1 で "poison" タグ など。
func _apply_dice_abilities(roll: DiceResult, result: AttackResult) -> void:
	match roll.dice_type:
		&"normal":
			pass
		_:
			pass
