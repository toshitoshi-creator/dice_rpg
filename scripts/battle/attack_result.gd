class_name AttackResult
extends RefCounted
## 1 回の攻撃の計算結果。演出側はこれだけを見て表示を決める。

var amount: int = 0
var is_critical: bool = false
var dice_value: int = 0
## 将来の拡張用（"fire", "poison", "heal" などの付加効果タグ）
var tags: Array[StringName] = []


func _init(p_amount: int = 0, p_critical: bool = false, p_dice_value: int = 0) -> void:
	amount = p_amount
	is_critical = p_critical
	dice_value = p_dice_value
