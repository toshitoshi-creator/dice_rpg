# DICE BATTLE - 敵（スライム）を Blender で作るスクリプト。ほかの敵を作るときのお手本。
#
# 使い方:
#   1. Blender の「Scripting」タブで「+ 新規」→ このファイルの中身を貼り付けて「▶」
#   2. 「DiceBattle_Enemy」コレクションにモデルができ、slime.glb が書き出される
#   3. できた slime.glb を、リポジトリの assets/models/enemies/slime.glb に置く
#
# ファイル名で差し替える敵が決まる（docs/ENEMY_LIST.md の ID を使う）:
#   slime.glb    … スライム族の 3 色（スライム / ベリースライム / ゴールドスライム）すべて
#   slime_2.glb  … No.4 ベリースライムだけ
#
# 色違いのしくみ:
#   マテリアル名をゲームの「役割名」（このスライムなら body / body2）にしておくと、
#   色違いの敵ではゲーム側がその色に置き換える。目や口など共通の部分は好きな名前でよい。
#
# ほかに使える名前:
#   Weapon… = 攻撃で振る / Wing… = 羽ばたく / Tail… = しっぽを振る（オブジェクト名。原点が回転の中心）

import math
import os

import bpy  # noqa: I001  (bpy を先に読み込む)
import bmesh
from mathutils import Euler, Vector

COLLECTION = "DiceBattle_Enemy"
FILE_NAME = "slime.glb"
EXPORT_DIR = ""  # 空なら .blend と同じフォルダ（未保存ならホームフォルダ）

# マテリアル名: (色 RGB, 金属っぽさ, ざらつき, 発光の強さ)
COLORS = {
    "body": ((0.3, 0.85, 0.45), 0.0, 0.12, 0.0),   # 色違いで置き換わる
    "body2": ((0.2, 0.55, 0.3), 0.0, 0.3, 0.0),    # 色違いで置き換わる
    "eye_white": ((1.0, 1.0, 1.0), 0.0, 0.2, 0.0),
    "pupil": ((0.04, 0.04, 0.06), 0.0, 0.1, 0.0),
    "shine": ((1.0, 1.0, 1.0), 0.0, 0.1, 1.0),
    "mouth": ((0.32, 0.04, 0.1), 0.0, 0.5, 0.0),
    "blush": ((1.0, 0.55, 0.6), 0.0, 0.6, 0.0),
}


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
    bmesh.ops.create_uvsphere(bm, u_segments=32, v_segments=16, radius=r)
    return _object(name, bm, mat, loc, rot, scale, parent)


def cylinder(name, mat, loc, r_bottom, r_top, height, rot=(0, 0, 0), parent=None, segments=24):
    """底面の中心が loc、+Z 方向に height 伸びる円柱／円すい（r_top=0 で円すい）。"""
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=segments, radius1=r_bottom, radius2=r_top, depth=height)
    bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, height / 2))
    return _object(name, bm, mat, loc, rot, (1, 1, 1), parent)


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
# モデル（正面は -Y、足元は Z = 0）
# ------------------------------------------------------------------
COL = reset_collection(COLLECTION)

cylinder("Puddle", "body2", (0, 0, 0), 1.0, 0.95, 0.12)
sphere("Body", "body", (0, 0, 0.62), 0.9, scale=(1.0, 1.0, 0.75))
cylinder("Tip", "body", (0, 0.05, 1.08), 0.28, 0.0, 0.45, rot=(10, 0, 0))

for side in (-1, 1):
    x = 0.3 * side
    sphere("EyeWhite", "eye_white", (x, -0.72, 0.8), 0.17, scale=(1.0, 0.7, 1.1))
    sphere("Pupil", "pupil", (x - 0.02 * side, -0.83, 0.79), 0.095, scale=(1.0, 0.6, 1.1))
    sphere("EyeShine", "shine", (x + 0.04, -0.9, 0.85), 0.03)
    sphere("Cheek", "blush", (0.5 * side, -0.66, 0.62), 0.1, scale=(1.2, 0.4, 0.6))

sphere("Mouth", "mouth", (0, -0.84, 0.5), 0.12, scale=(1.5, 0.5, 0.6))
sphere("Highlight", "shine", (-0.42, -0.5, 1.0), 0.14, scale=(1.0, 0.4, 0.6))

export(FILE_NAME)
