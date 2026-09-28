class_name ModelKit
extends RefCounted
## 敵モデルを Godot 標準 Mesh の組み合わせで作るための道具箱。
##
## 色は「役割（role）」で指定する（&"body", &"belly", &"eye_glow" など）。
## 役割 → 色の対応はパレット（Dictionary）で渡すので、同じ形のまま色違いを作れる。
## パレットの値は Color か、{"color", "rough", "metal", "emission", "unshaded", "double", "rim"} の Dictionary。
##
## 座標の約束: 地面が y = 0、敵の正面（プレイヤー側）が +Z。

## パレットに無い役割はここの色を使う
const DEFAULT_ROLES := {
	&"eye_white": {"color": Color(1, 1, 1), "rough": 0.2},
	&"pupil": {"color": Color(0.04, 0.04, 0.06), "rough": 0.1},
	&"shine": {"color": Color(1, 1, 1), "unshaded": true},
	&"dark": {"color": Color(0.1, 0.08, 0.1), "rough": 0.9},
	&"mouth": {"color": Color(0.32, 0.04, 0.1), "rough": 0.5},
	&"tongue": {"color": Color(0.85, 0.3, 0.4), "rough": 0.4},
	&"tooth": {"color": Color(0.96, 0.94, 0.86), "rough": 0.4},
	&"metal": {"color": Color(0.72, 0.74, 0.8), "metal": 0.85, "rough": 0.3},
	&"gold": {"color": Color(1.0, 0.78, 0.28), "metal": 0.9, "rough": 0.28},
	&"wood": {"color": Color(0.5, 0.33, 0.18), "rough": 0.85},
	&"bone": {"color": Color(0.93, 0.9, 0.8), "rough": 0.55},
	&"leather": {"color": Color(0.42, 0.26, 0.14), "rough": 0.85},
	&"eye_glow": {"color": Color(1.0, 0.25, 0.15), "emission": 3.0},
	&"glow": {"color": Color(1.0, 0.85, 0.2), "emission": 2.5},
	&"gem": {"color": Color(0.3, 0.8, 1.0), "emission": 1.2, "rough": 0.1},
	&"blush": {"color": Color(1.0, 0.55, 0.6), "rough": 0.6},
}

var palette: Dictionary
## 生成したマテリアル（被弾フラッシュ・撃破フェード用に BattleActor が使う）
var materials: Array[StandardMaterial3D] = []
## アニメーションさせる部位
##   wings:  Array of [pivot: Node3D, side: float]  … Z 軸回転で羽ばたく
##   weapon: Node3D  … X 軸回転で振る
##   tail:   Node3D  … Y 軸回転で振る
##   wing_speed: 羽ばたき 1 回の秒数
var parts := {"wings": [], "weapon": null, "tail": null, "wing_speed": 0.6, "wing_angle": 25.0}
## パレットにも既定にも無かった役割（テストで検出する）
var missing_roles: Array[StringName] = []

var _cache := {}


func _init(p_palette: Dictionary = {}) -> void:
	palette = p_palette


# ------------------------------------------------------------------
# マテリアル
# ------------------------------------------------------------------
func mat(role: StringName) -> StandardMaterial3D:
	if _cache.has(role):
		return _cache[role]
	var spec: Variant = palette.get(role, DEFAULT_ROLES.get(role, null))
	if spec == null:
		missing_roles.append(role)
		spec = Color.MAGENTA
	if spec is Color:
		spec = {"color": spec}
	var d: Dictionary = spec
	var m := StandardMaterial3D.new()
	var c: Color = d.get("color", Color.WHITE)
	m.albedo_color = c
	m.roughness = d.get("rough", 0.6)
	m.metallic = d.get("metal", 0.0)
	if d.has("emission"):
		m.emission_enabled = true
		m.emission = d.get("emission_color", c)
		m.emission_energy_multiplier = d["emission"]
	if d.get("unshaded", false):
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if c.a < 0.999:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if d.get("double", false) or c.a < 0.999:
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
	if d.has("rim"):
		m.rim_enabled = true
		m.rim = d["rim"]
		m.rim_tint = 0.4
	if d.has("clearcoat"):
		m.clearcoat_enabled = true
		m.clearcoat = d["clearcoat"]
	materials.append(m)
	_cache[role] = m
	return m


