class_name EnemyActor
extends BattleActor
## 敵。EnemyData からステータスと見た目を決める。
## 見た目は model_type ごとの _build_xxx() で Godot 標準 Mesh を組み合わせて作る。

var data: EnemyData

## 待機モーションで動かす部位（ドラゴンの翼など）
var _wing_pivots: Array[Node3D] = []
var _weapon_pivot: Node3D


func setup(p_data: EnemyData) -> void:
	data = p_data
	setup_stats(data.display_name, data.max_hp, data.attack, data.defense)
	attack_jump_height = data.jump_height


func get_hit_point() -> Vector3:
	if not data:
		return global_position + Vector3(0, 0.9, 0)
	return global_position + Vector3(0, data.hit_height, data.hit_forward)


func get_lunge_ratio() -> float:
	return data.lunge_ratio if data else 0.7


func _scale() -> float:
	return data.model_scale if data else 1.0


func _color() -> Color:
	return data.body_color if data else Color(0.3, 0.85, 0.45)


func _build_model() -> void:
	var root := Node3D.new()
	root.name = "Body"
	root.scale = Vector3.ONE * _scale()
	model.add_child(root)
	var model_type: StringName = data.model_type if data else &"slime"
	match model_type:
		&"goblin":
			_build_goblin(root)
		&"skeleton":
			_build_skeleton(root)
		&"dragon":
			_build_dragon(root)
		_:
			_build_slime(root)


func _sphere(radius: float, height: float = -1.0) -> SphereMesh:
	var m := SphereMesh.new()
	m.radius = radius
	m.height = radius * 2.0 if height < 0.0 else height
	return m


func _capsule(radius: float, height: float) -> CapsuleMesh:
	var m := CapsuleMesh.new()
	m.radius = radius
	m.height = height
	return m


func _cylinder(top: float, bottom: float, height: float, segments: int = 12) -> CylinderMesh:
	var m := CylinderMesh.new()
	m.top_radius = top
	m.bottom_radius = bottom
	m.height = height
	m.radial_segments = segments
	return m


func _box(size: Vector3) -> BoxMesh:
	var m := BoxMesh.new()
	m.size = size
	return m


func _glow_material(color: Color, energy: float = 2.0) -> StandardMaterial3D:
	var mat := _make_material(color, 0.3)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = energy
	return mat


# ------------------------------------------------------------------
# SLIME
# ------------------------------------------------------------------
func _build_slime(root: Node3D) -> void:
	var color := _color()
	var body_mat := _make_material(color, 0.15)
	body_mat.metallic_specular = 0.9
	body_mat.rim_enabled = true
	body_mat.rim = 0.6
	body_mat.rim_tint = 0.3
	body_mat.clearcoat_enabled = true
	body_mat.clearcoat = 0.8
	var dark_body := _make_material(color.darkened(0.35), 0.3)
	var white := _make_material(Color(1, 1, 1), 0.2)
	var black := _make_material(Color(0.05, 0.05, 0.08), 0.1)
	var mouth_mat := _make_material(Color(0.35, 0.05, 0.12), 0.4)

	_add_mesh(_cylinder(0.95, 1.0, 0.12, 24), dark_body, Vector3(0, 0.06, 0), Vector3.ZERO, root)
	_add_mesh(_sphere(0.9, 1.35), body_mat, Vector3(0, 0.62, 0), Vector3.ZERO, root)
	_add_mesh(_cylinder(0.0, 0.28, 0.5), body_mat, Vector3(0, 1.35, -0.05), Vector3(-10, 0, 0), root)
	for x in [-0.3, 0.3]:
		_add_mesh(_sphere(0.17), white, Vector3(x, 0.8, 0.7), Vector3.ZERO, root)
		_add_mesh(_sphere(0.09), black, Vector3(x * 0.95, 0.8, 0.84), Vector3.ZERO, root)
		_add_mesh(_sphere(0.03), white, Vector3(x * 0.95 + 0.03, 0.85, 0.92), Vector3.ZERO, root)
	var mouth := _add_mesh(_sphere(0.12, 0.12), mouth_mat, Vector3(0, 0.52, 0.84), Vector3.ZERO, root)
	mouth.scale = Vector3(1.4, 0.6, 0.5)
	var hl := _add_mesh(_sphere(0.14), _make_material(Color(1, 1, 1), 0.0), Vector3(-0.42, 1.05, 0.5), Vector3.ZERO, root)
	hl.scale = Vector3(1.0, 0.6, 0.4)
	hl.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


