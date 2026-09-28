class_name StageData
extends Resource
## 1 ステージ分のデータ。

@export var index: int = 0
## 画面に出すステージ名（"STAGE 1" / "BOSS"）
@export var title: String = "STAGE 1"
## エリア名（イントロで表示）
@export var area_name: String = ""
@export var enemy_id: StringName = &"slime"
@export var is_boss: bool = false
## BattleField.apply_theme() に渡す見た目テーマ
@export var theme: StringName = &"day"
