class_name Dice
extends RigidBody3D
## 物理演算で実際に転がる 6 面サイコロ。
##
## 各面はローカル座標の法線ベクトルと出目の対応表 (FACE_NORMALS / face_values) で定義する。
## 停止後、ワールド空間で最も真上を向いている面の値を出目とする。
## 停止判定後は freeze して姿勢を固定するため、画面に見えている上面と出目は必ず一致する。

signal roll_started
signal roll_finished(result: DiceResult)
signal impact(strength: float)

## ローカル空間での各面の法線。face_values と同じ順番。
const FACE_NORMALS: Array[Vector3] = [
	Vector3.UP,       # +Y
	Vector3.DOWN,     # -Y
	Vector3.RIGHT,    # +X
	Vector3.LEFT,     # -X
	Vector3.BACK,     # +Z
	Vector3.FORWARD,  # -Z
]

@export var size: float = 1.0
@export var dice_type: StringName = &"normal"
## FACE_NORMALS[i] の面に表示される数字。対面の和が 7 になる標準配置。
@export var face_values: Array[int] = [1, 6, 2, 5, 3, 4]
@export var body_color: Color = Color(0.98, 0.96, 0.9)
@export var number_color: Color = Color(0.12, 0.1, 0.16)
@export var one_color: Color = Color(0.85, 0.08, 0.12)

@export_group("Settle detection")
@export var settle_linear_threshold: float = 0.08
@export var settle_angular_threshold: float = 0.12
@export var settle_time: float = 0.3
@export var min_roll_time: float = 0.6
@export var max_roll_time: float = 7.0
## 上面がこの値より傾いていたら（壁に立てかかった等）軽く弾いて転がし直す
@export var flat_threshold: float = 0.96
@export var max_nudges: int = 6

var rest_position := Vector3(0.0, 0.5, 0.6)
var is_rolling := false

var _pending_state: Dictionary = {}
var _elapsed := 0.0
var _still_time := 0.0
var _nudges := 0
var _last_impact_ms := 0
var _visual: Node3D
var _face_labels: Array[Label3D] = []
var _highlight_tween: Tween
var _body_mat: StandardMaterial3D
var _edge_mat: StandardMaterial3D
var _underlines: Array[MeshInstance3D] = []
## 標準の出目（スペシャル技のあとに戻すため）
var _normal_faces: Array[int] = []
var is_special := false


func _ready() -> void:
	mass = 1.0
	can_sleep = false
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = 4
	linear_damp = 0.1
	angular_damp = 0.5
	var physics_mat := PhysicsMaterial.new()
	physics_mat.bounce = 0.35
	physics_mat.friction = 0.75
	physics_material_override = physics_mat

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3.ONE * size
	shape.shape = box
	add_child(shape)

	_build_visual()
	body_entered.connect(_on_body_entered)
	reset_to_rest()


