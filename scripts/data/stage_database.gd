class_name StageDatabase
extends RefCounted
## ステージ構成。10 チャプター × 10 ステージ（1-1 〜 10-10）。
##
## チャプター c のステージ:
##   c-1 〜 c-9 … そのチャプターの雑魚 9 体（図鑑の B+1 〜 B+9。B = (c-1)×12）
##   c-10       … ボス（図鑑の B+10）
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
	var theme: StringName = THEMES[c - 1]
	if stage.is_boss:
		theme = &"boss"
	elif theme == &"day" and s >= 7:
		theme = &"dusk"
	stage.theme = theme
	return stage


## ステージに挑む目安のレベル（整数、切り上げ）
static func recommended_level(chapter: int, stage: int) -> int:
	return ceili(Balance.design_level(chapter, stage))
