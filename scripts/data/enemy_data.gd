class_name EnemyData
extends Resource
## 敵 1 種類分のデータ。新しい敵はここにデータを追加し、必要なら model_type を増やす。

@export var id: StringName = &"slime"
@export var display_name: String = "SLIME"
@export var max_hp: int = 100
@export var attack: int = 10
@export var defense: int = 0
@export var model_type: StringName = &"slime"
@export var body_color: Color = Color(0.3, 0.85, 0.45)
@export var model_scale: float = 1.0
## 攻撃名（「SLIME の たいあたり！」）
@export var attack_name: String = "こうげき"
## 攻撃エフェクト・ダメージ数字を出す高さと前方オフセット
@export var hit_height: float = 0.9
@export var hit_forward: float = 0.0
## 攻撃時のジャンプの高さ・プレイヤーへの踏み込み割合
@export var jump_height: float = 0.9
@export var lunge_ratio: float = 0.7
@export var is_boss: bool = false
