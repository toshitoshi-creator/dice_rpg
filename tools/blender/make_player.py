# DICE BATTLE - 主人公（勇者）を Blender で作るスクリプト
#
# 設定資料「3D モデル制作イメージ - 勇者 -」をもとにした約 3 頭身のちびキャラ:
#   ツンツンの茶髪 / 青い宝石のサークレット / 大きな茶色の目 / 赤いスカーフとマント /
#   青いチュニック / 茶色のベルト・ブーツ / 青い宝石の剣 / 金の鳥の紋章の青い盾
#
# 使い方:
#   1. Blender（4.2 以降）で上のタブ「Scripting」→「+ 新規」→ このファイルの中身を貼り付けて「▶」
#   2. 「DiceBattle_Player」コレクションに勇者ができ、player.glb が書き出される
#      （.blend を保存していればその隣、未保存ならホームフォルダ。EXPORT_DIR で変更可）
#   3. player.glb をリポジトリの assets/models/player.glb に置く
#
# ゲーム側の約束:
#   - 正面は「正面ビュー（テンキー 1）」から見える側（-Y 方向）、足元は Z = 0。大きさは自由
#   - 「Weapon」（空の Empty）とその子（右腕と剣）が、攻撃時に Weapon の原点（右肩）を中心に振られる
#
# 何度実行しても、前回このスクリプトが作ったものだけを消して作り直します。
# 先頭の COLORS を変えると色を変えられます。

import math
import os

import bpy  # noqa: I001  (bpy を先に読み込む)
import bmesh
from mathutils import Euler, Matrix, Vector

COLLECTION = "DiceBattle_Player"
FILE_NAME = "player.glb"
EXPORT_DIR = ""  # 空なら .blend と同じフォルダ（未保存ならホームフォルダ）

# マテリアル名: (色 RGB（画面で見える色, 0〜1）, 金属っぽさ, ざらつき, 発光の強さ)
COLORS = {
    "skin": ((1.0, 0.8, 0.66), 0.0, 0.55, 0.0),
    "blush": ((1.0, 0.58, 0.55), 0.0, 0.6, 0.0),
    "hair": ((0.42, 0.24, 0.12), 0.0, 0.6, 0.0),
    "brow": ((0.3, 0.16, 0.08), 0.0, 0.7, 0.0),
    "eye_white": ((1.0, 1.0, 1.0), 0.0, 0.3, 0.0),
    "iris": ((0.42, 0.24, 0.1), 0.0, 0.2, 0.0),
    "pupil": ((0.08, 0.04, 0.03), 0.0, 0.2, 0.0),
    "shine": ((1.0, 1.0, 1.0), 0.0, 0.1, 1.5),
    "mouth": ((0.55, 0.25, 0.22), 0.0, 0.6, 0.0),
    "tunic": ((0.16, 0.32, 0.72), 0.0, 0.75, 0.0),
    "trim": ((0.93, 0.9, 0.82), 0.0, 0.8, 0.0),
    "pants": ((0.18, 0.2, 0.3), 0.0, 0.8, 0.0),
    "red": ((0.78, 0.1, 0.1), 0.0, 0.85, 0.0),
    "leather": ((0.45, 0.27, 0.13), 0.0, 0.7, 0.0),
    "boots": ((0.5, 0.3, 0.15), 0.0, 0.65, 0.0),
    "gold": ((1.0, 0.76, 0.3), 0.9, 0.3, 0.0),
    "gem": ((0.1, 0.35, 1.0), 0.2, 0.1, 0.6),
    "steel": ((0.86, 0.88, 0.92), 0.85, 0.22, 0.0),
    "shield": ((0.15, 0.36, 0.8), 0.1, 0.45, 0.0),
}

# 裏側も表示する（マント・スカーフ用）
DOUBLE_SIDED = {"red"}


# ------------------------------------------------------------------
# 道具（座標は Blender: X = 右, Y = 奥, Z = 上。キャラの正面は -Y）
# ------------------------------------------------------------------
def reset_collection(name):
    old = bpy.data.collections.get(name)
    if old:
        for obj in list(old.all_objects):
            bpy.data.objects.remove(obj, do_unlink=True)
        bpy.data.collections.remove(old)
    col = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(col)
    return col


def to_linear(c):
    """画面で見える色（sRGB）を Blender 内部の色（リニア）に変換する。"""
    return tuple(v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4 for v in c)