# ------------------------------------------------------------------
# GOBLIN
# ------------------------------------------------------------------
func _build_goblin(root: Node3D) -> void:
	var skin := _make_material(_color(), 0.7)
	var cloth := _make_material(Color(0.42, 0.26, 0.14), 0.9)
	var dark := _make_material(Color(0.2, 0.14, 0.1), 0.9)
	var eye := _glow_material(Color(1.0, 0.85, 0.1), 1.5)
	var pupil := _make_material(Color(0.05, 0.02, 0.02), 0.2)
	var tooth := _make_material(Color(0.95, 0.92, 0.8), 0.4)
	var wood := _make_material(Color(0.5, 0.33, 0.18), 0.8)
	var metal := _make_material(Color(0.55, 0.55, 0.6), 0.35, 0.7)

	for x in [-0.15, 0.15]:
		_add_mesh(_capsule(0.11, 0.55), skin, Vector3(x, 0.28, 0), Vector3.ZERO, root)
		_add_mesh(_box(Vector3(0.18, 0.08, 0.28)), dark, Vector3(x, 0.04, 0.05), Vector3.ZERO, root)
	_add_mesh(_capsule(0.32, 0.8), skin, Vector3(0, 0.8, 0), Vector3.ZERO, root)
	_add_mesh(_cylinder(0.34, 0.38, 0.3), cloth, Vector3(0, 0.55, 0), Vector3.ZERO, root)
	_add_mesh(_box(Vector3(0.7, 0.08, 0.1)), dark, Vector3(0, 0.9, 0.22), Vector3(0, 0, -35), root)
	# 頭
	_add_mesh(_sphere(0.33), skin, Vector3(0, 1.42, 0.02), Vector3.ZERO, root)
	for side in [-1.0, 1.0]:
		_add_mesh(_cylinder(0.0, 0.11, 0.5, 8), skin, Vector3(0.38 * side, 1.5, -0.02), Vector3(0, 0, -70.0 * side), root)
		_add_mesh(_sphere(0.085), eye, Vector3(0.13 * side, 1.5, 0.27), Vector3.ZERO, root)
		_add_mesh(_sphere(0.04), pupil, Vector3(0.13 * side, 1.5, 0.35), Vector3.ZERO, root)
		_add_mesh(_cylinder(0.0, 0.03, 0.1, 6), tooth, Vector3(0.08 * side, 1.26, 0.3), Vector3(180, 0, 0), root)
	_add_mesh(_sphere(0.08), skin, Vector3(0, 1.4, 0.34), Vector3.ZERO, root)
	_add_mesh(_box(Vector3(0.26, 0.04, 0.05)), pupil, Vector3(0, 1.29, 0.3), Vector3.ZERO, root)
	# 腕
	_add_mesh(_capsule(0.08, 0.55), skin, Vector3(-0.4, 0.85, 0.05), Vector3(0, 0, -15), root)
	# 棍棒（右手）
	_weapon_pivot = Node3D.new()
	_weapon_pivot.position = Vector3(0.4, 1.0, 0.05)
	root.add_child(_weapon_pivot)
	_add_mesh(_capsule(0.08, 0.55), skin, Vector3(0, -0.2, 0), Vector3.ZERO, _weapon_pivot)
	_add_mesh(_cylinder(0.05, 0.05, 0.5), wood, Vector3(0, -0.35, 0.25), Vector3(70, 0, 0), _weapon_pivot)
	_add_mesh(_cylinder(0.16, 0.1, 0.45), wood, Vector3(0, -0.2, 0.65), Vector3(70, 0, 0), _weapon_pivot)
	for i in 3:
		_add_mesh(_cylinder(0.0, 0.04, 0.12, 6), metal, Vector3(0.14 * (i - 1), -0.08, 0.72), Vector3(0, 0, 0), _weapon_pivot)


