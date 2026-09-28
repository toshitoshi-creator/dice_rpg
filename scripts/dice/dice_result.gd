class_name DiceResult
extends RefCounted
## 物理演算で停止したサイコロから読み取った結果。

var value: int
var dice_type: StringName
## 上面の法線と真上とのドット積（1.0 に近いほど平らに止まっている）
var up_alignment: float


func _init(p_value: int, p_dice_type: StringName = &"normal", p_up_alignment: float = 1.0) -> void:
	value = p_value
	dice_type = p_dice_type
	up_alignment = p_up_alignment


func is_even() -> bool:
	return value % 2 == 0


func is_odd() -> bool:
	return not is_even()