# ------------------------------------------------------------------
# 見た目
# ------------------------------------------------------------------
func _build_visual() -> void:
	_visual = Node3D.new()
	_visual.name = "Visual"
	add_child(_visual)

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE * size
	mesh_instance.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = body_color
	mat.roughness = 0.35
	mat.metallic_specular = 0.6
	mat.rim_enabled = true
	mat.rim = 0.3
	mesh_instance.material_override = mat
	_visual.add_child(mesh_instance)
	_body_mat = mat

	# 角を丸く見せるための少し小さい面取りフレーム（エッジを暗く見せる）
	var edge := MeshInstance3D.new()
	var edge_mesh := BoxMesh.new()
	edge_mesh.size = Vector3.ONE * (size + 0.012)
	edge.mesh = edge_mesh
	var edge_mat := StandardMaterial3D.new()
	edge_mat.albedo_color = Color(0.75, 0.68, 0.55)
	edge_mat.cull_mode = BaseMaterial3D.CULL_FRONT
	edge.material_override = edge_mat
	_edge_mat = edge_mat
	edge.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_visual.add_child(edge)

	for i in FACE_NORMALS.size():
		var normal: Vector3 = FACE_NORMALS[i]
		var label := Label3D.new()
		label.text = str(face_values[i])
		label.font_size = 128
		label.pixel_size = size * 0.0042
		label.outline_size = 0
		label.modulate = one_color if face_values[i] == 1 else number_color
		label.double_sided = false
		label.shaded = true
		label.alpha_cut = Label3D.ALPHA_CUT_DISCARD
		label.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var up := Vector3.FORWARD if absf(normal.y) > 0.5 else Vector3.UP
		# Label3D は +Z 方向から読める。+Z を面の法線に合わせる。
		label.transform = Transform3D(Basis.looking_at(-normal, up), normal * (size * 0.5 + 0.004))
		_visual.add_child(label)
		_face_labels.append(label)
		# 6 と 9 を見間違えないよう、6 には下線を付ける
		var bar := MeshInstance3D.new()
		var bar_mesh := BoxMesh.new()
		bar_mesh.size = Vector3(size * 0.28, size * 0.035, 0.004)
		bar.mesh = bar_mesh
		var bar_mat := StandardMaterial3D.new()
		bar_mat.albedo_color = number_color
		bar.material_override = bar_mat
		bar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		bar.position = Vector3(0, -size * 0.3, 0)
		bar.visible = face_values[i] == 6
		label.add_child(bar)
		_underlines.append(bar)
	_normal_faces = face_values.duplicate()


## 6 面の数字を変える（スペシャル技用）。special = true なら金色に光るサイコロになる。
func set_face_values(values: Array[int], special: bool = false) -> void:
	face_values = values.duplicate()
	is_special = special
	for i in _face_labels.size():
		var v := face_values[i]
		var label := _face_labels[i]
		label.text = str(v)
		label.modulate = Color(0.45, 0.12, 0.02) if special else (one_color if v == 1 else number_color)
		_underlines[i].visible = v == 6
		(_underlines[i].material_override as StandardMaterial3D).albedo_color = label.modulate
	if special:
		_body_mat.albedo_color = Color(1.0, 0.8, 0.3)
		_body_mat.metallic = 0.6
		_body_mat.emission_enabled = true
		_body_mat.emission = Color(1.0, 0.65, 0.15)
		_body_mat.emission_energy_multiplier = 0.8
		_edge_mat.albedo_color = Color(0.9, 0.5, 0.1)
	else:
		_body_mat.albedo_color = body_color
		_body_mat.metallic = 0.0
		_body_mat.emission_enabled = false
		_edge_mat.albedo_color = Color(0.75, 0.68, 0.55)


## 標準のサイコロに戻す。
func restore_normal_faces() -> void:
	if is_special:
		set_face_values(_normal_faces, false)


# ------------------------------------------------------------------
# 出目判定
# ------------------------------------------------------------------
## 最も真上を向いている面のインデックス。
func get_top_face_index() -> int:
	var best_index := 0
	var best_dot := -INF
	var world_basis := global_transform.basis.orthonormalized()
	for i in FACE_NORMALS.size():
		var n: Vector3 = FACE_NORMALS[i]
		var d: float = (world_basis * n).dot(Vector3.UP)
		if d > best_dot:
			best_dot = d
			best_index = i
	return best_index


func get_top_alignment() -> float:
	var world_basis := global_transform.basis.orthonormalized()
	var n: Vector3 = FACE_NORMALS[get_top_face_index()]
	return (world_basis * n).dot(Vector3.UP)


func get_top_value() -> int:
	return face_values[get_top_face_index()]