# ------------------------------------------------------------------
# SKELETON
# ------------------------------------------------------------------
func _build_skeleton(root: Node3D) -> void:
	var bone := _make_material(_color(), 0.55)
	var dark := _make_material(Color(0.05, 0.04, 0.06), 0.9)
	var eye := _glow_material(Color(1.0, 0.25, 0.2), 3.0)
	var rust := _make_material(Color(0.55, 0.45, 0.38), 0.4, 0.6)
	var cloth := _make_material(Color(0.25, 0.12, 0.3), 0.9)
	cloth.cull_mode = BaseMaterial3D.CULL_DISABLED

	for x in [-0.13, 0.13]:
		_add_mesh(_cylinder(0.045, 0.05, 0.7, 8), bone, Vector3(x, 0.37, 0), Vector3.ZERO, root)
		_add_mesh(_sphere(0.07), bone, Vector3(x, 0.38, 0.02), Vector3.ZERO, root)
		_add_mesh(_box(Vector3(0.14, 0.06, 0.24)), bone, Vector3(x, 0.03, 0.05), Vector3.ZERO, root)
	_add_mesh(_box(Vector3(0.38, 0.13, 0.2)), bone, Vector3(0, 0.76, 0), Vector3.ZERO, root)
	_add_mesh(_cylinder(0.04, 0.04, 0.65, 8), bone, Vector3(0, 1.07, -0.02), Vector3.ZERO, root)
	for i in 4:
		var rib := TorusMesh.new()
		rib.inner_radius = 0.15 - i * 0.012
		rib.outer_radius = 0.2 - i * 0.012
		rib.rings = 16
		rib.ring_segments = 6
		var mi := _add_mesh(rib, bone, Vector3(0, 0.98 + i * 0.1, 0.02), Vector3.ZERO, root)
		mi.scale = Vector3(1.1, 1.4, 0.75)
	# ボロ布（腰）
	_add_mesh(_cylinder(0.24, 0.3, 0.2, 10), cloth, Vector3(0, 0.66, 0), Vector3.ZERO, root)
	# 頭蓋骨
	_add_mesh(_sphere(0.23), bone, Vector3(0, 1.58, 0), Vector3.ZERO, root)
	_add_mesh(_box(Vector3(0.24, 0.1, 0.2)), bone, Vector3(0, 1.4, 0.06), Vector3.ZERO, root)
	for side in [-1.0, 1.0]:
		_add_mesh(_sphere(0.065), dark, Vector3(0.085 * side, 1.6, 0.18), Vector3.ZERO, root)
		_add_mesh(_sphere(0.03), eye, Vector3(0.085 * side, 1.6, 0.22), Vector3.ZERO, root)
	_add_mesh(_box(Vector3(0.04, 0.05, 0.04)), dark, Vector3(0, 1.5, 0.22), Vector3.ZERO, root)
	# 左腕と盾
	_add_mesh(_cylinder(0.035, 0.035, 0.6, 6), bone, Vector3(-0.3, 1.02, 0.05), Vector3(0, 0, -12), root)
	_add_mesh(_cylinder(0.26, 0.26, 0.05, 8), rust, Vector3(-0.38, 0.92, 0.2), Vector3(90, 0, 0), root)
	# 右腕と剣
	_weapon_pivot = Node3D.new()
	_weapon_pivot.position = Vector3(0.3, 1.3, 0.02)
	root.add_child(_weapon_pivot)
	_add_mesh(_cylinder(0.035, 0.035, 0.55, 6), bone, Vector3(0, -0.25, 0), Vector3.ZERO, _weapon_pivot)
	_add_mesh(_box(Vector3(0.24, 0.04, 0.06)), rust, Vector3(0, -0.52, 0.12), Vector3(-70, 0, 0), _weapon_pivot)
	_add_mesh(_box(Vector3(0.07, 0.8, 0.02)), rust, Vector3(0, -0.4, 0.55), Vector3(-70, 0, 0), _weapon_pivot)
	_weapon_pivot.rotation_degrees = Vector3(20, 0, 0)


