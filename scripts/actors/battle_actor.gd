class_name BattleActor
extends Node3D
## プレイヤー・敵の共通基底クラス。
## ステータス・HP 管理と、汎用アニメーション（被弾・攻撃・撃破）を持つ。
## 見た目は派生クラスの _build_model() で作る。

signal hp_changed(current: int, maximum: int)
signal died

@export var display_name: String = "ACTOR"
@export var max_hp: int = 100
@export var attack: int = 1
@export var defense: int = 0
## 攻撃時に飛び跳ねる高さ
@export var attack_jump_height: float = 0.0

var hp: int = 100
var model: Node3D

var _materials: Array[StandardMaterial3D] = []
## マテリアルの元の発光・透明度（フラッシュ・フェード後に戻すため）
var _material_bases: Dictionary = {}
var _flash_tween: Tween
var _idle_tween: Tween
var _home_position := Vector3.ZERO


func _ready() -> void:
	hp = clampi(hp, 0, max_hp)
	model = Node3D.new()
	model.name = "Model"
	add_child(model)
	_build_model()
	_capture_material_bases()
	_home_position = position
	start_idle()


## ステータスを初期化する（add_child 前に呼ぶ）。
func setup_stats(p_name: String, p_max_hp: int, p_attack: int, p_defense: int) -> void:
	display_name = p_name
	max_hp = p_max_hp
	hp = p_max_hp
	attack = p_attack
	defense = p_defense


func is_dead() -> bool:
	return hp <= 0


func take_damage(amount: int) -> int:
	if is_dead():
		return 0
	hp = maxi(hp - amount, 0)
	hp_changed.emit(hp, max_hp)
	if hp == 0:
		died.emit()
	return amount


func heal(amount: int) -> int:
	if is_dead():
		return 0
	var before := hp
	hp = mini(hp + amount, max_hp)
	hp_changed.emit(hp, max_hp)
	return hp - before


## 攻撃演出で狙う位置（頭上付近）。
func get_hit_point() -> Vector3:
	return global_position + Vector3(0, 1.0, 0)


# ------------------------------------------------------------------
# モデル構築ヘルパー
# ------------------------------------------------------------------
func _build_model() -> void:
	pass


