class_name PlayerActor
extends BattleActor
## プレイヤー（剣士）。Godot 標準 Mesh の組み合わせで作る簡易モデル。

var _sword_pivot: Node3D


func _init() -> void:
	display_name = "PLAYER"
	max_hp = 100
	hp = 100
	attack = 1
	defense = 0


func _build_model() -> void:
	var skin := _make_material(Color(0.96, 0.78, 0.62))
	var tunic := _make_material(Color(0.18, 0.36, 0.78), 0.7)
	var dark := _make_material(Color(0.16, 0.13, 0.18), 0.8)
	var leather := _make_material(Color(0.45, 0.28, 0.15), 0.8)
	var steel := _make_material(Color(0.82, 0.85, 0.9), 0.25, 0.85)
	var gold := _make_material(Color(1.0, 0.78, 0.25), 0.3, 0.9)
	var cape_mat := _make_material(Color(0.78, 0.12, 0.16), 0.8)
	cape_mat.cull_mode = BaseMaterial3D.CULL_DISABLED

	# 脚
	for x in [-0.17, 0.17]:
		var leg := CapsuleMesh.new()
		leg.radius = 0.13
		leg.height = 0.75
		_add_mesh(leg, dark, Vector3(x, 0.38, 0))
	# 胴体
	var body := CapsuleMesh.new()
	body.radius = 0.34
	body.height = 1.05
	_add_mesh(body, tunic, Vector3(0, 1.0, 0))
	# ベルト
	var belt := CylinderMesh.new()
	belt.top_radius = 0.35
	belt.bottom_radius = 0.35
	belt.height = 0.1
	_add_mesh(belt, leather, Vector3(0, 0.82, 0))
	# 頭
	var head := SphereMesh.new()
	head.radius = 0.27
	head.height = 0.54
	_add_mesh(head, skin, Vector3(0, 1.72, 0))
	# 兜
	var helmet := SphereMesh.new()
	helmet.radius = 0.3
	helmet.height = 0.3
	helmet.is_hemisphere = true
	_add_mesh(helmet, steel, Vector3(0, 1.76, 0))
	var plume := CylinderMesh.new()
	plume.top_radius = 0.0
	plume.bottom_radius = 0.07
	plume.height = 0.35
	_add_mesh(plume, cape_mat, Vector3(0, 2.15, 0.05), Vector3(-20, 0, 0))
	# マント（カメラ側 = 背中側）
	var cape := BoxMesh.new()
	cape.size = Vector3(0.62, 1.0, 0.04)
	_add_mesh(cape, cape_mat, Vector3(0, 1.05, 0.36), Vector3(12, 0, 0))
	# 盾（左腕）
	var shield := CylinderMesh.new()
	shield.top_radius = 0.3
	shield.bottom_radius = 0.3
	shield.height = 0.06
	_add_mesh(shield, steel, Vector3(-0.46, 1.0, -0.12), Vector3(90, 0, 10))
	var boss := SphereMesh.new()
	boss.radius = 0.08
	boss.height = 0.16
	_add_mesh(boss, gold, Vector3(-0.47, 1.0, -0.16))

	# 剣（右腕。肩を支点に回転させる）
	_sword_pivot = Node3D.new()
	_sword_pivot.name = "SwordPivot"
	_sword_pivot.position = Vector3(0.44, 1.3, 0)
	model.add_child(_sword_pivot)
	var arm := CapsuleMesh.new()
	arm.radius = 0.09
	arm.height = 0.55
	_add_mesh(arm, tunic, Vector3(0, -0.22, 0), Vector3.ZERO, _sword_pivot)
	var hilt := CylinderMesh.new()
	hilt.top_radius = 0.04
	hilt.bottom_radius = 0.04
	hilt.height = 0.25
	_add_mesh(hilt, leather, Vector3(0, -0.45, 0.0), Vector3(-70, 0, 0), _sword_pivot)
	var guard := BoxMesh.new()
	guard.size = Vector3(0.32, 0.06, 0.08)
	_add_mesh(guard, gold, Vector3(0, -0.405, -0.12), Vector3(-70, 0, 0), _sword_pivot)
	var blade := BoxMesh.new()
	blade.size = Vector3(0.1, 1.1, 0.03)
	_add_mesh(blade, steel, Vector3(0, -0.22, -0.64), Vector3(-70, 0, 0), _sword_pivot)
	_sword_pivot.rotation_degrees = Vector3(-20, 0, 0)


func _create_idle_tween() -> Tween:
	var t := create_tween().set_loops()
	t.tween_property(model, "position:y", 0.05, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(model, "position:y", 0.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return t


func stop_idle() -> void:
	super.stop_idle()
	if _sword_pivot:
		_sword_pivot.rotation_degrees = Vector3(-20, 0, 0)


## 剣を振りかぶって振り下ろす。
func _on_strike(duration: float) -> void:
	if not _sword_pivot:
		return
	var t := create_tween()
	t.tween_property(_sword_pivot, "rotation_degrees:x", 60.0, duration * 0.5).set_ease(Tween.EASE_OUT)
	t.tween_property(_sword_pivot, "rotation_degrees:x", -110.0, duration * 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	t.tween_interval(0.2)
	t.tween_property(_sword_pivot, "rotation_degrees:x", -20.0, 0.3).set_trans(Tween.TRANS_SINE)
