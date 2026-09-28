class_name BattleField
extends Node3D
## 3D バトルフィールド（空・ライト・床・サイコロ台・背景の装飾）をコードで構築する。

## サイコロが転がる範囲（見えない壁で囲う）
const TRAY_MIN := Vector2(-2.6, -2.1)   # (x, z)
const TRAY_MAX := Vector2(2.6, 2.9)

var enemy_spot := Vector3(0, 0, -4.7)
var player_spot := Vector3(0, 0, 4.4)
var dice_rest_position := Vector3(0, 0.5, 0.6)

## ステージごとの見た目（空・太陽・霧・松明の強さ）
const THEMES := {
	&"day": {
		"sky_top": Color(0.16, 0.24, 0.5), "sky_horizon": Color(0.93, 0.62, 0.45),
		"sun_color": Color(1.0, 0.93, 0.82), "sun_energy": 1.3, "ambient": 0.55,
		"fog_color": Color(0.75, 0.6, 0.6), "fog_density": 0.004, "torch": 2.2,
	},
	&"dusk": {
		"sky_top": Color(0.2, 0.12, 0.35), "sky_horizon": Color(1.0, 0.45, 0.25),
		"sun_color": Color(1.0, 0.68, 0.45), "sun_energy": 1.1, "ambient": 0.45,
		"fog_color": Color(0.8, 0.45, 0.35), "fog_density": 0.006, "torch": 2.8,
	},
	&"night": {
		"sky_top": Color(0.02, 0.03, 0.1), "sky_horizon": Color(0.18, 0.22, 0.4),
		"sun_color": Color(0.6, 0.7, 1.0), "sun_energy": 0.7, "ambient": 0.4,
		"fog_color": Color(0.2, 0.25, 0.4), "fog_density": 0.012, "torch": 3.5,
	},
	&"boss": {
		"sky_top": Color(0.12, 0.02, 0.05), "sky_horizon": Color(0.75, 0.18, 0.08),
		"sun_color": Color(1.0, 0.5, 0.35), "sun_energy": 1.0, "ambient": 0.45,
		"fog_color": Color(0.5, 0.12, 0.08), "fog_density": 0.01, "torch": 3.5,
	},
}

var _torch_lights: Array[OmniLight3D] = []
var _torch_energy := 2.2
var _time := 0.0
var _env: Environment
var _sky_mat: ProceduralSkyMaterial
var _sun: DirectionalLight3D


func _ready() -> void:
	_build_environment()
	_build_ground()
	_build_arena()
	_build_dice_tray()
	_build_decorations()


func _process(delta: float) -> void:
	_time += delta
	for i in _torch_lights.size():
		var l := _torch_lights[i]
		l.light_energy = _torch_energy + sin(_time * 9.0 + i * 1.7) * 0.25 + sin(_time * 23.0 + i) * 0.15


## ステージのテーマを適用する（_ready 後に呼ぶ）。
func apply_theme(theme_id: StringName) -> void:
	var theme: Dictionary = THEMES.get(theme_id, THEMES[&"day"])
	_sky_mat.sky_top_color = theme["sky_top"]
	_sky_mat.sky_horizon_color = theme["sky_horizon"]
	_sky_mat.ground_horizon_color = (theme["sky_horizon"] as Color).darkened(0.4)
	_sun.light_color = theme["sun_color"]
	_sun.light_energy = theme["sun_energy"]
	_env.ambient_light_energy = theme["ambient"]
	_env.fog_light_color = theme["fog_color"]
	_env.fog_density = theme["fog_density"]
	_torch_energy = theme["torch"]