def material(name):
    srgb, metal, rough, emit = COLORS[name]
    color = to_linear(srgb)
    mat = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metal
    bsdf.inputs["Roughness"].default_value = rough
    if emit > 0.0:
        bsdf.inputs["Emission Color"].default_value = (*color, 1.0)
        bsdf.inputs["Emission Strength"].default_value = emit
    mat.use_backface_culling = name not in DOUBLE_SIDED
    mat.diffuse_color = (*color, 1.0)
    return mat


def make_object(name, bm, mat_name, loc=(0, 0, 0), rot=(0, 0, 0), scale=(1, 1, 1), parent=None, smooth=True):
    mesh = bpy.data.meshes.new(name)
    bm.to_mesh(mesh)
    bm.free()
    for poly in mesh.polygons:
        poly.use_smooth = smooth
    obj = bpy.data.objects.new(name, mesh)
    COL.objects.link(obj)
    obj.data.materials.append(material(mat_name))
    obj.location = loc
    obj.rotation_euler = Euler([math.radians(a) for a in rot])
    obj.scale = scale
    if parent:
        obj.parent = parent
    return obj


def sphere(name, mat, loc, r, scale=(1, 1, 1), rot=(0, 0, 0), parent=None, seg=32):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=seg // 2, radius=r)
    return make_object(name, bm, mat, loc, rot, scale, parent)


def rounded_box(name, mat, loc, size, rot=(0, 0, 0), parent=None, bevel=0.03):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=size, verts=bm.verts)
    obj = make_object(name, bm, mat, loc, rot, (1, 1, 1), parent, smooth=True)
    if bevel > 0:
        mod = obj.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = 3
        mod.limit_method = "NONE"
    return obj


def cylinder(name, mat, loc, r_bottom, r_top, height, rot=(0, 0, 0), parent=None, seg=24, scale=(1, 1, 1)):
    """底面の中心が loc、ローカル +Z に height 伸びる円柱／円すい。"""
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=seg, radius1=r_bottom, radius2=r_top, depth=height)
    bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, height / 2))
    return make_object(name, bm, mat, loc, rot, scale, parent)


def between(name, mat, a, b, r_a, r_b, parent=None, seg=16, caps=True):
    """点 a から点 b へ伸びる棒（a 側の半径 r_a、b 側 r_b。r_b = 0 でトゲ）。"""
    a, b = Vector(a), Vector(b)
    d = b - a
    obj = cylinder(name, mat, a, r_a, r_b, d.length, parent=parent, seg=seg)
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(d)
    if caps:
        sphere(name + "_a", mat, a, r_a, parent=parent, seg=16)
        if r_b > 0.001:
            sphere(name + "_b", mat, b, r_b, parent=parent, seg=16)
    return obj


def torus(name, mat, loc, major, minor, rot=(0, 0, 0), parent=None, seg=40, ring=10, scale=(1, 1, 1)):
    bm = bmesh.new()
    rings = []
    for i in range(seg):
        a = 2 * math.pi * i / seg
        center = Vector((math.cos(a) * major, math.sin(a) * major, 0))
        out = Vector((math.cos(a), math.sin(a), 0))
        ring_verts = []
        for j in range(ring):
            b = 2 * math.pi * j / ring
            ring_verts.append(bm.verts.new(center + out * (math.cos(b) * minor) + Vector((0, 0, math.sin(b) * minor))))
        rings.append(ring_verts)
    for i in range(seg):
        for j in range(ring):
            r0, r1 = rings[i], rings[(i + 1) % seg]
            bm.faces.new((r0[j], r1[j], r1[(j + 1) % ring], r0[(j + 1) % ring]))
    return make_object(name, bm, mat, loc, rot, scale, parent)


