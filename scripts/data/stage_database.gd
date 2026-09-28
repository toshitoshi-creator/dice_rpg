class_name StageDatabase
extends RefCounted
## ステージ構成。3 ステージで雑魚敵と戦い、4 ステージ目でボスと戦う。
## ステージを増やす・順番を変える場合はここを編集する。

const STAGES := [
	{"title": "STAGE 1", "area_name": "はじまりの草原", "enemy_id": &"slime", "theme": &"day"},
	{"title": "STAGE 2", "area_name": "ゴブリンの森", "enemy_id": &"goblin", "theme": &"dusk"},
	{"title": "STAGE 3", "area_name": "がいこつの墓場", "enemy_id": &"skeleton", "theme": &"night"},
	{"title": "BOSS", "area_name": "竜の玉座", "enemy_id": &"dragon", "theme": &"boss", "is_boss": true},
]


static func count() -> int:
	return STAGES.size()


static func get_stage(index: int) -> StageData:
	var i := clampi(index, 0, STAGES.size() - 1)
	var entry: Dictionary = STAGES[i]
	var stage := StageData.new()
	stage.index = i
	for prop in entry:
		stage.set(prop, entry[prop])
	return stage
