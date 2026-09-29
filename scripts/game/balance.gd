class_name Balance
extends RefCounted
## ゲームバランスの数式をまとめたところ。ここを変えれば全体の強さが変わる。
##
## ■ サイコロ（かけ算でインフレ）
##   レベル 10 ごとにサイコロが 1 つ増える（Lv1〜9: 1 こ, Lv10: 2 こ, Lv20: 3 こ …）。
##   ダメージ = (1 こ目の出目のダメージ + 武器の攻撃力) × 2 こ目以降の「倍率」を全部かけたもの × レベルの攻撃力
##   出目 → ダメージ: 1:5  2:10  3:15  4:20  5:30  6:50
##   出目 → 倍率  : 1:×1 2:×2  3:×3  4:×4  5:×6  6:×10（= ダメージ ÷ 5）
##   例: 6・4・2 → 50 × 4 × 2 = 400
##
## ■ 敵の強さ
##   チャプター c のステージ s（c-s）ごとに「このくらいのレベルで挑む」という目安 design_level を決め、
##   そのレベルのプレイヤーが数ターン（TURNS）で倒せる HP、数回（HITS）でやられる攻撃力にする。
##   目安: 1-1 = Lv1 … 10-10 = Lv50.5。チャプター 10 は Lv50（サイコロ 6 こ）くらいで無いと厳しい。
##   ステージが進むとなめらかに強くなる（x-10 はボス。HP・攻撃力が高い）。
##
## ■ 経験値
##   敵をたおすと EXP。先のステージほど多い（ボスは 3 倍）。次のレベルまでの EXP は 1 レベルごとに約 1.1 倍。

const MAX_LEVEL := 99
const MAX_DICE := 10
const STAGES_PER_CHAPTER := 10
## 出目 → 倍率（2 こ目以降のサイコロ）
const MULTIPLIER := {1: 1, 2: 2, 3: 3, 4: 4, 5: 6, 6: 10}
## サイコロ 1 この倍率の平均（(1+2+3+4+6+10) / 6）
const AVERAGE_MULTIPLIER := 26.0 / 6.0
const BOSS_HP := 1.6
const BOSS_ATTACK := 1.3


## レベル → サイコロの数
static func dice_count(level: int) -> int:
	return mini(1 + level / 10, MAX_DICE)


## そのサイコロの数になるレベル（2 こ → Lv10）
static func level_for_dice(count: int) -> int:
	return (count - 1) * 10


## レベル → 攻撃力（ダメージにかける値。Lv1 = 1.0、1 レベルごとに +0.08）
static func power(level: int) -> float:
	return 1.0 + 0.08 * (level - 1)


## レベル → 最大 HP（よろいの分は別）
static func player_hp(level: int) -> int:
	return 100 + 25 * (level - 1)


## 次のレベルまでに必要な EXP
static func exp_to_next(level: int) -> int:
	return roundi(12.0 * pow(1.115, level - 1))


## ステージの通し番号（1-1 = 1 … 10-10 = 100）
static func stage_number(chapter: int, stage: int) -> int:
	return (chapter - 1) * STAGES_PER_CHAPTER + stage


## このステージに挑む目安のレベル
static func design_level(chapter: int, stage: int) -> float:
	return 5.0 * (chapter - 1) + 0.5 * (stage - 1) + 1.0


## 目安のレベルのプレイヤーの 1 ターンあたりの平均ダメージ（なめらかな曲線にしたもの）
static func expected_damage(level: float) -> float:
	return 5.0 * pow(AVERAGE_MULTIPLIER, 1.0 + (level - 5.0) / 10.0) * (1.0 + 0.08 * (level - 1.0))


## 敵を倒すのにかかる目安のターン数（最初は 2、だんだん 4 へ）
static func turns(chapter: int, stage: int) -> float:
	return 2.0 + 2.0 * minf(1.0, (stage_number(chapter, stage) - 1) / 20.0)


## 敵の攻撃で何回やられるか（最初は 20 回、だんだん 7 回へ）
static func hits(chapter: int, stage: int) -> float:
	return 20.0 - 13.0 * minf(1.0, (stage_number(chapter, stage) - 1) / 30.0)


static func enemy_hp(chapter: int, stage: int, boss: bool = false) -> int:
	var hp := turns(chapter, stage) * expected_damage(design_level(chapter, stage))
	return maxi(roundi(hp * (BOSS_HP if boss else 1.0)), 10)


static func enemy_attack(chapter: int, stage: int, boss: bool = false) -> int:
	var atk := player_hp(int(design_level(chapter, stage))) / hits(chapter, stage)
	return maxi(roundi(atk * (BOSS_ATTACK if boss else 1.0)), 1)


static func exp_reward(chapter: int, stage: int, boss: bool = false) -> int:
	return roundi(4.0 * pow(1.058, stage_number(chapter, stage)) * (3.0 if boss else 1.0))


## サイコロの目の組み合わせ → ダメージ（攻撃力をかける前）。values[0] が 1 こ目。
static func dice_damage(values: Array, damage_table: Dictionary, bonus: int = 0) -> int:
	if values.is_empty():
		return 0
	var total: int = int(damage_table.get(values[0], 0)) + bonus
	for i in range(1, values.size()):
		total *= int(MULTIPLIER.get(values[i], 1))
	return total