# ------------------------------------------------------------------
# DRAGON (BOSS)
# ------------------------------------------------------------------
func _build_dragon(root: Node3D) -> void:
	var scales := _make_material(_color(), 0.45)
	scales.metallic_specular = 0.7
	scales.rim_enabled = true
	scales.rim = 0.4
	var belly := _make_material(Color(0.95, 0.72, 0.4), 0.6)
	var membrane := _make_material(_color().darkened(0.4), 0.7)
	membrane.cull_mode = BaseMaterial3D.CULL_DISABLED
	var horn := _make_material(Color(0.95, 0.9, 0.78), 0.4)
	var eye := _glow_material(Color(1.0, 0.85, 0.1), 3.0)
	var claw := _make_material(Color(0.15, 0.1, 0.1), 0.3)

	# 胴体
	var body := _add_mesh(_sphere(1.0, 1.7), scales, Vector3(0, 1.25, -0.3), Vector3.ZERO, root)
	body.scale = Vector3(1.0, 1.0, 1.25)
	var front := _add_mesh(_sphere(0.72, 1.3), belly, Vector3(0, 1.15, 0.45), Vector3.ZERO, root)
	front.scale = Vector3(0.95, 1.0, 0.55)
	# 脚
	for side in [-1.0, 1.0]:
		_add_mesh(_capsule(0.26, 0.95), scales, Vector3(0.62 * side, 0.45, 0.35), Vector3.ZERO, root)
		_add_mesh(_capsule(0.26, 0.95), scales, Vector3(0.62 * side, 0.45, -0.95), Vector3.ZERO, root)
		for c in 3:
			_add_mesh(_cylinder(0.0, 0.05, 0.16, 6), claw, Vector3(0.62 * side + (c - 1) * 0.1, 0.05, 0.62), Vector3(90, 0, 0), root)
	# 首と頭
	_add_mesh(_capsule(0.34, 1.35), scales, Vector3(0, 2.15, 0.55), Vector3(30, 0, 0), root)
	_add_mesh(_box(Vector3(0.72, 0.58, 0.8)), scales, Vector3(0, 2.85, 0.95), Vector3.ZERO, root)
	_add_mesh(_box(Vector3(0.52, 0.34, 0.6)), scales, Vector3(0, 2.72, 1.5), Vector3.ZERO, root)
	_add_mesh(_box(Vector3(0.48, 0.1, 0.5)), belly, Vector3(0, 2.56, 1.48), Vector3.ZERO, root)
	for side in [-1.0, 1.0]:
		_add_mesh(_cylinder(0.0, 0.1, 0.65, 8), horn, Vector3(0.24 * side, 3.25, 0.75), Vector3(-40, 0, -18.0 * side), root)
		_add_mesh(_sphere(0.08), eye, Vector3(0.26 * side, 2.98, 1.3), Vector3.ZERO, root)
		_add_mesh(_cylinder(0.0, 0.035, 0.12, 6), horn, Vector3(0.18 * side, 2.54, 1.72), Vector3(180, 0, 0), root)
		_add_mesh(_sphere(0.04), claw, Vector3(0.12 * side, 2.82, 1.8), Vector3.ZERO, root)
	# 背中のトゲ
	for i in 4:
		_add_mesh(_cylinder(0.0, 0.14, 0.4, 6), horn, Vector3(0, 2.15 - i * 0.08, -0.1 - i * 0.45), Vector3(-25, 0, 0), root)
	# 尻尾
	_add_mesh(_cylinder(0.12, 0.42, 1.8), scales, Vector3(0, 0.75, -2.0), Vector3(-72, 0, 0), root)
	_add_mesh(_cylinder(0.0, 0.2, 0.5, 4), horn, Vector3(0, 0.5, -2.95), Vector3(-80, 0, 0), root)
	# 翼（付け根を支点に羽ばたかせる）
	for side in [-1.0, 1.0]:
		var pivot := Node3D.new()
		pivot.position = Vector3(0.55 * side, 2.0, -0.35)
		root.add_child(pivot)
		_wing_pivots.append(pivot)
		_add_mesh(_cylinder(0.07, 0.1, 1.9, 8), scales, Vector3(0.9 * side, 0.55, 0), Vector3(0, 0, -60.0 * side), pivot)
		var wing := _add_mesh(_box(Vector3(1.9, 0.04, 1.3)), membrane, Vector3(1.0 * side, 0.35, -0.45), Vector3(0, 0, 22.0 * side), pivot)
		wing.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON


