class_name DiceResult
extends RefCounted
## 物理演算で停止したサイコロから読み取った結果。

var value: int
## 全部のサイコロの出目（1 こ目 = value）。サイコロが 1 こなら [value]
var values: Array[int] = []
var dice_type: StringName
## 上面の法線と真上とのドット積（1.0 に近いほど平らに止まっている）
var up_alignment: float


func _init(p_value: int, p_dice_type: StringName = &"normal", p_up_alignment: float = 1.0) -> void:
	value = p_value
	values = [p_value]
	dice_type = p_dice_type
	up_alignment = p_up_alignment


## 複数のサイコロの結果。values[0] が 1 こ目。
static func from_values(p_values: Array[int], p_dice_type: StringName = &"normal") -> DiceResult:
	var r := DiceResult.new(p_values[0] if not p_values.is_empty() else 0, p_dice_type)
	r.values = p_values.duplicate()
	return r


func is_even() -> bool:
	return value % 2 == 0


func is_odd() -> bool:
	return not is_even()
