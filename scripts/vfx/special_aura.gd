class_name SpecialAura
extends Node3D
## スペシャル技発動時の、主人公を包む光の柱・広がる輪・立ちのぼる光の粒。


static func spawn(parent: Node, world_position: Vector3, color: Color, duration: float = 2.4) -> SpecialAura:
	var aura := SpecialAura.new()
	aura.position = world_position
	parent.add_child(aura)
	aura._build(color, duration)
	return aura


func _glow(color: Color, energy: float, alpha: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.albedo_color = Color(color.r, color.g, color.b, alpha)
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = energy
	return m


func _build(color: Color, duration: float) -> void:
	# 光の柱
	var pillar := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.75
	cyl.bottom_radius = 0.95
	cyl.height = 7.0
	cyl.cap_top = false
	cyl.cap_bottom = false
	pillar.mesh = cyl
	var pillar_mat := _glow(color, 1.2, 0.16)
	pillar.material_override = pillar_mat
	pillar.position.y = 3.5
	pillar.scale = Vector3(0.05, 1, 0.05)
	pillar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(pillar)
	var core := MeshInstance3D.new()
	var core_mesh := CylinderMesh.new()
	core_mesh.top_radius = 0.18
	core_mesh.bottom_radius = 0.28
	core_mesh.height = 7.0
	core.mesh = core_mesh
	var core_mat := _glow(Color(1, 1, 0.9), 1.5, 0.12)
	core.material_override = core_mat
	core.position.y = 3.5
	core.scale = Vector3(0.05, 1, 0.05)
	core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(core)

	# 足元で広がる輪（2 重）
	var rings: Array[MeshInstance3D] = []
	for i in 2:
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = 0.9
		torus.outer_radius = 1.05
		torus.rings = 48
		ring.mesh = torus
		ring.material_override = _glow(color, 3.0, 0.9)
		ring.position.y = 0.05 + i * 0.02
		ring.scale = Vector3(0.2, 0.3, 0.2)
		ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(ring)
		rings.append(ring)

	# 立ちのぼる光の粒
	var particles := CPUParticles3D.new()
	var dot := SphereMesh.new()
	dot.radius = 0.06
	dot.height = 0.12
	dot.radial_segments = 6
	dot.rings = 3
	dot.material = _glow(color.lightened(0.3), 4.0, 1.0)
	particles.mesh = dot
	particles.amount = 60
	particles.lifetime = 1.2
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
	particles.emission_ring_axis = Vector3.UP
	particles.emission_ring_radius = 1.1
	particles.emission_ring_inner_radius = 0.3
	particles.emission_ring_height = 0.1
	particles.direction = Vector3.UP
	particles.spread = 10.0
	particles.gravity = Vector3(0, 3.0, 0)
	particles.initial_velocity_min = 1.5
	particles.initial_velocity_max = 4.0
	var curve := Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(1, 0))
	particles.scale_amount_curve = curve
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(particles)
	particles.emitting = true

	var light := OmniLight3D.new()
	light.light_color = color
	light.omni_range = 7.0
	light.light_energy = 0.0
	light.position.y = 1.5
	add_child(light)

	var t := create_tween().set_parallel(true)
	t.tween_property(pillar, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(core, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(light, "light_energy", 3.5, 0.3)
	for i in rings.size():
		t.tween_property(rings[i], "scale", Vector3(3.2, 0.3, 3.2), 0.9).set_delay(i * 0.25).set_ease(Tween.EASE_OUT)
		t.tween_property(rings[i].material_override, "albedo_color:a", 0.0, 0.9).set_delay(i * 0.25)
	t.tween_method(func(v: float) -> void: pillar.rotation.y = v, 0.0, TAU, duration)
	t.chain().tween_property(pillar_mat, "albedo_color:a", 0.0, 0.4)
	t.parallel().tween_property(core_mat, "albedo_color:a", 0.0, 0.4)
	t.parallel().tween_property(light, "light_energy", 0.0, 0.4)
	t.parallel().tween_property(pillar, "scale:x", 0.2, 0.4)
	t.parallel().tween_property(pillar, "scale:z", 0.2, 0.4)
	t.tween_callback(func() -> void: particles.emitting = false)
	t.tween_interval(1.2)
	t.tween_callback(queue_free)
