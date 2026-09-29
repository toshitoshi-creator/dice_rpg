class_name EnemyActor
extends BattleActor
## 敵。EnemyData からステータスと見た目を決める。
## 形は各チャプターの種族ビルダー（scripts/enemies/chapter_XX.gd）が ModelKit で作り、
## ここでは大きさの自動調整と待機・攻撃モーションを担当する。

var data: EnemyData

var _parts: Dictionary = {}
## モデルの上端・前端（拡大縮小後、足元からの距離）
var _extent_top := 1.6
var _extent_front := 0.8
var _body: Node3D


func setup(p_data: EnemyData) -> void:
	data = p_data
	setup_stats(data.display_name, data.max_hp, data.attack, data.defense)
	attack_jump_height = _jump_height_for(data.idle_style, data.is_boss)


static func _jump_height_for(style: StringName, is_boss: bool) -> float:
	var h := 0.5
	match style:
		&"bounce":
			h = 0.9
		&"hover", &"flicker":
			h = 0.35
		&"breathe":
			h = 0.3
	return minf(h, 0.35) if is_boss else h


func get_hit_point() -> Vector3:
	return global_position + Vector3(0, _extent_top * 0.55, _extent_front * 0.5)


## プレイヤーの手前で止まるように踏み込む割合を決める。
func get_lunge_ratio(target: Vector3 = Vector3(0, 0, 4.4)) -> float:
	var dist := Vector2(target.x - position.x, target.z - position.z).length()
	if dist < 0.01:
		return 0.0
	return clampf((dist - _extent_front - 1.3) / dist, 0.3, 0.75)


func _build_model() -> void:
	_body = Node3D.new()
	_body.name = "Body"
	model.add_child(_body)
	var kit := ModelKit.new(data.palette if data else {})
	var custom := CustomModels.enemy_path(data)
	if custom == "" or CustomModels.attach(custom, _body, kit) == null:
		EnemyModels.build(data.model_type if data else &"slime", kit, _body)
	_materials.append_array(kit.materials)
	_parts = kit.parts
	# 目標サイズに合わせて拡大縮小
	var aabb := ModelKit.compute_aabb(_body)
	var height := maxf(aabb.end.y, 0.05)
	var width := maxf(aabb.size.x, 0.05)
	var target_h := data.target_height if data else 1.6
	var max_w := data.max_width if data else 2.6
	var s := minf(target_h / height, max_w / width)
	_body.scale = Vector3.ONE * s
	_extent_top = aabb.end.y * s
	_extent_front = maxf(aabb.end.z * s, 0.3)


## 大きさ確認用（テスト・図鑑）。x = 横幅、y = 地面からの高さ、z = 奥行き。
func get_model_size() -> Vector3:
	var aabb := ModelKit.compute_aabb(_body)
	return Vector3(aabb.size.x, aabb.end.y, aabb.size.z) * _body.scale.x


