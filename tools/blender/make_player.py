# DICE BATTLE - プレイヤー（剣士）を Blender で作るスクリプト
#
# 使い方:
#   1. Blender を開き、上のタブから「Scripting」を選ぶ
#   2. 「+ 新規」を押して、このファイルの中身をすべて貼り付ける
#   3. 「▶（スクリプト実行）」を押す
#   4. 「DiceBattle_Player」コレクションにモデルができ、player.glb が書き出される
#      （.blend を保存していればその隣、未保存ならホームフォルダ。EXPORT_DIR で変更可）
#   5. 形や色を手直ししたら、ファイル → エクスポート → glTF 2.0 (.glb) で書き出し直してもよい
#   6. できた player.glb を、リポジトリの assets/models/player.glb に置く
#
# ゲーム側の約束:
#   - 正面は「正面ビュー（テンキー 1）」から見える側（-Y 方向）、足元は Z = 0
#   - 大きさは自由（ゲームが自動で合わせる）
#   - 「Weapon」という名前のオブジェクト（空の Empty）とその子が、攻撃時に原点を中心に振られる
#
# 何度実行しても、前回このスクリプトが作ったものだけを消して作り直します（他のオブジェクトは消しません）。

import math
import os

import bpy  # noqa: I001  (bpy を先に読み込む)
import bmesh
from mathutils import Euler, Vector

COLLECTION = "DiceBattle_Player"
FILE_NAME = "player.glb"
EXPORT_DIR = ""  # 空なら .blend と同じフォルダ（未保存ならホームフォルダ）

# ------------------------------------------------------------------
# 色（マテリアル名: (色 RGB, 金属っぽさ, ざらつき, 発光の強さ)）
# ------------------------------------------------------------------
COLORS = {
    "skin": ((0.96, 0.76, 0.6), 0.0, 0.6, 0.0),
    "hair": ((0.35, 0.2, 0.1), 0.0, 0.7, 0.0),
    "tunic": ((0.16, 0.34, 0.8), 0.0, 0.7, 0.0),
    "cape": ((0.8, 0.12, 0.16), 0.0, 0.8, 0.0),
    "leather": ((0.42, 0.26, 0.14), 0.0, 0.85, 0.0),
    "boots": ((0.2, 0.14, 0.12), 0.0, 0.8, 0.0),
    "steel": ((0.82, 0.85, 0.9), 0.9, 0.25, 0.0),
    "gold": ((1.0, 0.78, 0.28), 0.9, 0.3, 0.0),
    "eye": ((0.05, 0.05, 0.08), 0.0, 0.2, 0.0),
    "shine": ((1.0, 1.0, 1.0), 0.0, 0.2, 1.0),
    "blush": ((1.0, 0.55, 0.6), 0.0, 0.6, 0.0),
    "plume": ((0.95, 0.2, 0.25), 0.0, 0.7, 0.0),
}


# ------------------------------------------------------------------
# 道具（座標はすべて Blender の座標: X = 右, Y = 奥, Z = 上。正面は -Y）
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


def material(name):
    color, metal, rough, emit = COLORS[name]
    mat = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metal
    bsdf.inputs["Roughness"].default_value = rough
    if emit > 0.0:
        bsdf.inputs["Emission Color"].default_value = (*color, 1.0)
        bsdf.inputs["Emission Strength"].default_value = emit
    mat.diffuse_color = (*color, 1.0)
    return mat


def _object(name, bm, mat_name, loc, rot, scale, parent, smooth=True):
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


def sphere(name, mat, loc, r, scale=(1, 1, 1), rot=(0, 0, 0), parent=None):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=24, v_segments=12, radius=r)
    return _object(name, bm, mat, loc, rot, scale, parent)


def box(name, mat, loc, size, rot=(0, 0, 0), parent=None):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    return _object(name, bm, mat, loc, rot, size, parent, smooth=False)


def cylinder(name, mat, loc, r_bottom, r_top, height, rot=(0, 0, 0), parent=None, segments=16):
    """底面の中心が loc、+Z 方向に height 伸びる円柱／円すい（r_top=0 で円すい）。"""
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=segments, radius1=r_bottom, radius2=r_top, depth=height)
    bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, height / 2))
    return _object(name, bm, mat, loc, rot, (1, 1, 1), parent, smooth=True)


def limb(name, mat, a, b, r, parent=None):
    """点 a から点 b へ伸びる丸い棒（両端が球）。"""
    a, b = Vector(a), Vector(b)
    d = b - a
    obj = cylinder(name, mat, a, r, r, d.length, parent=parent, segments=12)
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(d)
    sphere(name + "_end", mat, b, r, parent=parent)
    sphere(name + "_start", mat, a, r, parent=parent)
    return obj


