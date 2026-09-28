class_name GameProgress
extends RefCounted
## 1 回のプレイ（ステージ 1 → ボス）の進行状況。
## ステージをクリアするたびにプレイヤーの最大 HP が上がり、各ステージ開始時に全回復する。

const BASE_MAX_HP := 100
const MAX_HP_PER_CLEAR := 20

var stage_index: int = 0


func reset() -> void:
	stage_index = 0


func current_stage() -> StageData:
	return StageDatabase.get_stage(stage_index)


func stage_count() -> int:
	return StageDatabase.count()


func is_final_stage() -> bool:
	return stage_index >= StageDatabase.count() - 1


## ステージ番号から決まるプレイヤーの最大 HP（再挑戦しても同じ値になる）。
func player_max_hp(index: int = stage_index) -> int:
	return BASE_MAX_HP + MAX_HP_PER_CLEAR * index


func advance() -> void:
	stage_index = mini(stage_index + 1, StageDatabase.count() - 1)
