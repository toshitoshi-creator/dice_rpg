class_name EnemyData
extends Resource
## 敵 1 体分のデータ（図鑑の 1 項目）。EnemyDatabase が種族データとステータス式から作る。

## 図鑑番号（1〜120）。大きいほど強い。
@export var no: int = 1
## 一意な ID（例: &"slime_1" = スライム族の 1 色目）
@export var id: StringName = &"slime_1"
@export var species_id: StringName = &"slime"
## 色違いの番号（0, 1, 2）
@export var variant: int = 0
@export var chapter: int = 1
@export var is_boss: bool = false

@export var display_name: String = "スライム"
@export var name_en: String = "SLIME"
@export var description: String = ""
## 攻撃名（「スライムの たいあたり！」）
@export var attack_name: String = "たいあたり"

@export var max_hp: int = 40
@export var attack: int = 5
@export var defense: int = 0

## 見た目
@export var model_type: StringName = &"slime"
@export var palette: Dictionary = {}
## モデルの目標の高さ・最大の横幅（この範囲に収まるよう自動で拡大縮小される）
@export var target_height: float = 1.6
@export var max_width: float = 2.6
## 待機モーション: bounce / sway / hover / breathe / flicker
@export var idle_style: StringName = &"sway"