# ------------------------------------------------------------------
func _build_environment() -> void:
	var sky_mat := ProceduralSkyMaterial.new()
	_sky_mat = sky_mat
	sky_mat.sky_top_color = Color(0.16, 0.24, 0.5)
	sky_mat.sky_horizon_color = Color(0.93, 0.62, 0.45)
	sky_mat.ground_horizon_color = Color(0.5, 0.4, 0.38)
	sky_mat.ground_bottom_color = Color(0.12, 0.1, 0.12)
	sky_mat.sun_angle_max = 30.0
	var sky := Sky.new()
	sky.sky_material = sky_mat

	var env := Environment.new()
	_env = env
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.55
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 0.95
	env.glow_enabled = true
	env.glow_intensity = 0.5
	env.glow_bloom = 0.05
	env.fog_enabled = true
	env.fog_light_color = Color(0.75, 0.6, 0.6)
	env.fog_density = 0.004
	env.fog_sky_affect = 0.3

	var world_env := WorldEnvironment.new()
	world_env.name = "WorldEnvironment"
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	_sun = sun
	sun.name = "Sun"
	sun.light_color = Color(1.0, 0.93, 0.82)
	sun.light_energy = 1.3
	sun.shadow_enabled = true
	sun.shadow_blur = 1.5
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.directional_shadow_max_distance = 40.0
	sun.rotation_degrees = Vector3(-55, 35, 0)
	add_child(sun)


func _build_ground() -> void:
	# 物理用の床（全面）
	var floor_body := StaticBody3D.new()
	floor_body.name = "Floor"
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(60, 1, 60)
	shape.shape = box
	shape.position = Vector3(0, -0.5, 0)
	floor_body.add_child(shape)
	add_child(floor_body)

	# 草地
	var noise := FastNoiseLite.new()
	noise.frequency = 0.02
	var grad := Gradient.new()
	grad.set_color(0, Color(0.16, 0.3, 0.14))
	grad.set_color(1, Color(0.3, 0.46, 0.2))
	var tex := NoiseTexture2D.new()
	tex.noise = noise
	tex.color_ramp = grad
	tex.seamless = true
	var grass := StandardMaterial3D.new()
	grass.albedo_texture = tex
	grass.uv1_scale = Vector3(6, 6, 1)
	grass.roughness = 0.95
	var plane := PlaneMesh.new()
	plane.size = Vector2(120, 120)
	_mesh(plane, grass, Vector3(0, -0.02, 0))


func _build_arena() -> void:
	var stone_noise := FastNoiseLite.new()
	stone_noise.frequency = 0.08
	stone_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	var stone_grad := Gradient.new()
	stone_grad.set_color(0, Color(0.42, 0.4, 0.42))
	stone_grad.set_color(1, Color(0.62, 0.58, 0.55))
	var stone_tex := NoiseTexture2D.new()
	stone_tex.noise = stone_noise
	stone_tex.color_ramp = stone_grad
	stone_tex.seamless = true
	var stone := StandardMaterial3D.new()
	stone.albedo_texture = stone_tex
	stone.uv1_scale = Vector3(3, 3, 1)
	stone.roughness = 0.85

	var rim := StandardMaterial3D.new()
	rim.albedo_color = Color(0.32, 0.29, 0.3)
	rim.roughness = 0.9

	var outer := CylinderMesh.new()
	outer.top_radius = 7.4
	outer.bottom_radius = 7.6
	outer.height = 0.3
	outer.radial_segments = 16
	_mesh(outer, rim, Vector3(0, -0.17, 0))
	var inner := CylinderMesh.new()
	inner.top_radius = 7.0
	inner.bottom_radius = 7.0
	inner.height = 0.3
	inner.radial_segments = 16
	_mesh(inner, stone, Vector3(0, -0.15, 0))

	# 敵・プレイヤーの足元の魔法陣風リング
	_ring(enemy_spot, Color(0.9, 0.25, 0.3), 1.5)
	_ring(player_spot, Color(0.3, 0.6, 1.0), 1.0)


func _ring(pos: Vector3, color: Color, radius: float) -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 1.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var torus := TorusMesh.new()
	torus.inner_radius = radius - 0.06
	torus.outer_radius = radius
	torus.rings = 48
	_mesh(torus, mat, pos + Vector3(0, 0.03, 0)).scale = Vector3(1, 0.2, 1)