# ------------------------------------------------------------------
# アニメーション
# ------------------------------------------------------------------
func _create_idle_tween() -> Tween:
	var model_type: StringName = data.model_type if data else &"slime"
	var t := create_tween().set_loops()
	match model_type:
		&"slime":
			t.tween_property(model, "scale", Vector3(1.07, 0.92, 1.07), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			t.tween_property(model, "scale", Vector3(0.95, 1.06, 0.95), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		&"dragon":
			t.tween_property(model, "position:y", 0.12, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			for i in _wing_pivots.size():
				var side := -1.0 if i == 0 else 1.0
				t.parallel().tween_property(_wing_pivots[i], "rotation_degrees:z", 25.0 * side, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			t.tween_property(model, "position:y", 0.0, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			for i in _wing_pivots.size():
				var side := -1.0 if i == 0 else 1.0
				t.parallel().tween_property(_wing_pivots[i], "rotation_degrees:z", -15.0 * side, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_:
			# 人型: 体を揺らしながら武器を構える
			t.tween_property(model, "position:y", 0.06, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			t.parallel().tween_property(model, "rotation_degrees:z", 3.0, 0.5).set_trans(Tween.TRANS_SINE)
			t.tween_property(model, "position:y", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			t.parallel().tween_property(model, "rotation_degrees:z", -3.0, 0.5).set_trans(Tween.TRANS_SINE)
	return t


func stop_idle() -> void:
	super.stop_idle()
	for pivot in _wing_pivots:
		pivot.rotation = Vector3.ZERO


## 攻撃時: 武器を振りかぶって振り下ろす / 翼を大きく広げる。
func _on_strike(duration: float) -> void:
	if _weapon_pivot:
		var base := _weapon_pivot.rotation_degrees.x
		var t := create_tween()
		t.tween_property(_weapon_pivot, "rotation_degrees:x", base - 90.0, duration * 0.5).set_ease(Tween.EASE_OUT)
		t.tween_property(_weapon_pivot, "rotation_degrees:x", base + 50.0, duration * 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		t.tween_interval(0.2)
		t.tween_property(_weapon_pivot, "rotation_degrees:x", base, 0.3)
	for i in _wing_pivots.size():
		var side := -1.0 if i == 0 else 1.0
		var t := create_tween()
		t.tween_property(_wing_pivots[i], "rotation_degrees:z", 40.0 * side, duration * 0.5)
		t.tween_property(_wing_pivots[i], "rotation_degrees:z", -20.0 * side, duration)
		t.tween_property(_wing_pivots[i], "rotation_degrees:z", 0.0, 0.3)
