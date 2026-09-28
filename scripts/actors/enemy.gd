class_name EnemyActor
extends BattleActor
## 敵。EnemyData からステータスと見た目を決める。

var data: EnemyData


func setup(p_data: EnemyData) -> void:
	data = p_data
	setup_stats(data.display_name, data.max_hp, data.attack, data.defense)
	attack_jump_height = 0.9


func get_hit_point() -> Vector3:
	return global_position + Vector3(0, 0.8 * _scale(), 0)


func _scale() -> float:
	return data.model_scale if data else 1.0


func _build_model() -> void:
	var model_type: StringName = data.model_type if data else &"slime"
	match model_type:
		&"slime":
			_build_slime()
		_:
			_build_slime()
	model.scale = Vector3.ONE


func _build_slime() -> void:
	var s := _scale()
	var color := data.body_color if data else Color(0.3, 0.85, 0.45)
	var root := Node3D.new()
	root.name = "SlimeRoot"
	root.scale = Vector3.ONE * s
	model.add_child(root)

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

	# 床にとろけた部分
	var puddle := CylinderMesh.new()
	puddle.top_radius = 0.95
	puddle.bottom_radius = 1.0
	puddle.height = 0.12
	_add_mesh(puddle, dark_body, Vector3(0, 0.06, 0), Vector3.ZERO, root)
	# 本体
	var body := SphereMesh.new()
	body.radius = 0.9
	body.height = 1.35
	_add_mesh(body, body_mat, Vector3(0, 0.62, 0), Vector3.ZERO, root)
	# 頭のしずく
	var tip := CylinderMesh.new()
	tip.top_radius = 0.0
	tip.bottom_radius = 0.28
	tip.height = 0.5
	_add_mesh(tip, body_mat, Vector3(0, 1.35, -0.05), Vector3(-10, 0, 0), root)
	# 目
	for x in [-0.3, 0.3]:
		var eye := SphereMesh.new()
		eye.radius = 0.17
		eye.height = 0.34
		_add_mesh(eye, white, Vector3(x, 0.8, 0.7), Vector3.ZERO, root)
		var pupil := SphereMesh.new()
		pupil.radius = 0.09
		pupil.height = 0.18
		_add_mesh(pupil, black, Vector3(x * 0.95, 0.8, 0.84), Vector3.ZERO, root)
		var shine := SphereMesh.new()
		shine.radius = 0.03
		shine.height = 0.06
		_add_mesh(shine, white, Vector3(x * 0.95 + 0.03, 0.85, 0.92), Vector3.ZERO, root)
	# 口
	var mouth := SphereMesh.new()
	mouth.radius = 0.12
	mouth.height = 0.12
	var mouth_mi := _add_mesh(mouth, mouth_mat, Vector3(0, 0.52, 0.84), Vector3.ZERO, root)
	mouth_mi.scale = Vector3(1.4, 0.6, 0.5)
	# ハイライト
	var hl := SphereMesh.new()
	hl.radius = 0.14
	hl.height = 0.28
	var hl_mat := _make_material(Color(1, 1, 1), 0.0)
	var hl_mi := _add_mesh(hl, hl_mat, Vector3(-0.42, 1.05, 0.5), Vector3.ZERO, root)
	hl_mi.scale = Vector3(1.0, 0.6, 0.4)
	hl_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _create_idle_tween() -> Tween:
	var t := create_tween().set_loops()
	t.tween_property(model, "scale", Vector3(1.07, 0.92, 1.07), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(model, "scale", Vector3(0.95, 1.06, 0.95), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return t