func _build_dice_tray() -> void:
	var size_x := TRAY_MAX.x - TRAY_MIN.x
	var size_z := TRAY_MAX.y - TRAY_MIN.y
	var center := Vector3((TRAY_MAX.x + TRAY_MIN.x) * 0.5, 0, (TRAY_MAX.y + TRAY_MIN.y) * 0.5)

	# フェルトのマット
	var felt := StandardMaterial3D.new()
	felt.albedo_color = Color(0.36, 0.1, 0.16)
	felt.roughness = 1.0
	var felt_mesh := PlaneMesh.new()
	felt_mesh.size = Vector2(size_x, size_z)
	_mesh(felt_mesh, felt, center + Vector3(0, 0.02, 0))

	# 木の縁（見た目）
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.45, 0.27, 0.13)
	wood.roughness = 0.7
	var gold := StandardMaterial3D.new()
	gold.albedo_color = Color(0.95, 0.72, 0.25)
	gold.metallic = 0.9
	gold.roughness = 0.3
	var t := 0.18
	var h := 0.28
	var sides := [
		[Vector3(center.x, h * 0.5, TRAY_MIN.y - t * 0.5), Vector3(size_x + t * 2, h, t)],
		[Vector3(center.x, h * 0.5, TRAY_MAX.y + t * 0.5), Vector3(size_x + t * 2, h, t)],
		[Vector3(TRAY_MIN.x - t * 0.5, h * 0.5, center.z), Vector3(t, h, size_z)],
		[Vector3(TRAY_MAX.x + t * 0.5, h * 0.5, center.z), Vector3(t, h, size_z)],
	]
	for side in sides:
		var bm := BoxMesh.new()
		bm.size = side[1]
		_mesh(bm, wood, side[0])
	for cx in [TRAY_MIN.x - t * 0.5, TRAY_MAX.x + t * 0.5]:
		for cz in [TRAY_MIN.y - t * 0.5, TRAY_MAX.y + t * 0.5]:
			var knob := SphereMesh.new()
			knob.radius = 0.14
			knob.height = 0.28
			_mesh(knob, gold, Vector3(cx, h + 0.04, cz))

	# 見えない壁（サイコロが外へ出ないように高めに）
	var walls := StaticBody3D.new()
	walls.name = "DiceWalls"
	add_child(walls)
	var wall_h := 8.0
	var wall_defs := [
		[Vector3(center.x, wall_h * 0.5, TRAY_MIN.y - 0.5), Vector3(size_x + 2, wall_h, 1)],
		[Vector3(center.x, wall_h * 0.5, TRAY_MAX.y + 0.5), Vector3(size_x + 2, wall_h, 1)],
		[Vector3(TRAY_MIN.x - 0.5, wall_h * 0.5, center.z), Vector3(1, wall_h, size_z + 2)],
		[Vector3(TRAY_MAX.x + 0.5, wall_h * 0.5, center.z), Vector3(1, wall_h, size_z + 2)],
		[Vector3(center.x, wall_h + 0.5, center.z), Vector3(size_x + 2, 1, size_z + 2)],
	]
	var wall_mat := PhysicsMaterial.new()
	wall_mat.bounce = 0.4
	wall_mat.friction = 0.3
	walls.physics_material_override = wall_mat
	for def in wall_defs:
		var cs := CollisionShape3D.new()
		var b := BoxShape3D.new()
		b.size = def[1]
		cs.shape = b
		cs.position = def[0]
		walls.add_child(cs)