# ------------------------------------------------------------------
# 基本形状
# ------------------------------------------------------------------
func add(parent: Node3D, mesh: Mesh, role: StringName, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO, scl: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat(role)
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.scale = scl
	if mat(role).transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi


func sphere(parent: Node3D, role: StringName, pos: Vector3, r: float, scl: Vector3 = Vector3.ONE, rot_deg: Vector3 = Vector3.ZERO, segments: int = 24) -> MeshInstance3D:
	var m := SphereMesh.new()
	m.radius = r
	m.height = r * 2.0
	m.radial_segments = segments
	m.rings = maxi(segments / 2, 4)
	return add(parent, m, role, pos, rot_deg, scl)


## ドーム（半球）。pos が平らな底面の中心。
func dome(parent: Node3D, role: StringName, pos: Vector3, r: float, h: float, rot_deg: Vector3 = Vector3.ZERO, scl: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var m := SphereMesh.new()
	m.radius = r
	m.height = h
	m.is_hemisphere = true
	m.radial_segments = 24
	m.rings = 8
	return add(parent, m, role, pos, rot_deg, scl)


func box(parent: Node3D, role: StringName, pos: Vector3, size: Vector3, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var m := BoxMesh.new()
	m.size = size
	return add(parent, m, role, pos, rot_deg)


func capsule(parent: Node3D, role: StringName, pos: Vector3, r: float, h: float, rot_deg: Vector3 = Vector3.ZERO, scl: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var m := CapsuleMesh.new()
	m.radius = r
	m.height = maxf(h, r * 2.0 + 0.001)
	return add(parent, m, role, pos, rot_deg, scl)


func cyl(parent: Node3D, role: StringName, pos: Vector3, r_top: float, r_bottom: float, h: float, rot_deg: Vector3 = Vector3.ZERO, segments: int = 16) -> MeshInstance3D:
	var m := CylinderMesh.new()
	m.top_radius = r_top
	m.bottom_radius = r_bottom
	m.height = h
	m.radial_segments = segments
	m.rings = 1
	return add(parent, m, role, pos, rot_deg)


## 円錐（先端が +Y）。pos は中心。
func cone(parent: Node3D, role: StringName, pos: Vector3, r: float, h: float, rot_deg: Vector3 = Vector3.ZERO, segments: int = 10) -> MeshInstance3D:
	return cyl(parent, role, pos, 0.0, r, h, rot_deg, segments)


func torus(parent: Node3D, role: StringName, pos: Vector3, r_in: float, r_out: float, rot_deg: Vector3 = Vector3.ZERO, scl: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var m := TorusMesh.new()
	m.inner_radius = r_in
	m.outer_radius = r_out
	m.rings = 24
	m.ring_segments = 8
	return add(parent, m, role, pos, rot_deg, scl)


func pivot(parent: Node3D, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO) -> Node3D:
	var p := Node3D.new()
	p.position = pos
	p.rotation_degrees = rot_deg
	parent.add_child(p)
	return p


# ------------------------------------------------------------------
# 2 点間をつなぐ形状（手足・しっぽ・触手など）
# ------------------------------------------------------------------
static func basis_from_up(dir: Vector3) -> Basis:
	var d := dir.normalized()
	var dot := d.dot(Vector3.UP)
	if dot > 0.9999:
		return Basis.IDENTITY
	if dot < -0.9999:
		return Basis(Vector3.RIGHT, PI)
	return Basis(Quaternion(Vector3.UP, d))


## a から b へ伸びる丸い棒（カプセル）。
func limb(parent: Node3D, role: StringName, a: Vector3, b: Vector3, r: float) -> MeshInstance3D:
	var m := CapsuleMesh.new()
	m.radius = r
	m.height = maxf(a.distance_to(b) + r * 2.0, r * 2.0 + 0.001)
	m.radial_segments = 12
	m.rings = 4
	var mi := add(parent, m, role, (a + b) * 0.5)
	mi.basis = basis_from_up(b - a)
	return mi


## a から b へ伸びる、太さが変わる棒（a 側の半径 ra、b 側の半径 rb）。rb = 0 でトゲ・ツノ。
func bone(parent: Node3D, role: StringName, a: Vector3, b: Vector3, ra: float, rb: float, segments: int = 10) -> MeshInstance3D:
	var m := CylinderMesh.new()
	m.bottom_radius = ra
	m.top_radius = rb
	m.height = maxf(a.distance_to(b), 0.001)
	m.radial_segments = segments
	m.rings = 1
	var mi := add(parent, m, role, (a + b) * 0.5)
	mi.basis = basis_from_up(b - a)
	return mi


## ツノ・トゲ（base から tip へ）。
func spike(parent: Node3D, role: StringName, base: Vector3, tip: Vector3, r: float) -> MeshInstance3D:
	return bone(parent, role, base, tip, r, 0.0, 8)


## 点列をなめらかにつなぐ（しっぽ・触手・鼻など）。太さは r0 → r1 に変化。
func chain(parent: Node3D, role: StringName, points: Array, r0: float, r1: float) -> void:
	var n := points.size()
	for i in n - 1:
		var t0 := float(i) / (n - 1)
		var t1 := float(i + 1) / (n - 1)
		var ra := lerpf(r0, r1, t0)
		var rb := lerpf(r0, r1, t1)
		bone(parent, role, points[i], points[i + 1], ra, rb, 10)
		if i > 0:
			sphere(parent, role, points[i], ra, Vector3.ONE, Vector3.ZERO, 10)
	if r1 > 0.01:
		sphere(parent, role, points[n - 1], r1, Vector3.ONE, Vector3.ZERO, 10)


## 始点 start から dir 方向へ曲がりながら伸びる点列（しっぽ・触手用）。
static func curl_points(start: Vector3, dir: Vector3, bend: Vector3, length: float, count: int) -> Array:
	var pts := [start]
	var d := dir.normalized()
	var step := length / count
	var p := start
	for i in count:
		d = (d + bend * (1.0 / count)).normalized()
		p += d * step
		pts.append(p)
	return pts


# ------------------------------------------------------------------
# 顔パーツ
# ------------------------------------------------------------------
## 両目。center は両目の中間（顔の表面上）、spacing は目の間隔。
## style: &"cute"（白目＋黒目＋ハイライト）/ &"glow"（光る目）/ &"angry"（cute＋つり眉）/ &"dot"（黒い点）
func eyes(parent: Node3D, center: Vector3, spacing: float, r: float, style: StringName = &"cute", brow_role: StringName = &"dark") -> void:
	for side in [-1.0, 1.0]:
		var p: Vector3 = center + Vector3(side * spacing * 0.5, 0, 0)
		match style:
			&"glow":
				sphere(parent, &"eye_glow", p, r, Vector3(1, 0.8, 0.6), Vector3.ZERO, 12)
			&"dot":
				sphere(parent, &"pupil", p, r, Vector3(1, 1.2, 0.6), Vector3.ZERO, 12)
			_:
				sphere(parent, &"eye_white", p, r, Vector3(1, 1.1, 0.7), Vector3.ZERO, 16)
				sphere(parent, &"pupil", p + Vector3(side * -r * 0.1, -r * 0.05, r * 0.5), r * 0.55, Vector3(1, 1.1, 0.6), Vector3.ZERO, 12)
				sphere(parent, &"shine", p + Vector3(r * 0.2, r * 0.3, r * 0.8), r * 0.18, Vector3.ONE, Vector3.ZERO, 8)
				if style == &"angry":
					box(parent, brow_role, p + Vector3(0, r * 1.2, r * 0.3), Vector3(r * 2.2, r * 0.45, r * 0.4), Vector3(0, 0, side * 20.0))


## 楕円体（中心 center、半径 radii）の表面上の点。az = 正面からの水平角、el = 仰角（度）。
static func surface_point(center: Vector3, radii: Vector3, az_deg: float, el_deg: float) -> Vector3:
	var az := deg_to_rad(az_deg)
	var el := deg_to_rad(el_deg)
	return center + Vector3(sin(az) * cos(el) * radii.x, sin(el) * radii.y, cos(az) * cos(el) * radii.z)


## 楕円体の表面に、表面に沿った向きで部品（平たい球）を貼り付ける（模様・ウロコ・斑点）。
func stud(parent: Node3D, role: StringName, center: Vector3, radii: Vector3, az_deg: float, el_deg: float, size: Vector3) -> MeshInstance3D:
	var p := surface_point(center, radii, az_deg, el_deg)
	var q := p - center
	var n := Vector3(q.x / (radii.x * radii.x), q.y / (radii.y * radii.y), q.z / (radii.z * radii.z))
	var mi := sphere(parent, role, p, 1.0, Vector3.ONE, Vector3.ZERO, 12)
	mi.basis = basis_from_up(n) * Basis.from_scale(size)
	return mi


## 楕円体の表面から外向きにトゲを生やす。
func spike_out(parent: Node3D, role: StringName, center: Vector3, radii: Vector3, az_deg: float, el_deg: float, length: float, r: float) -> MeshInstance3D:
	var p := surface_point(center, radii, az_deg, el_deg)
	var q := p - center
	var n := Vector3(q.x / (radii.x * radii.x), q.y / (radii.y * radii.y), q.z / (radii.z * radii.z)).normalized()
	return spike(parent, role, p - n * r * 0.5, p + n * length, r)


## 左右対称に置くためのヘルパー（x を反転した 2 つを返す）。
static func mirror(v: Vector3) -> Array:
	return [v, Vector3(-v.x, v.y, v.z)]


## 翼などの部位を登録する。
func add_wing(p: Node3D, side: float) -> void:
	(parts["wings"] as Array).append([p, side])


# ------------------------------------------------------------------
# サイズ計測
# ------------------------------------------------------------------
## root のローカル座標系で、配下の全メッシュを包む AABB を求める（ツリー外でも動く）。
static func compute_aabb(root: Node3D) -> AABB:
	var result := AABB()
	var first := true
	var stack: Array = [[root, Transform3D.IDENTITY]]
	while not stack.is_empty():
		var item: Array = stack.pop_back()
		var node: Node = item[0]
		var xf: Transform3D = item[1]
		if node is MeshInstance3D and (node as MeshInstance3D).mesh:
			var box_aabb: AABB = xf * (node as MeshInstance3D).get_aabb()
			if first:
				result = box_aabb
				first = false
			else:
				result = result.merge(box_aabb)
		for child in node.get_children():
			if child is Node3D:
				stack.append([child, xf * (child as Node3D).transform])
	return result
