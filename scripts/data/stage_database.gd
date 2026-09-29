class_name StageDatabase
extends RefCounted
## ステージ構成。
## チャプター 1「はじまりの草原」はチュートリアル: 図鑑の No.1〜3（いちばん弱い雑魚）と
## ボスの中でいちばん弱い No.10 スライムキングと戦う。
## 今後チャプターを増やすときは、CHAPTERS に同じ形でステージを追加する
## （そのチャプターの敵は EnemyDatabase.chapter_enemies(c) で取得できる）。

const CHAPTERS := [
	{
		"title": "CHAPTER 1",
		"stages": [
			{"title": "STAGE 1", "area_name": "はじまりの草原", "enemy_no": 1, "theme": &"day"},
			{"title": "STAGE 2", "area_name": "キノコの小道", "enemy_no": 2, "theme": &"day"},
			{"title": "STAGE 3", "area_name": "花畑の丘", "enemy_no": 3, "theme": &"dusk"},
			{"title": "BOSS", "area_name": "スライムの王座", "enemy_no": 10, "theme": &"boss", "is_boss": true},
		],
	},
]

## 遊べるチャプターの数（CHAPTERS に書いてある分）。それ以降は「じゅんびちゅう」
static func playable_chapters() -> int:
	return CHAPTERS.size()


## チャプター c（1〜）のステージが用意されているか（前のチャプターをクリアしたかは GameProgress で見る）。
static func is_playable(c: int) -> bool:
	return c >= 1 and c <= CHAPTERS.size()


## チャプターの名前（エリア名。敵図鑑のチャプターと同じ）
static func chapter_name(c: int) -> String:
	var scripts := EnemyDatabase.chapter_scripts()
	if c < 1 or c > scripts.size():
		return ""
	return scripts[c - 1].AREA


static func _stages(chapter: int) -> Array:
	return CHAPTERS[clampi(chapter - 1, 0, CHAPTERS.size() - 1)]["stages"]


static func count(chapter: int = 1) -> int:
	return _stages(chapter).size()


static func get_stage(index: int, chapter: int = 1) -> StageData:
	var stages := _stages(chapter)
	var i := clampi(index, 0, stages.size() - 1)
	var entry: Dictionary = stages[i]
	var stage := StageData.new()
	stage.index = i
	stage.chapter = clampi(chapter, 1, CHAPTERS.size())
	for prop in entry:
		stage.set(prop, entry[prop])
	return stage