# ------------------------------------------------------------------
# 振る
# ------------------------------------------------------------------
## プレイヤー側から敵側へ向かってサイコロを投げる。
func roll(throw_strength: float = 1.0) -> void:
	if is_rolling:
		return
	is_rolling = true
	_elapsed = 0.0
	_still_time = 0.0
	_nudges = 0
	_clear_highlight()

	var start := Vector3(randf_range(-0.8, 0.8), 1.6, 2.4)
	var start_rot := Basis.from_euler(Vector3(randf() * TAU, randf() * TAU, randf() * TAU))
	var lin := Vector3(
		randf_range(-1.8, 1.8),
		randf_range(5.5, 7.0),
		randf_range(-4.2, -3.0)
	) * throw_strength
	var spin_axis := Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
	if spin_axis.length_squared() < 0.01:
		spin_axis = Vector3.RIGHT
	var ang := spin_axis.normalized() * randf_range(16.0, 26.0)

	freeze = false
	_queue_state(Transform3D(start_rot, start), lin, ang)
	roll_started.emit()


## 振っていない時の定位置に戻す。
func reset_to_rest() -> void:
	is_rolling = false
	_pending_state = {}
	_clear_highlight()
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_transform = Transform3D(Basis.IDENTITY, rest_position)


func _queue_state(t: Transform3D, lin: Vector3, ang: Vector3) -> void:
	_pending_state = {"transform": t, "linear": lin, "angular": ang}
	sleeping = false


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# テレポートは物理ステップ内で行うのが安全。
	if _pending_state.is_empty():
		return
	state.transform = _pending_state["transform"]
	state.linear_velocity = _pending_state["linear"]
	state.angular_velocity = _pending_state["angular"]
	_pending_state = {}


func _physics_process(delta: float) -> void:
	if not is_rolling or not _pending_state.is_empty():
		return
	_elapsed += delta

	# 場外へ飛び出した場合は投げ直す（通常は壁があるので起きない）
	if global_position.y < -3.0 or global_position.length() > 30.0:
		is_rolling = false
		roll()
		return

	var moving := linear_velocity.length() > settle_linear_threshold \
		or angular_velocity.length() > settle_angular_threshold
	if _elapsed > min_roll_time and not moving:
		_still_time += delta
	else:
		_still_time = 0.0

	if _still_time >= settle_time:
		if get_top_alignment() < flat_threshold and _nudges < max_nudges:
			_nudge()
		else:
			_finish_roll()
	elif _elapsed > max_roll_time:
		if _nudges < max_nudges:
			_nudge()
			_elapsed = max_roll_time * 0.5
		else:
			_finish_roll()


func _nudge() -> void:
	_nudges += 1
	_still_time = 0.0
	apply_central_impulse(Vector3(randf_range(-0.6, 0.6), 3.5, randf_range(-0.6, 0.6)) * mass)
	apply_torque_impulse(Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * 0.4)


func _finish_roll() -> void:
	is_rolling = false
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	# 姿勢を固定して、判定した面と見た目を一致させる
	freeze = true
	var result := DiceResult.new(get_top_value(), dice_type, get_top_alignment())
	roll_finished.emit(result)


func _on_body_entered(_body: Node) -> void:
	var now := Time.get_ticks_msec()
	var speed := linear_velocity.length()
	if speed < 0.8 or now - _last_impact_ms < 90:
		return
	_last_impact_ms = now
	impact.emit(clampf(speed / 8.0, 0.0, 1.0))


# ------------------------------------------------------------------
# 演出
# ------------------------------------------------------------------
## 出目確定時の「タメ」演出。上面の数字を光らせてサイコロを弾ませる。
func play_result_highlight(color: Color = Color(1.0, 0.8, 0.2)) -> void:
	_clear_highlight()
	var label := _face_labels[get_top_face_index()]
	label.shaded = false
	label.outline_size = 24
	label.outline_modulate = color
	_highlight_tween = create_tween()
	_highlight_tween.tween_property(_visual, "scale", Vector3.ONE * 1.25, 0.12) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_highlight_tween.tween_property(_visual, "scale", Vector3.ONE, 0.25) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	await _highlight_tween.finished


func _clear_highlight() -> void:
	if _highlight_tween and _highlight_tween.is_valid():
		_highlight_tween.kill()
	if _visual:
		_visual.scale = Vector3.ONE
	for i in _face_labels.size():
		_face_labels[i].shaded = true
		_face_labels[i].outline_size = 0