def plate(name, mat, points, depth, loc, rot=(0, 0, 0), parent=None, scale=(1, 1, 1)):
    """XZ 平面の輪郭 points [(x, z), ...] を +Y 方向に depth だけ厚みをつけた板（盾・紋章用）。"""
    bm = bmesh.new()
    front = [bm.verts.new((x, 0, z)) for x, z in points]
    back = [bm.verts.new((x, depth, z)) for x, z in points]
    bm.faces.new(list(reversed(front)))
    bm.faces.new(back)
    n = len(points)
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new((front[i], front[j], back[j], back[i]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return make_object(name, bm, mat, loc, rot, scale, parent, smooth=False)


def empty(name, loc, parent=None):
    obj = bpy.data.objects.new(name, None)
    obj.empty_display_type = "ARROWS"
    obj.empty_display_size = 0.15
    COL.objects.link(obj)
    obj.location = loc
    if parent:
        obj.parent = parent
    return obj


def surface(center, radii, az, el):
    """楕円体の表面の点と外向きの向き（az: 正面からの水平角、el: 仰角。度）。正面は -Y。"""
    a, e = math.radians(az), math.radians(el)
    p = Vector((math.sin(a) * math.cos(e) * radii[0], -math.cos(a) * math.cos(e) * radii[1], math.sin(e) * radii[2]))
    n = Vector((p.x / radii[0] ** 2, p.y / radii[1] ** 2, p.z / radii[2] ** 2)).normalized()
    return Vector(center) + p, n


def export(file_name):
    folder = EXPORT_DIR or (os.path.dirname(bpy.data.filepath) if bpy.data.filepath else os.path.expanduser("~"))
    path = os.path.join(folder, file_name)
    bpy.ops.object.select_all(action="DESELECT")
    for obj in COL.all_objects:
        obj.select_set(True)
    bpy.ops.export_scene.gltf(filepath=path, export_format="GLB", use_selection=True, export_apply=True)
    print("書き出しました:", path)
    return path


# ==================================================================
# 勇者（高さ約 1.9、3 頭身）
# ==================================================================
COL = reset_collection(COLLECTION)

# ---- 足・ブーツ ----------------------------------------------------
for side in (-1, 1):
    x = 0.12 * side
    rounded_box("Boot", "boots", (x, -0.04, 0.075), (0.17, 0.3, 0.15), bevel=0.05)
    cylinder("BootShaft", "boots", (x, 0.0, 0.1), 0.085, 0.09, 0.16)
    cylinder("BootCuff", "boots", (x, 0.0, 0.25), 0.1, 0.11, 0.07)
    between("Leg", "pants", (x, 0.0, 0.3), (x * 1.1, 0.0, 0.5), 0.07, 0.075)

# ---- 胴体（チュニック・ズボン・ベルト） ------------------------------
cylinder("Shorts", "pants", (0, 0, 0.44), 0.19, 0.2, 0.14)
cylinder("TunicSkirt", "tunic", (0, 0, 0.4), 0.29, 0.22, 0.26, seg=32)
torus("TunicHem", "trim", (0, 0, 0.405), 0.285, 0.022, seg=48)
sphere("Chest", "tunic", (0, 0.0, 0.76), 0.24, scale=(1.0, 0.85, 1.05))
cylinder("Belt", "leather", (0, 0, 0.6), 0.235, 0.235, 0.06, seg=32)
rounded_box("BeltBuckle", "gold", (0, -0.235, 0.63), (0.1, 0.03, 0.08), bevel=0.01)
rounded_box("BeltBuckleHole", "leather", (0, -0.25, 0.63), (0.05, 0.01, 0.035), bevel=0.0)
# 斜めがけのベルト
rounded_box("Strap", "leather", (0, -0.2, 0.78), (0.06, 0.04, 0.5), rot=(0, -38, 0), bevel=0.01)
rounded_box("StrapBuckle", "gold", (-0.08, -0.24, 0.84), (0.06, 0.02, 0.05), rot=(0, -38, 0), bevel=0.005)
rounded_box("Pouch", "leather", (0.2, -0.13, 0.55), (0.09, 0.07, 0.1), bevel=0.02)

# ---- スカーフとマント ------------------------------------------------
torus("Scarf", "red", (0, 0.0, 0.96), 0.15, 0.06, rot=(8, 0, 0), scale=(1.1, 1.0, 1.0))
sphere("ScarfKnot", "red", (0.08, -0.14, 0.93), 0.06)
between("ScarfTail", "red", (0.1, -0.15, 0.92), (0.2, -0.12, 0.72), 0.05, 0.03, caps=False)


def cape():
    """背中側（+Y）で風になびく、ゆるく曲がったマント。"""
    bm = bmesh.new()
    rows, cols = 10, 12
    grid = []
    for r in range(rows + 1):
        t = r / rows  # 0 = 肩, 1 = すそ
        z = 0.97 - t * 0.78
        half_w = 0.17 + t * 0.2
        row = []
        for c in range(cols + 1):
            u = c / cols * 2 - 1  # -1 .. 1
            x = u * half_w
            y = 0.15 + t * 0.18 + (1 - u * u) * 0.08 * (0.4 + t) + math.sin(u * 3.0 + t * 4.0) * 0.02 * t
            row.append(bm.verts.new((x, y, z)))
        grid.append(row)
    for r in range(rows):
        for c in range(cols):
            bm.faces.new((grid[r][c], grid[r][c + 1], grid[r + 1][c + 1], grid[r + 1][c]))
    obj = make_object("Cape", bm, "red")
    mod = obj.modifiers.new("Thick", "SOLIDIFY")
    mod.thickness = 0.02
    return obj


cape()

# ---- 左腕と盾（キャラの左 = +X） ------------------------------------
sphere("SleeveL", "tunic", (0.25, 0.0, 0.86), 0.09)
between("UpperArmL", "skin", (0.27, 0.0, 0.84), (0.31, -0.06, 0.7), 0.06, 0.055)
between("BracerL", "leather", (0.31, -0.06, 0.7), (0.3, -0.14, 0.6), 0.065, 0.06)
sphere("GloveL", "leather", (0.3, -0.16, 0.57), 0.065)

SHIELD_W, SHIELD_H = 0.44, 0.54


def heater(w, h, n=10):
    """上が平ら・下がとがった盾の輪郭（XZ 平面）。"""
    pts = [(-w / 2, h * 0.45), (0, h * 0.5), (w / 2, h * 0.45)]
    for i in range(1, n + 1):  # 右側を上から下へ
        t = i / n
        x = (w / 2) * (1 - t ** 1.8)
        z = h * 0.45 - t * h * 0.95
        pts.append((x, z))
    for i in range(n - 1, 0, -1):  # 左側を下から上へ
        t = i / n
        x = -(w / 2) * (1 - t ** 1.8)
        z = h * 0.45 - t * h * 0.95
        pts.append((x, z))
    return pts


shield = empty("Shield", (0.37, -0.26, 0.62))
shield.rotation_euler = Euler((0, 0, math.radians(-25)))
plate("ShieldRim", "gold", heater(SHIELD_W, SHIELD_H), 0.05, (0, 0.0, 0), parent=shield)
plate("ShieldFace", "shield", heater(SHIELD_W * 0.86, SHIELD_H * 0.86), 0.05, (0, -0.012, 0.0), parent=shield)
BIRD = [  # 翼を広げた鳥の紋章（左右対称）
    (0.0, 0.2), (0.03, 0.17), (0.03, 0.12), (0.07, 0.15), (0.12, 0.2), (0.15, 0.16), (0.15, 0.1),
    (0.12, 0.05), (0.09, 0.0), (0.05, -0.02), (0.06, -0.1), (0.1, -0.16), (0.04, -0.13), (0.0, -0.18),
]
bird = BIRD + [(-x, z) for x, z in reversed(BIRD[1:-1])]
plate("ShieldEmblem", "gold", bird, 0.02, (0, -0.03, 0.01), parent=shield, scale=(0.95, 1, 0.95))

# ---- 右腕と剣（Weapon を中心に振られる。原点 = 右肩） -----------------
weapon = empty("Weapon", (-0.26, 0.0, 0.86))
sphere("SleeveR", "tunic", (0, 0, 0), 0.09, parent=weapon)
between("UpperArmR", "skin", (-0.02, 0.0, -0.02), (-0.06, -0.08, -0.15), 0.06, 0.055, parent=weapon)
between("BracerR", "leather", (-0.06, -0.08, -0.15), (-0.08, -0.18, -0.24), 0.065, 0.06, parent=weapon)
hand = Vector((-0.09, -0.21, -0.27))
sphere("GloveR", "leather", hand, 0.068, parent=weapon)

# 剣（手から前方・斜め上へ）
blade_dir = Vector((-0.25, -0.75, 0.62)).normalized()
sword = empty("Sword", hand, parent=weapon)
sword.rotation_mode = "QUATERNION"
sword.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(blade_dir)
cylinder("Grip", "leather", (0, 0, -0.1), 0.028, 0.028, 0.16, parent=sword, seg=12)
sphere("Pommel", "gold", (0, 0, -0.12), 0.042, parent=sword, seg=16)
rounded_box("Guard", "gold", (0, 0, 0.07), (0.26, 0.06, 0.05), parent=sword, bevel=0.015)
for gx in (-0.13, 0.13):
    sphere("GuardEnd", "gold", (gx, 0, 0.075), 0.032, parent=sword, seg=16)
sphere("GuardGem", "gem", (0, -0.032, 0.075), 0.03, parent=sword, seg=16)


def blade(length=0.72, width=0.055, thick=0.016):
    """ひし形断面で先がとがった刃（ローカル +Z 方向）。"""
    bm = bmesh.new()
    base = [bm.verts.new(v) for v in ((width, 0, 0), (0, -thick, 0), (-width, 0, 0), (0, thick, 0))]
    mid = [bm.verts.new((v.co.x * 0.95, v.co.y, length * 0.82)) for v in base]
    tip = bm.verts.new((0, 0, length))
    for i in range(4):
        j = (i + 1) % 4
        bm.faces.new((base[i], base[j], mid[j], mid[i]))
        bm.faces.new((mid[i], mid[j], tip))
    bm.faces.new(list(reversed(base)))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return bm


make_object("Blade", blade(), "steel", (0, 0, 0.09), parent=sword, smooth=False)

# ---- 頭 --------------------------------------------------------------
HEAD = Vector((0, 0.0, 1.3))
HEAD_R = (0.34, 0.32, 0.33)
sphere("Head", "skin", HEAD, 1.0, scale=HEAD_R)
for side in (-1, 1):
    sphere("Ear", "skin", HEAD + Vector((0.33 * side, 0.02, -0.02)), 0.07, scale=(0.5, 0.8, 1.0))

# 顔（大きな茶色の目・太い眉・小さな口）
for side in (-1, 1):
    ex = 0.115 * side
    eye = HEAD + Vector((ex, -0.29, -0.03))
    sphere("EyeWhite", "eye_white", eye, 1.0, scale=(0.08, 0.03, 0.105))
    sphere("Iris", "iris", eye + Vector((-0.008 * side, -0.018, -0.008)), 1.0, scale=(0.064, 0.02, 0.088))
    sphere("Pupil", "pupil", eye + Vector((-0.008 * side, -0.03, -0.014)), 1.0, scale=(0.034, 0.012, 0.05))
    sphere("EyeShine", "shine", eye + Vector((0.016, -0.042, 0.032)), 0.02)
    sphere("EyeShine2", "shine", eye + Vector((-0.02, -0.04, -0.035)), 0.01)
    rounded_box("Brow", "brow", HEAD + Vector((0.12 * side, -0.3, 0.09)), (0.12, 0.03, 0.03), rot=(0, -20 * side, 0), bevel=0.01)
    sphere("Cheek", "blush", HEAD + Vector((0.2 * side, -0.25, -0.1)), 1.0, scale=(0.05, 0.02, 0.03))
sphere("Nose", "skin", HEAD + Vector((0, -0.325, -0.08)), 0.02)
rounded_box("Mouth", "mouth", HEAD + Vector((0, -0.315, -0.15)), (0.06, 0.01, 0.014), bevel=0.004)

# 髪（ふくらんだ土台＋上と後ろにはねる大きな毛束）
HAIR = HEAD + Vector((0, 0.07, 0.07))
HAIR_R = (0.355, 0.33, 0.33)
sphere("HairBase", "hair", HAIR, 1.0, scale=HAIR_R)
sphere("HairBack", "hair", HEAD + Vector((0, 0.12, -0.06)), 1.0, scale=(0.33, 0.25, 0.3))


def lock(name, base, direction, length, r, bend, flat=0.7):
    """根元 base から direction へ伸び、先が bend の方向へ曲がる、なめらかな毛束。
    断面は少し平たい楕円（flat）で、根元から先へ細くなる。"""
    d1 = Vector(direction).normalized()
    ctrl = base + d1 * length * 0.6
    end = ctrl + (d1 + Vector(bend)).normalized() * length * 0.5
    steps, ring = 10, 12
    pts = []
    for i in range(steps + 1):  # 2 次ベジェ曲線
        t = i / steps
        pts.append(base * (1 - t) ** 2 + ctrl * 2 * (1 - t) * t + end * t * t)
    bm = bmesh.new()
    rings = []
    prev_side = None
    for i in range(steps):
        tangent = (pts[i + 1] - pts[i]).normalized()
        side = tangent.cross(Vector((0, 0, 1)) if abs(tangent.z) < 0.95 else Vector((1, 0, 0))).normalized()
        if prev_side is not None and side.dot(prev_side) < 0:
            side = -side
        prev_side = side
        up = side.cross(tangent).normalized()
        rad = r * (1 - i / steps) ** 0.8
        verts = []
        for j in range(ring):
            a = 2 * math.pi * j / ring
            verts.append(bm.verts.new(pts[i] + side * math.cos(a) * rad + up * math.sin(a) * rad * flat))
        rings.append(verts)
    tip = bm.verts.new(pts[-1])
    for i in range(steps - 1):
        for j in range(ring):
            k = (j + 1) % ring
            bm.faces.new((rings[i][j], rings[i][k], rings[i + 1][k], rings[i + 1][j]))
    for j in range(ring):
        bm.faces.new((rings[-1][j], rings[-1][(j + 1) % ring], tip))
    bm.faces.new(list(reversed(rings[0])))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return make_object(name, bm, "hair")


UP, BACK = Vector((0, 0, 1)), Vector((0, 1, 0))
locks = [
    # (水平角, 仰角, 長さ, 太さ)  水平角 0 = 正面, ±90 = 横, 180 = 後ろ
    (0, 50, 0.36, 0.16), (-32, 45, 0.34, 0.15), (32, 45, 0.34, 0.15),
    (-65, 32, 0.34, 0.15), (65, 32, 0.34, 0.15), (-100, 22, 0.32, 0.14), (100, 22, 0.32, 0.14),
    (-140, 30, 0.34, 0.15), (140, 30, 0.34, 0.15), (180, 30, 0.34, 0.16),
    (-160, 0, 0.28, 0.14), (160, 0, 0.28, 0.14), (-115, -8, 0.24, 0.12), (115, -8, 0.24, 0.12),
    (-45, 75, 0.34, 0.16), (45, 75, 0.34, 0.16), (180, 72, 0.34, 0.16), (0, 85, 0.3, 0.15),
]
for i, (az, el, length, r) in enumerate(locks):
    p, n = surface(HAIR, HAIR_R, az, el)
    front = abs(az) < 45
    if front:  # 前髪: 上へ立ち上がって後ろへ流れる
        direction = n * 0.5 + UP * 0.6 + BACK * 0.25
        bend = BACK * 1.3
    elif el > 45:  # てっぺん: 上へ、先は後ろへ
        direction = n * 0.6 + UP * 0.6 + BACK * 0.2
        bend = BACK * 0.8
    else:  # 横・後ろ: 外へはねる
        direction = n + UP * 0.35 + BACK * 0.2
        bend = UP * 0.5 + n * 0.3
    lock("HairLock%d" % i, p - n * (0.1 if el > 10 else 0.16), direction, length, r, bend)
# もみあげ
for side in (-1, 1):
    base = HEAD + Vector((0.3 * side, -0.06, 0.06))
    between("Sideburn", "hair", base, base + Vector((0.03 * side, -0.05, -0.2)), 0.06, 0.0, seg=10, caps=False)
# 額の小さな前髪（サークレットの上）
for i, bx in enumerate((-0.14, 0.0, 0.14)):
    base = HEAD + Vector((bx, -0.24, 0.24))
    between("Bangs%d" % i, "hair", base, base + Vector((bx * 0.4, -0.1, -0.06)), 0.06, 0.0, seg=10, caps=False)

# サークレット（金の輪＋青い宝石）
torus("Circlet", "gold", HEAD + Vector((0, 0.01, 0.13)), 1.0, 0.075, rot=(-12, 0, 0), scale=(0.33, 0.325, 0.34))
gem_pos = HEAD + Vector((0, -0.325, 0.12))
cylinder("GemFrame", "gold", gem_pos + Vector((0, 0.02, 0)), 0.075, 0.07, 0.04, rot=(90, 0, 0), seg=24)
sphere("CircletGem", "gem", gem_pos + Vector((0, -0.02, 0)), 0.055, scale=(1, 0.6, 1))
torus("GemRing", "gold", gem_pos + Vector((0, -0.025, 0)), 0.068, 0.012, rot=(90, 0, 0))

export(FILE_NAME)
