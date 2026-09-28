class_name BattleCamera
extends Camera3D
## 敵・サイコロ・プレイヤーを 1 画面に収めるカメラ。
## 「寄り」と「揺れ」の簡単な演出を持つ。

const VIEW_DEFAULT := {"pos": Vector3(0, 9.6, 10.2), "target": Vector3(0, 0.3, -0.6)}
const VIEW_DICE := {"pos": Vector3(0, 7.0, 6.6), "target": Vector3(0, 0.0, -0.4)}
const VIEW_ENEMY := {"pos": Vector3(0, 7.0, 4.8), "target": Vector3(0, 0.8, -3.8)}
const VIEW_PLAYER := {"pos": Vector3(0, 8.6, 10.6), "target": Vector3(0, 0.6, 1.8)}

var _focus_pos: Vector3 = VIEW_DEFAULT["pos"]
var _focus_target: Vector3 = VIEW_DEFAULT["target"]
var _move_tween: Tween
var _trauma := 0.0
var _noise_t := 0.0


func _ready() -> void:
	fov = 52.0
	keep_aspect = Camera3D.KEEP_WIDTH
	current = true
	_apply(Vector3.ZERO)


func _process(delta: float) -> void:
	_noise_t += delta * 40.0
	var offset := Vector3.ZERO
	if _trauma > 0.0:
		var amount := _trauma * _trauma * 0.35
		offset = Vector3(sin(_noise_t * 1.3), sin(_noise_t * 1.7 + 1.0), 0) * amount
		_trauma = maxf(_trauma - delta * 2.2, 0.0)
	_apply(offset)


func _apply(offset: Vector3) -> void:
	var pos := _focus_pos + offset
	if pos.is_equal_approx(_focus_target):
		return
	look_at_from_position(pos, _focus_target + offset * 0.5, Vector3.UP)


func shake(strength: float = 0.6) -> void:
	_trauma = clampf(maxf(_trauma, strength), 0.0, 1.0)


func focus_default(duration: float = 0.6) -> void:
	_move_to(VIEW_DEFAULT, duration)


func focus_dice(duration: float = 0.5) -> void:
	_move_to(VIEW_DICE, duration)


func focus_enemy(duration: float = 0.35) -> void:
	_move_to(VIEW_ENEMY, duration)


func focus_player(duration: float = 0.35) -> void:
	_move_to(VIEW_PLAYER, duration)


func snap_default() -> void:
	if _move_tween and _move_tween.is_valid():
		_move_tween.kill()
	_focus_pos = VIEW_DEFAULT["pos"]
	_focus_target = VIEW_DEFAULT["target"]
	_trauma = 0.0
	_apply(Vector3.ZERO)


func _move_to(view: Dictionary, duration: float) -> void:
	if _move_tween and _move_tween.is_valid():
		_move_tween.kill()
	_move_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_move_tween.tween_property(self, "_focus_pos", view["pos"], duration)
	_move_tween.tween_property(self, "_focus_target", view["target"], duration)
