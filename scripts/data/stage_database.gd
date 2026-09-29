class_name StageDatabase
extends RefCounted
## ステージ構成。10 チャプター × 10 ステージ（1-1 〜 10-10）。
##
## チャプター c のステージ:
##   c-1 〜 c-9 … そのチャプターの雑魚（図鑑の B+s が中心。B = (c-1)×12）と、なかまの 1〜3 体のグループ。
##                なかまはそのチャプターで出会った雑魚や、前のチャプターの強い雑魚からえらぶ（ステージごとに決まっている）
##   c-10       … ボス（図鑑の B+10）。チャプター 2 から手下がつく
## 敵 1 体ごとの HP・攻撃力・EXP・ゴールドは enemy_stats() で決まる（グループ全体で 1 体分より少し強い）。
## 強さはステージが進むほどなめらかに上がる（数式は Balance）。
## ステージの見た目（空の色）は THEMES、名前はチャプターのエリア名（scripts/enemies/chapter_XX.gd の AREA）。

const CHAPTER_COUNT := 10
const STAGES_PER_CHAPTER := Balance.STAGES_PER_CHAPTER

## チャプターの空の色（ボスステージは &"boss"）。7〜9 ステージ目は夕方にする（昼のチャプターのみ）
const THEMES := [&"day", &"day", &"day", &"night", &"night", &"day", &"dusk", &"day", &"night", &"night"]


## 遊べるチャプターの数。
static func playable_chapters() -> int:
	return CHAPTER_COUNT


## チャプター c（1〜）のステージが用意されているか（前のチャプターをクリアしたかは GameProgress で見る）。
static func is_playable(c: int) -> bool:
	return c >= 1 and c <= CHAPTER_COUNT


## チャプターの名前（エリア名。敵図鑑のチャプターと同じ）
static func chapter_name(c: int) -> String:
	var scripts := EnemyDatabase.chapter_scripts()
	if c < 1 or c > scripts.size():
		return ""
	return scripts[c - 1].AREA


static func count(_chapter: int = 1) -> int:
	return STAGES_PER_CHAPTER


## ステージ index（0 = c-1）のデータ。
static func get_stage(index: int, chapter: int = 1) -> StageData:
	var c := clampi(chapter, 1, CHAPTER_COUNT)
	var i := clampi(index, 0, STAGES_PER_CHAPTER - 1)
	var s := i + 1
	var stage := StageData.new()
	stage.index = i
	stage.chapter = c
	stage.is_boss = s == STAGES_PER_CHAPTER
	stage.title = "%d-%d" % [c, s]
	stage.area_name = chapter_name(c) + ("  BOSS" if stage.is_boss else "")
	stage.enemy_no = (c - 1) * EnemyDatabase.PER_CHAPTER + (10 if stage.is_boss else s)
	stage.enemy_nos = formation(c, s)
	var theme: StringName = THEMES[c - 1]
	if stage.is_boss:
		theme = &"boss"
	elif theme == &"day" and s >= 7:
		theme = &"dusk"
	stage.theme = theme
	return stage


## ステージ c-s に出てくる敵（図鑑番号、左から順）
static func formation(c: int, s: int) -> Array[int]:
	var base := (c - 1) * EnemyDatabase.PER_CHAPTER
	var rng := RandomNumberGenerator.new()
	rng.seed = c * 1000 + s
	var result: Array[int] = []
	if s == STAGES_PER_CHAPTER:
		var boss := base + 10
		# 手下はそのチャプターのいちばん強い色の雑魚から
		var m1 := base + 7 + rng.randi() % 3
		var m2 := base + 7 + rng.randi() % 3
		if c == 1:
			result = [boss]
		elif c == 2:
			result = [boss, m1]
		else:
			result = [m1, boss, m2]
		return result
	var lead := base + s
	var count := 1
	if c == 1:
		count = 1 if s <= 3 else (2 if s <= 6 else 3)
	else:
		count = 2 if s <= 2 else (3 if rng.randf() < 0.7 else 2)
	# なかま候補: このチャプターでもう出会った雑魚と、前のチャプターの強い雑魚
	var pool: Array[int] = []
	for i in range(1, s + 1):
		pool.append(base + i)
	if c > 1:
		var prev := base - EnemyDatabase.PER_CHAPTER
		for i in range(4, 10):
			pool.append(prev + i)
	result = [lead]
	while result.size() < count:
		var pick: int = pool[rng.randi() % pool.size()]
		# 真ん中に中心の敵が来るように、左右へ交互に置く
		if result.size() % 2 == 1:
			result.push_front(pick)
		else:
			result.push_back(pick)
	return result


## ステージの slot 番目の敵のステータス {"max_hp", "attack", "exp", "gold"}（数式は Balance）
static func enemy_stats(stage: StageData, slot: int) -> Dictionary:
	var c := stage.chapter
	var s := stage.index + 1
	var nos := stage.enemy_nos if not stage.enemy_nos.is_empty() else [stage.enemy_no]
	var n := nos.size()
	var share := Balance.group_share(n)
	var boss := false
	if stage.is_boss:
		boss = nos[slot] == stage.enemy_no
		share = 1.0 if boss else Balance.MINION_SHARE
	return {
		"max_hp": maxi(roundi(Balance.enemy_hp(c, s, stage.is_boss) * share), 5),
		"attack": maxi(roundi(Balance.enemy_attack(c, s, stage.is_boss) * share), 1),
		"exp": maxi(roundi(Balance.exp_reward(c, s, stage.is_boss) * share), 1),
		"gold": maxi(roundi(Balance.gold_reward(c, s, stage.is_boss) * share), 1),
	}


## ステージに挑む目安のレベル（整数、切り上げ）
static func recommended_level(chapter: int, stage: int) -> int:
	return ceili(Balance.design_level(chapter, stage))
