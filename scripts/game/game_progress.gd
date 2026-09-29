class_name GameProgress
extends RefCounted
## 1 回のプレイ（ステージ 1 → ボス）の進行状況。
## ステージをクリアするたびにプレイヤーの最大 HP が上がり、各ステージ開始時に全回復する。

const BASE_MAX_HP := 100
const MAX_HP_PER_CLEAR := 20

## スペシャルゲージ（0〜SPECIAL_MAX）。チャプター中はステージをまたいで持ち越す。
const SPECIAL_MAX := 100.0
## 敵 1 体分の HP を削りきると溜まる量（ダメージの割合に応じて溜まる）。
## 3 体 × 32 = 96 なので、チュートリアルではボス戦の始まりごろに満タンになる。
const SPECIAL_PER_ENEMY := 32.0
## 自分の最大 HP ぶんのダメージを受けたときに溜まる量
const SPECIAL_ON_HURT := 20.0

var stage_index: int = 0
var weapon_id: StringName = WeaponDatabase.DEFAULT_WEAPON
var special_gauge: float = 0.0
## ステージ開始時のゲージ（再挑戦のときに戻す）
var stage_start_gauge: float = 0.0


func reset() -> void:
	stage_index = 0
	special_gauge = 0.0
	stage_start_gauge = 0.0


func weapon() -> Dictionary:
	return WeaponDatabase.get_weapon(weapon_id)


func is_special_ready() -> bool:
	return special_gauge >= SPECIAL_MAX - 0.001


## 敵に dealt ダメージを与えた（enemy_max_hp はその敵の最大 HP）。
func charge_on_attack(dealt: int, enemy_max_hp: int) -> void:
	_add_special(SPECIAL_PER_ENEMY * dealt / maxf(enemy_max_hp, 1.0))


## taken ダメージを受けた。
func charge_on_hurt(taken: int, player_max: int) -> void:
	_add_special(SPECIAL_ON_HURT * taken / maxf(player_max, 1.0))


func use_special() -> void:
	special_gauge = 0.0


func _add_special(amount: float) -> void:
	special_gauge = clampf(special_gauge + amount, 0.0, SPECIAL_MAX)


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
