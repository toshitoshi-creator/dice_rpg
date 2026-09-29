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
## ■ ゾロ目（サイコロ 2 こ以上）
##   同じ目が k こそろうと ×2^(k-1)（2 こ ×2、3 こ ×4、4 こ ×8 …）。そろった組がいくつもあれば全部かける。
##   全部のサイコロが同じ目（オールゾロ目）ならさらに ×2。
##
## ■ クリティカル
##   6 がサイコロの数の半分以上（1 こなら 6、2 こなら 6 が 1 こ以上、3 こなら 2 こ以上…）。ダメージは変わらず、演出が派手になる。
##
## ■ 経験値
##   敵をたおすと EXP。先のステージほど多い（ボスは 3 倍）。次のレベルまでの EXP は 1 レベルごとに約 1.1 倍、
##   Lv40 をこえるとさらに 1 レベルごとに 1.12 倍ずつ上がりにくくなる。
##
## ■ ゴールド
##   敵をたおすとゴールド。1-1 の敵 1 体で 10000。先のステージほど多い。装備・サイコロの強化に使う。
##
## ■ 敵のグループ
##   1〜3 体で出てくる。グループ全体の HP・攻撃力は 1 体のときの GROUP_TOTAL 倍を、人数で分ける。
##   あふれたダメージは次の敵へ（オーバーキル）。

const MAX_LEVEL := 99
const MAX_DICE := 10
const STAGES_PER_CHAPTER := 10
## 出目 → 倍率（2 こ目以降のサイコロ）
const MULTIPLIER := {1: 1, 2: 2, 3: 3, 4: 4, 5: 6, 6: 10}
## サイコロ 1 この倍率の平均（(1+2+3+4+6+10) / 6）
const AVERAGE_MULTIPLIER := 26.0 / 6.0
const BOSS_HP := 1.4
const BOSS_ATTACK := 1.3
## サイコロ n こでの 1 回あたりの平均ダメージ（倍率とゾロ目こみ、攻撃力をかける前）。tools で計算した値
const AVERAGE_DAMAGE := [0.0, 21.7, 163.1, 828.4, 4949.2, 32484.9, 226107.0, 1638209.0, 12367775.0, 91164872.0, 722145845.0]
## グループの人数 → 1 体のときと比べた全体の HP・攻撃力（人数で分ける）
const GROUP_TOTAL := {1: 1.0, 2: 1.2, 3: 1.35}
## ボスといっしょに出てくる手下 1 体の HP・攻撃力（ボス 1 体分に対する割合）
const MINION_SHARE := 0.15
## 1-1 の敵 1 体でもらえるゴールド
const BASE_GOLD := 10000
## レベルが上がりにくくなるレベル
const SLOW_LEVEL := 40


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
	var need := 12.0 * pow(1.115, level - 1)
	if level > SLOW_LEVEL:
		need *= pow(1.12, level - SLOW_LEVEL)
	return roundi(need)


## ステージの通し番号（1-1 = 1 … 10-10 = 100）
static func stage_number(chapter: int, stage: int) -> int:
	return (chapter - 1) * STAGES_PER_CHAPTER + stage


## このステージに挑む目安のレベル
## チャプター 10 まではステージごとに +0.5、そのあと（11〜20）はレベルが上がりにくくなるのに合わせて +0.25。
## 10-10 = Lv50.5、20-10 = Lv75.5
static func design_level(chapter: int, stage: int) -> float:
	var k := stage_number(chapter, stage)
	if k <= 100:
		return 5.0 * (chapter - 1) + 0.5 * (stage - 1) + 1.0
	return 50.5 + 0.25 * (k - 100)


## 目安のレベルのプレイヤーの 1 ターンあたりの平均ダメージ（なめらかな曲線にしたもの）
static func expected_damage(level: float) -> float:
	# サイコロの数を「なめらかに」考えて、平均ダメージの表をなめらかにつなぐ
	var n := clampf(1.0 + (level - 5.0) / 10.0, 1.0, float(MAX_DICE))
	var i := mini(int(floor(n)), MAX_DICE - 1)
	var f := n - i
	var avg := exp(log(AVERAGE_DAMAGE[i]) * (1.0 - f) + log(AVERAGE_DAMAGE[i + 1]) * f)
	return avg * (1.0 + 0.08 * (level - 1.0))


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


static func gold_reward(chapter: int, stage: int, boss: bool = false) -> int:
	return roundi(BASE_GOLD * pow(1.06, stage_number(chapter, stage) - 1) * (3.0 if boss else 1.0))


## グループの人数 n のときの 1 体あたりの割合（HP・攻撃力・EXP・ゴールド）
static func group_share(n: int) -> float:
	return float(GROUP_TOTAL.get(clampi(n, 1, 3), 1.0)) / clampi(n, 1, 3)


## サイコロの目の組み合わせ → ダメージ（ゾロ目こみ、攻撃力をかける前）。values[0] が 1 こ目。
static func dice_damage(values: Array, damage_table: Dictionary, bonus: int = 0) -> int:
	if values.is_empty():
		return 0
	var total: int = int(damage_table.get(values[0], 0)) + bonus
	for i in range(1, values.size()):
		total *= int(MULTIPLIER.get(values[i], 1))
	return total * zorome_multiplier(values)


## 出目 → そろった数（2 以上のものだけ）。例: [6, 6, 2, 2, 2] → {6: 2, 2: 3}
static func zorome_groups(values: Array) -> Dictionary:
	var counts := {}
	for v in values:
		counts[v] = counts.get(v, 0) + 1
	var groups := {}
	for v in counts:
		if counts[v] >= 2:
			groups[v] = counts[v]
	return groups


## 全部同じ目か（サイコロ 2 こ以上）
static func is_all_zorome(values: Array) -> bool:
	if values.size() < 2:
		return false
	for v in values:
		if v != values[0]:
			return false
	return true


## ゾロ目の倍率（ゾロ目が無ければ 1）
static func zorome_multiplier(values: Array) -> int:
	var m := 1
	var groups := zorome_groups(values)
	for v in groups:
		m *= 1 << (groups[v] - 1)
	if is_all_zorome(values):
		m *= 2
	return m


## クリティカルか: 6 がサイコロの数の半分以上
static func is_critical(values: Array) -> bool:
	if values.is_empty():
		return false
	return values.count(6) >= ceili(values.size() / 2.0)