func _make_material(color: Color, roughness: float = 0.6, metallic: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	_materials.append(mat)
	return mat


func _add_mesh(mesh: Mesh, mat: Material, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO, parent: Node3D = null) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot_deg
	(parent if parent else model).add_child(mi)
	return mi


# ------------------------------------------------------------------
# アニメーション
# ------------------------------------------------------------------
func start_idle() -> void:
	stop_idle()
	if is_dead():
		return
	_idle_tween = _create_idle_tween()


func stop_idle() -> void:
	if _idle_tween and _idle_tween.is_valid():
		_idle_tween.kill()
	_idle_tween = null
	if model:
		model.position = Vector3.ZERO
		model.scale = Vector3.ONE
		model.rotation = Vector3.ZERO


## 派生クラスで待機モーションの Tween を返す（ループ）。
func _create_idle_tween() -> Tween:
	return null


## 派生クラスで攻撃時の追加モーション（剣を振る等）を行う。
func _on_strike(_duration: float) -> void:
	pass


func _capture_material_bases() -> void:
	_material_bases.clear()
	for mat in _materials:
		_material_bases[mat] = {
			"enabled": mat.emission_enabled,
			"emission": mat.emission,
			"energy": mat.emission_energy_multiplier if mat.emission_enabled else 0.0,
			"alpha": mat.albedo_color.a,
			"transparency": mat.transparency,
		}


## 白く光らせる（光る目などの元の発光は最後に元に戻す）。
func flash(color: Color = Color.WHITE, duration: float = 0.3) -> void:
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	for mat in _materials:
		mat.emission_enabled = true
	_flash_tween = create_tween()
	_flash_tween.tween_method(_apply_flash.bind(color), 1.0, 0.0, duration)
	_flash_tween.tween_callback(_restore_emission)


func _apply_flash(amount: float, color: Color) -> void:
	for mat in _materials:
		var base: Dictionary = _material_bases.get(mat, {"emission": Color.BLACK, "energy": 0.0})
		mat.emission = (base["emission"] as Color).lerp(color, amount)
		mat.emission_energy_multiplier = lerpf(base["energy"], 3.0, amount)


func _restore_emission() -> void:
	for mat in _materials:
		if _material_bases.has(mat):
			var base: Dictionary = _material_bases[mat]
			mat.emission_enabled = base["enabled"]
			mat.emission = base["emission"]
			mat.emission_energy_multiplier = base["energy"] if base["enabled"] else 1.0


## 攻撃：少し溜めてから target に向かって踏み込む。踏み込み完了（命中の瞬間）で戻る。
func lunge_to(target: Vector3, distance_ratio: float = 0.55) -> void:
	stop_idle()
	var dir := target - _home_position
	dir.y = 0.0
	var windup_pos := _home_position - dir.normalized() * 0.35
	var strike_pos := _home_position + dir * distance_ratio
	var t := create_tween()
	t.tween_property(self, "position", windup_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(model, "scale", Vector3(1.1, 0.88, 1.1), 0.2)
	t.tween_callback(_on_strike.bind(0.16))
	t.tween_property(self, "position", strike_pos, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(model, "scale", Vector3(0.92, 1.12, 0.92), 0.16)
	if attack_jump_height > 0.0:
		t.parallel().tween_property(model, "position:y", attack_jump_height, 0.08).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(model, "position:y", 0.0, 0.08).set_delay(0.08).set_ease(Tween.EASE_IN)
	await t.finished


## その場で歩く（前に進む演出用。地面のほうがスクロールする）。1 歩ごとに on_step を呼ぶ。
func play_walk(duration: float, on_step: Callable = Callable()) -> void:
	stop_idle()
	var step_time := 0.32
	var steps := maxi(int(duration / step_time), 1)
	var half := duration / steps * 0.5
	var t := create_tween()
	for i in steps:
		var tilt := 4.0 if i % 2 == 0 else -4.0
		t.tween_property(model, "position:y", 0.12, half).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(model, "rotation_degrees:z", tilt, half)
		t.tween_property(model, "position:y", 0.0, half).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		if on_step.is_valid():
			t.tween_callback(on_step)
	t.tween_property(model, "rotation_degrees:z", 0.0, 0.1)
	await t.finished
	if not is_dead():
		start_idle()


func return_home() -> void:
	var t := create_tween()
	t.tween_property(self, "position", _home_position, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(model, "scale", Vector3.ONE, 0.3)
	await t.finished
	if not is_dead():
		start_idle()


## 被弾：光って後ろにのけぞる。
func play_hit(knock_direction: Vector3, strength: float = 0.5) -> void:
	stop_idle()
	flash()
	var dir := knock_direction
	dir.y = 0.0
	dir = dir.normalized()
	var t := create_tween()
	t.tween_property(self, "position", _home_position + dir * strength, 0.08).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(model, "scale", Vector3(1.2, 0.8, 1.2), 0.08)
	t.tween_property(self, "position", _home_position, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(model, "scale", Vector3.ONE, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	await t.finished
	if not is_dead():
		start_idle()


## 撃破：吹き飛んで倒れ、フェードアウトする。
func play_death(away_direction: Vector3) -> void:
	stop_idle()
	var dir := away_direction
	dir.y = 0.0
	dir = dir.normalized()
	for mat in _materials:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var fall_angle := signf(dir.z) * deg_to_rad(80.0)
	if is_zero_approx(fall_angle):
		fall_angle = deg_to_rad(80.0)
	var fly_to := position + dir * 1.8
	var t := create_tween()
	t.tween_property(self, "position", fly_to + Vector3(0, 1.0, 0), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(model, "rotation:x", fall_angle * 0.5, 0.3)
	t.tween_property(self, "position", fly_to, 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(model, "rotation:x", fall_angle, 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	t.tween_interval(0.25)
	t.tween_method(_set_alpha, 1.0, 0.0, 0.7)
	await t.finished
	visible = false


func _set_alpha(alpha: float) -> void:
	for mat in _materials:
		var base_alpha: float = (_material_bases.get(mat, {"alpha": 1.0}) as Dictionary)["alpha"]
		var c := mat.albedo_color
		c.a = alpha * base_alpha
		mat.albedo_color = c