# ------------------------------------------------------------------
# アニメーション
# ------------------------------------------------------------------
func _create_idle_tween() -> Tween:
	var style: StringName = data.idle_style if data else &"sway"
	var t := create_tween().set_loops()
	var sine := Tween.TRANS_SINE
	var io := Tween.EASE_IN_OUT
	var period := 0.5
	match style:
		&"bounce":
			period = 0.45
			t.tween_property(model, "scale", Vector3(1.07, 0.92, 1.07), period).set_trans(sine).set_ease(io)
			t.tween_property(model, "scale", Vector3(0.95, 1.06, 0.95), period).set_trans(sine).set_ease(io)
		&"hover":
			period = 0.8
			t.tween_property(model, "position:y", 0.18, period).set_trans(sine).set_ease(io)
			t.parallel().tween_property(model, "rotation_degrees:z", 3.0, period).set_trans(sine)
			t.tween_property(model, "position:y", 0.0, period).set_trans(sine).set_ease(io)
			t.parallel().tween_property(model, "rotation_degrees:z", -3.0, period).set_trans(sine)
		&"breathe":
			period = 0.9
			t.tween_property(model, "scale", Vector3(1.02, 1.04, 1.02), period).set_trans(sine).set_ease(io)
			t.tween_property(model, "scale", Vector3.ONE, period).set_trans(sine).set_ease(io)
		&"flicker":
			period = 0.25
			t.tween_property(model, "scale", Vector3(1.06, 0.95, 1.06), period).set_trans(sine)
			t.parallel().tween_property(model, "position:y", 0.1, period).set_trans(sine)
			t.tween_property(model, "scale", Vector3(0.96, 1.07, 0.96), period).set_trans(sine)
			t.parallel().tween_property(model, "position:y", 0.0, period).set_trans(sine)
		_:
			period = 0.5
			t.tween_property(model, "position:y", 0.06, period).set_trans(sine).set_ease(io)
			t.parallel().tween_property(model, "rotation_degrees:z", 3.0, period).set_trans(sine)
			t.tween_property(model, "position:y", 0.0, period).set_trans(sine).set_ease(io)
			t.parallel().tween_property(model, "rotation_degrees:z", -3.0, period).set_trans(sine)
	_start_part_loops()
	return t


## 翼・しっぽは待機モーションとは別周期でループさせる。
var _part_tweens: Array[Tween] = []


func _start_part_loops() -> void:
	_stop_part_loops()
	var wing_time: float = _parts.get("wing_speed", 0.6)
	var wing_angle: float = _parts.get("wing_angle", 25.0)
	for w in _parts.get("wings", []):
		var p: Node3D = w[0]
		var side: float = w[1]
		var base_z := p.rotation_degrees.z
		p.set_meta(&"base_rot", p.rotation_degrees)
		var t := create_tween().set_loops()
		t.tween_property(p, "rotation_degrees:z", base_z + wing_angle * side, wing_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(p, "rotation_degrees:z", base_z - wing_angle * 0.6 * side, wing_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_part_tweens.append(t)
	var tail: Node3D = _parts.get("tail")
	if tail:
		var base_y := tail.rotation_degrees.y
		tail.set_meta(&"base_rot", tail.rotation_degrees)
		var t := create_tween().set_loops()
		t.tween_property(tail, "rotation_degrees:y", base_y + 15.0, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(tail, "rotation_degrees:y", base_y - 15.0, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_part_tweens.append(t)


func _stop_part_loops() -> void:
	for t in _part_tweens:
		if t and t.is_valid():
			t.kill()
	_part_tweens.clear()
	for w in _parts.get("wings", []):
		var p: Node3D = w[0]
		if p.has_meta(&"base_rot"):
			p.rotation_degrees = p.get_meta(&"base_rot")
	var tail: Node3D = _parts.get("tail")
	if tail and tail.has_meta(&"base_rot"):
		tail.rotation_degrees = tail.get_meta(&"base_rot")


func stop_idle() -> void:
	super.stop_idle()
	_stop_part_loops()


## 攻撃時: 武器を振りかぶって振り下ろす / 翼を大きく広げる。
func _on_strike(duration: float) -> void:
	var weapon: Node3D = _parts.get("weapon")
	if weapon:
		var base := weapon.rotation_degrees.x
		var t := create_tween()
		t.tween_property(weapon, "rotation_degrees:x", base - 80.0, duration * 0.5).set_ease(Tween.EASE_OUT)
		t.tween_property(weapon, "rotation_degrees:x", base + 50.0, duration * 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		t.tween_interval(0.2)
		t.tween_property(weapon, "rotation_degrees:x", base, 0.3)
	for w in _parts.get("wings", []):
		var p: Node3D = w[0]
		var side: float = w[1]
		var base_z := p.rotation_degrees.z
		var t := create_tween()
		t.tween_property(p, "rotation_degrees:z", base_z + 40.0 * side, duration * 0.5)
		t.tween_property(p, "rotation_degrees:z", base_z - 20.0 * side, duration)
		t.tween_property(p, "rotation_degrees:z", base_z, 0.3)
