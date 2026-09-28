class_name HitEffect
extends Node3D
## 攻撃ヒット時のエフェクト（火花パーティクル＋広がるリング＋斬撃の光）。一定時間後に自動で消える。


static func spawn(parent: Node, world_position: Vector3, color: Color, power: float = 1.0) -> HitEffect:
	var fx := HitEffect.new()
	fx.position = world_position
	parent.add_child(fx)
	fx._build(color, power)
	return fx


func _build(color: Color, power: float) -> void:
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.albedo_color = color
	glow.emission_enabled = true
	glow.emission = color
	glow.emission_energy_multiplier = 3.0
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED

	# 火花
	var sparks := CPUParticles3D.new()
	var spark_mesh := SphereMesh.new()
	spark_mesh.radius = 0.06
	spark_mesh.height = 0.12
	spark_mesh.radial_segments = 6
	spark_mesh.rings = 3
	spark_mesh.material = glow
	sparks.mesh = spark_mesh
	sparks.amount = int(24 * power)
	sparks.one_shot = true
	sparks.explosiveness = 1.0
	sparks.lifetime = 0.6
	sparks.direction = Vector3(0, 1, 0.3)
	sparks.spread = 180.0
	sparks.initial_velocity_min = 3.0 * power
	sparks.initial_velocity_max = 6.0 * power
	sparks.gravity = Vector3(0, -12, 0)
	sparks.scale_amount_min = 0.6
	sparks.scale_amount_max = 1.4
	var curve := Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(1, 0))
	sparks.scale_amount_curve = curve
	sparks.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(sparks)
	sparks.emitting = true

	# 衝撃リング
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.35
	torus.outer_radius = 0.45
	ring.mesh = torus
	var ring_mat := glow.duplicate() as StandardMaterial3D
	ring.material_override = ring_mat
	ring.rotation_degrees = Vector3(90, 0, 0)
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(ring)

	# 斬撃の光（細長い板）
	var slash := MeshInstance3D.new()
	var slash_mesh := BoxMesh.new()
	slash_mesh.size = Vector3(2.4 * power, 0.12, 0.02)
	slash.mesh = slash_mesh
	var slash_mat := glow.duplicate() as StandardMaterial3D
	slash_mat.albedo_color = Color(1, 1, 1)
	slash.material_override = slash_mat
	slash.rotation_degrees = Vector3(0, 0, randf_range(25, 55) * (1 if randf() < 0.5 else -1))
	slash.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(slash)

	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = 4.0 * power
	light.omni_range = 4.0
	add_child(light)

	var t := create_tween().set_parallel(true)
	t.tween_property(ring, "scale", Vector3.ONE * 3.2 * power, 0.35).set_ease(Tween.EASE_OUT)
	t.tween_property(ring_mat, "albedo_color:a", 0.0, 0.35)
	t.tween_property(slash, "scale", Vector3(1.3, 0.2, 1), 0.25).set_ease(Tween.EASE_OUT)
	t.tween_property(slash_mat, "albedo_color:a", 0.0, 0.25)
	t.tween_property(light, "light_energy", 0.0, 0.4)
	t.chain().tween_interval(0.5)
	t.chain().tween_callback(queue_free)
