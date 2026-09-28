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

## 現在遊べるチャプター
const CURRENT_CHAPTER := 0
const STAGES: Array = CHAPTERS[CURRENT_CHAPTER]["stages"]


static func count() -> int:
	return STAGES.size()


static func get_stage(index: int) -> StageData:
	var i := clampi(index, 0, STAGES.size() - 1)
	var entry: Dictionary = STAGES[i]
	var stage := StageData.new()
	stage.index = i
	stage.chapter = CURRENT_CHAPTER + 1
	for prop in entry:
		stage.set(prop, entry[prop])
	return stage