def empty(name, loc, parent=None):
    obj = bpy.data.objects.new(name, None)
    obj.empty_display_type = "ARROWS"
    obj.empty_display_size = 0.2
    COL.objects.link(obj)
    obj.location = loc
    if parent:
        obj.parent = parent
    return obj


def export(file_name):
    folder = EXPORT_DIR or (os.path.dirname(bpy.data.filepath) if bpy.data.filepath else os.path.expanduser("~"))
    path = os.path.join(folder, file_name)
    bpy.ops.object.select_all(action="DESELECT")
    for obj in COL.all_objects:
        obj.select_set(True)
    bpy.ops.export_scene.gltf(filepath=path, export_format="GLB", use_selection=True, export_apply=True)
    print("書き出しました:", path)
    return path


# ------------------------------------------------------------------
# モデル（高さ約 2、ちびキャラ体型）
# ------------------------------------------------------------------
COL = reset_collection(COLLECTION)

# 脚とブーツ
for x in (-0.17, 0.17):
    limb("Leg", "tunic", (x, 0, 0.72), (x, 0, 0.25), 0.11)
    box("Boot", "boots", (x, -0.05, 0.1), (0.24, 0.36, 0.2))

# 胴体・ベルト
cylinder("Body", "tunic", (0, 0, 0.62), 0.36, 0.3, 0.72)
cylinder("Skirt", "tunic", (0, 0, 0.55), 0.4, 0.34, 0.2)
cylinder("Belt", "leather", (0, 0, 0.78), 0.37, 0.37, 0.09)
box("Buckle", "gold", (0, -0.37, 0.825), (0.12, 0.03, 0.08))

# 頭（大きめ）
head = (0, 0, 1.62)
sphere("Head", "skin", head, 0.36)
for side in (-1, 1):
    sphere("Eye", "eye", (0.13 * side, -0.31, 1.62), 0.055, scale=(0.9, 0.5, 1.3))
    sphere("EyeShine", "shine", (0.13 * side + 0.02, -0.34, 1.65), 0.018)
    sphere("Cheek", "blush", (0.22 * side, -0.28, 1.53), 0.045, scale=(1.3, 0.4, 0.7))
sphere("Hair", "hair", (0, 0.06, 1.7), 0.35, scale=(1.02, 0.95, 0.9))

# 兜と羽根飾り
sphere("Helmet", "steel", (0, 0.02, 1.76), 0.37, scale=(1.05, 1.05, 0.72))
box("HelmetBand", "gold", (0, -0.3, 1.74), (0.5, 0.06, 0.06))
cylinder("Plume", "plume", (0, 0.05, 2.0), 0.08, 0.0, 0.4, rot=(-25, 0, 0))

# マント（背中側 = +Y）
box("Cape", "cape", (0, 0.36, 0.95), (0.62, 0.04, 0.9), rot=(10, 0, 0))

# 左腕（体の +X 側）と盾
limb("ArmL", "tunic", (0.38, 0, 1.12), (0.46, -0.08, 0.82), 0.09)
cylinder("Shield", "steel", (0.52, -0.18, 0.95), 0.3, 0.3, 0.05, rot=(90, 0, 10))
sphere("ShieldBoss", "gold", (0.53, -0.24, 0.95), 0.08)

# 右腕と剣（Weapon を中心に振られる。原点 = 肩）
weapon = empty("Weapon", (-0.4, 0, 1.12))
limb("ArmR", "tunic", (0, 0, 0), (-0.05, -0.1, -0.3), 0.09, parent=weapon)
sphere("Hand", "skin", (-0.05, -0.12, -0.34), 0.09, parent=weapon)
blade_dir = Vector((0, -0.95, 0.3)).normalized()
hand = Vector((-0.05, -0.14, -0.34))
cylinder("Hilt", "leather", hand - blade_dir * 0.12, 0.035, 0.035, 0.24, parent=weapon).rotation_euler = Vector((0, 0, 1)).rotation_difference(blade_dir).to_euler()
guard = box("Guard", "gold", hand + blade_dir * 0.14, (0.3, 0.07, 0.06), parent=weapon)
blade = box("Blade", "steel", hand + blade_dir * 0.7, (0.09, 1.05, 0.025), parent=weapon)
blade.rotation_euler = Vector((0, -1, 0)).rotation_difference(blade_dir).to_euler()
guard.rotation_euler = blade.rotation_euler

export(FILE_NAME)