func _build_decorations() -> void:
	var pillar_mat := StandardMaterial3D.new()
	pillar_mat.albedo_color = Color(0.7, 0.66, 0.6)
	pillar_mat.roughness = 0.8
	var cap_mat := StandardMaterial3D.new()
	cap_mat.albedo_color = Color(0.55, 0.52, 0.5)
	var flame_mat := StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.6, 0.15)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.5, 0.1)
	flame_mat.emission_energy_multiplier = 4.0
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	# 円形に並ぶ石柱＋松明
	var count := 8
	for i in count:
		var ang := TAU * float(i) / count + PI / count
		var pos := Vector3(sin(ang) * 7.2, 0, cos(ang) * 7.2)
		# 手前（カメラ側）の柱は視界を塞ぐので置かない
		if pos.z > 3.0:
			continue
		var height := 3.2
		var column := CylinderMesh.new()
		column.top_radius = 0.35
		column.bottom_radius = 0.42
		column.height = height
		column.radial_segments = 8
		_mesh(column, pillar_mat, pos + Vector3(0, height * 0.5, 0))
		var cap := BoxMesh.new()
		cap.size = Vector3(1.0, 0.22, 1.0)
		_mesh(cap, cap_mat, pos + Vector3(0, height + 0.11, 0))
		var flame := SphereMesh.new()
		flame.radius = 0.18
		flame.height = 0.5
		_mesh(flame, flame_mat, pos + Vector3(0, height + 0.45, 0)).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var light := OmniLight3D.new()
		light.light_color = Color(1.0, 0.6, 0.3)
		light.omni_range = 6.0
		light.light_energy = 2.2
		light.position = pos + Vector3(0, height + 0.6, 0)
		add_child(light)
		_torch_lights.append(light)

	# 木（低ポリ）
	var trunk_mat := StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.35, 0.22, 0.12)
	var leaf_mat := StandardMaterial3D.new()
	leaf_mat.albedo_color = Color(0.13, 0.38, 0.2)
	leaf_mat.roughness = 0.9
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	for i in 26:
		var ang := rng.randf_range(-PI * 0.75, PI * 0.75) + PI
		var dist := rng.randf_range(11.0, 22.0)
		var pos := Vector3(sin(ang) * dist, 0, cos(ang) * dist)
		var s := rng.randf_range(0.8, 1.6)
		var trunk := CylinderMesh.new()
		trunk.top_radius = 0.15 * s
		trunk.bottom_radius = 0.22 * s
		trunk.height = 1.2 * s
		_mesh(trunk, trunk_mat, pos + Vector3(0, 0.6 * s, 0))
		for k in 2:
			var cone := CylinderMesh.new()
			cone.top_radius = 0.0
			cone.bottom_radius = (1.3 - k * 0.35) * s
			cone.height = 1.8 * s
			cone.radial_segments = 7
			_mesh(cone, leaf_mat, pos + Vector3(0, (1.6 + k * 0.9) * s, 0))

	# 岩
	var rock_mat := StandardMaterial3D.new()
	rock_mat.albedo_color = Color(0.45, 0.43, 0.45)
	for i in 10:
		var ang := rng.randf_range(0, TAU)
		var dist := rng.randf_range(8.2, 10.5)
		var rock := SphereMesh.new()
		rock.radius = rng.randf_range(0.3, 0.7)
		rock.height = rock.radius * 1.4
		rock.radial_segments = 6
		rock.rings = 3
		_mesh(rock, rock_mat, Vector3(sin(ang) * dist, 0.1, cos(ang) * dist))

	# 遠景の山
	var mountain_mat := StandardMaterial3D.new()
	mountain_mat.albedo_color = Color(0.3, 0.3, 0.42)
	mountain_mat.roughness = 1.0
	for i in 7:
		var x := -36.0 + i * 12.0 + rng.randf_range(-3, 3)
		var mh := rng.randf_range(10, 20)
		var m := CylinderMesh.new()
		m.top_radius = 0.0
		m.bottom_radius = rng.randf_range(8, 13)
		m.height = mh
		m.radial_segments = 6
		_mesh(m, mountain_mat, Vector3(x, mh * 0.5 - 0.5, -45 + rng.randf_range(-4, 4)))


func _mesh(mesh: Mesh, mat: Material, pos: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	add_child(mi)
	return mi
