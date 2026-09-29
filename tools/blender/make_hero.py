# =============================================================================
# DICE BATTLE - 勇者（3 頭身デフォルメ）を Blender で自動生成するスクリプト
# =============================================================================
#
# 使い方:
#   Blender 4.2 以降で「Scripting」タブ →「+ 新規」→ このファイルの中身を貼り付けて「▶」
#
# 実行すると、次を自動で行います:
#   1. シーンを初期化（RESET_SCENE = True のとき、今のシーンのオブジェクトをすべて削除します）
#   2. マテリアル作成（MAT_Skin, MAT_Hair, MAT_BlueCloth ...）
#   3. 頭・顔・髪・胴体・服・手足・ブーツ（Hero_Head, Hero_Hair, Hero_Tunic ...）
#   4. 剣（Hero_Sword と Blade / Guard / Handle / Gem）
#   5. 盾（Hero_Shield / Hero_Shield_Emblem）
#   6. マント（Cloth Simulation で形を作り、メッシュとして適用）
#   7. ポーズ（POSE = "IDLE" で待機ポーズ、"A" で A ポーズ）
#   8. カメラ（正面・側面・背面・斜めの平行投影カメラ＋確認用カメラ）
#   9. ライト（Key / Fill / Rim の 3 灯＋明るいワールド）
#  10. アーマチュア（root / pelvis / spine ... の簡易ヒューマノイド）
#  11. コレクション整理
#  12. .blend 保存と、ゲーム用 player.glb の書き出し
#
# 座標の約束: X = キャラの左手側, -Y = キャラの正面（正面ビュー = テンキー 1）, Z = 上, 足元 Z = 0
#
# 第 2 段階（あとで改良しやすいように、部位ごとに関数を分けています）:
#   build_face() … 顔 / build_hair() … 髪 / build_sword(), build_shield() … 装備
#   build_cape() … マント / make_materials() … 質感 / build_armature(), BIND_TO_ARMATURE … リギング
# =============================================================================

import math
import os

import bpy  # noqa: I001  (bpy を先に読み込む)
import bmesh
from mathutils import Euler, Matrix, Quaternion, Vector

# ----------------------------------------------------------------------------
# 設定
# ----------------------------------------------------------------------------
RESET_SCENE = True          # True: 今のシーンのオブジェクトを全部消してから作る
POSE = "IDLE"               # "IDLE" = 剣と盾を構えた待機ポーズ / "A" = A ポーズ
USE_CLOTH_SIM = True        # マントを Cloth Simulation で作る（失敗したら手続き生成に切り替え）
CREATE_ARMATURE = True      # 簡易アーマチュアを作る
BIND_TO_ARMATURE = False    # 第 2 段階: 各パーツをボーンに親子付けする（今は False 推奨）
SAVE_BLEND = True           # hero.blend を保存する
EXPORT_GLB = True           # ゲーム用 player.glb を書き出す
OUTPUT_DIR = ""             # 保存先（空なら今の .blend と同じ場所、未保存ならホームフォルダ）
BLEND_NAME = "hero.blend"
GLB_NAME = "player.glb"

# ----------------------------------------------------------------------------
# 色（画面で見える色 sRGB）と質感
#   (色, 金属っぽさ, ざらつき, 発光, 追加設定)
# ----------------------------------------------------------------------------
MATERIALS = {
    "MAT_Skin": ((1.0, 0.8, 0.66), 0.0, 0.55, 0.0, {}),
    "MAT_Blush": ((1.0, 0.62, 0.6), 0.0, 0.6, 0.0, {}),
    "MAT_Hair": ((0.47, 0.27, 0.13), 0.0, 0.45, 0.0, {}),
    "MAT_Brow": ((0.33, 0.18, 0.08), 0.0, 0.6, 0.0, {}),
    "MAT_Eye": ((0.45, 0.26, 0.11), 0.0, 0.15, 0.0, {}),        # 瞳（茶色）
    "MAT_EyeWhite": ((1.0, 1.0, 1.0), 0.0, 0.25, 0.0, {}),
    "MAT_Pupil": ((0.12, 0.06, 0.03), 0.0, 0.15, 0.0, {}),
    "MAT_EyeLine": ((0.2, 0.1, 0.05), 0.0, 0.5, 0.0, {}),
    "MAT_EyeHighlight": ((1.0, 1.0, 1.0), 0.0, 0.05, 2.0, {}),
    "MAT_Mouth": ((0.6, 0.28, 0.24), 0.0, 0.5, 0.0, {}),
    "MAT_BlueCloth": ((0.16, 0.38, 0.82), 0.0, 0.8, 0.0, {}),
    "MAT_Cream": ((0.96, 0.92, 0.84), 0.0, 0.8, 0.0, {}),
    "MAT_Pants": ((0.22, 0.24, 0.34), 0.0, 0.8, 0.0, {}),
    "MAT_RedCape": ((0.82, 0.13, 0.1), 0.0, 0.75, 0.0, {"double": True}),
    "MAT_RedScarf": ((0.9, 0.17, 0.12), 0.0, 0.8, 0.0, {"double": True}),
    "MAT_Leather": ((0.55, 0.33, 0.16), 0.0, 0.45, 0.0, {}),
    "MAT_LeatherDark": ((0.36, 0.21, 0.1), 0.0, 0.5, 0.0, {}),
    "MAT_Gold": ((1.0, 0.77, 0.3), 0.8, 0.35, 0.0, {}),
    "MAT_Silver": ((0.88, 0.9, 0.94), 0.75, 0.3, 0.0, {}),
    "MAT_BlueGem": ((0.12, 0.42, 1.0), 0.0, 0.05, 0.4, {"coat": 1.0}),
    "MAT_ShieldBlue": ((0.14, 0.37, 0.82), 0.1, 0.4, 0.0, {}),
}

# ----------------------------------------------------------------------------
# 体の寸法（3 頭身: 頭＋髪で全体の約 1/3）
# ----------------------------------------------------------------------------
HEAD_C = Vector((0.0, 0.0, 1.46))        # 頭の中心
HEAD_R = Vector((0.33, 0.31, 0.32))      # 頭の半径（横, 奥行き, 高さ）
NECK_Z = 1.1
WAIST_Z = 0.6
HIP_X = 0.1
SHOULDER = Vector((0.235, 0.0, 0.98))    # 左肩（右肩は X を反転）

COL = {}          # コレクション
PIVOTS = {}       # ポーズ用の支点（Empty）


# =============================================================================
# 1. シーン初期化とコレクション
# =============================================================================
def reset_scene():
    if RESET_SCENE:
        for obj in list(bpy.context.scene.objects):
            bpy.data.objects.remove(obj, do_unlink=True)
        for col in list(bpy.context.scene.collection.children):
            _remove_collection(col)
        for block in (bpy.data.meshes, bpy.data.armatures, bpy.data.cameras, bpy.data.lights, bpy.data.curves):
            for item in list(block):
                if item.users == 0:
                    block.remove(item)
    else:
        old = bpy.data.collections.get("Hero")
        if old:
            _remove_collection(old)
    root = bpy.data.collections.new("Hero")
    bpy.context.scene.collection.children.link(root)
    COL["root"] = root
    for key, name in (("body", "Hero_Character"), ("face", "Hero_Face"), ("hair", "Hero_HairParts"),
                      ("gear", "Hero_Equipment"), ("rig", "Hero_Rig"), ("setup", "Hero_Cameras_Lights")):
        col = bpy.data.collections.new(name)
        root.children.link(col)
        COL[key] = col


def _remove_collection(col):
    for child in list(col.children):
        _remove_collection(child)
    for obj in list(col.objects):
        bpy.data.objects.remove(obj, do_unlink=True)
    bpy.data.collections.remove(col)


# =============================================================================
# 2. マテリアル
# =============================================================================
def to_linear(c):
    return tuple(v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4 for v in c)


def _set_input(bsdf, names, value):
    for n in names:
        if n in bsdf.inputs:
            bsdf.inputs[n].default_value = value
            return


def make_materials():
    for name, (srgb, metal, rough, emit, extra) in MATERIALS.items():
        mat = bpy.data.materials.get(name) or bpy.data.materials.new(name)
        mat.use_nodes = True
        bsdf = mat.node_tree.nodes.get("Principled BSDF")
        color = (*to_linear(srgb), 1.0)
        bsdf.inputs["Base Color"].default_value = color
        bsdf.inputs["Metallic"].default_value = metal
        bsdf.inputs["Roughness"].default_value = rough
        if emit > 0:
            _set_input(bsdf, ("Emission Color", "Emission"), color)
            _set_input(bsdf, ("Emission Strength",), emit)
        if extra.get("coat"):
            _set_input(bsdf, ("Coat Weight", "Clearcoat"), extra["coat"])
        if extra.get("subsurface"):
            _set_input(bsdf, ("Subsurface Weight", "Subsurface"), extra["subsurface"])
        mat.use_backface_culling = not extra.get("double", False)
        mat.diffuse_color = color


# =============================================================================
# メッシュ作りの道具
#   Part: 1 つのオブジェクトに複数の形・複数のマテリアルをまとめて作る
# =============================================================================
def quat_to(direction, up=Vector((0, 0, 1))):
    return up.rotation_difference(Vector(direction).normalized())


def ellipsoid_point(center, radii, az, el):
    """楕円体の表面の点と法線（az: 正面(-Y)からの水平角 [+ = キャラの左 (+X)], el: 仰角。度）"""
    a, e = math.radians(az), math.radians(el)
    p = Vector((math.sin(a) * math.cos(e) * radii.x, -math.cos(a) * math.cos(e) * radii.y, math.sin(e) * radii.z))
    n = Vector((p.x / radii.x ** 2, p.y / radii.y ** 2, p.z / radii.z ** 2)).normalized()
    return center + p, n


class Part:
    def __init__(self, name, collection="body"):
        self.name = name
        self.collection = collection
        self.bm = bmesh.new()
        self.mats = []

    def _mi(self, mat):
        if mat not in self.mats:
            self.mats.append(mat)
        return self.mats.index(mat)

    def _paint(self, verts, mat):
        idx = self._mi(mat)
        faces = {f for v in verts for f in v.link_faces}
        for f in faces:
            f.material_index = idx

    def sphere(self, mat, center, radii, rot=None, seg=24):
        m = Matrix.LocRotScale(Vector(center), rot or Quaternion(), Vector(radii))
        res = bmesh.ops.create_uvsphere(self.bm, u_segments=seg, v_segments=max(seg // 2, 6), radius=1.0, matrix=m)
        self._paint(res["verts"], mat)
        return res["verts"]

    def box(self, mat, center, size, rot=None):
        m = Matrix.LocRotScale(Vector(center), rot or Quaternion(), Vector(size))
        res = bmesh.ops.create_cube(self.bm, size=1.0, matrix=m)
        self._paint(res["verts"], mat)
        return res["verts"]

    def cone(self, mat, base, direction, length, r_base, r_tip, seg=16, flat=1.0):
        """base から direction へ length 伸びる円柱／円すい。"""
        q = quat_to(direction)
        m = Matrix.LocRotScale(Vector(base) + Vector(direction).normalized() * length / 2, q, Vector((1, flat, 1)))
        res = bmesh.ops.create_cone(self.bm, cap_ends=True, segments=seg, radius1=r_base, radius2=r_tip, depth=length, matrix=m)
        self._paint(res["verts"], mat)
        return res["verts"]

    def torus(self, mat, center, major, minor, rot=None, scale=(1, 1, 1), seg=40, ring=10):
        m = Matrix.LocRotScale(Vector(center), rot or Quaternion(), Vector(scale))
        rings = []
        for i in range(seg):
            a = 2 * math.pi * i / seg
            c = Vector((math.cos(a) * major, math.sin(a) * major, 0))
            out = Vector((math.cos(a), math.sin(a), 0))
            rings.append([self.bm.verts.new(m @ (c + out * math.cos(2 * math.pi * j / ring) * minor
                                                    + Vector((0, 0, math.sin(2 * math.pi * j / ring) * minor))))
                          for j in range(ring)])
        verts = [v for r in rings for v in r]
        for i in range(seg):
            r0, r1 = rings[i], rings[(i + 1) % seg]
            for j in range(ring):
                self.bm.faces.new((r0[j], r1[j], r1[(j + 1) % ring], r0[(j + 1) % ring]))
        self._paint(verts, mat)
        return verts

    def lathe(self, mat, profile, center=(0, 0, 0), seg=32, sx=1.0, sy=1.0, cap_bottom=True, cap_top=True, rot=None):
        """高さと半径の組 [(z, r), ...]（下から上）を Z 軸まわりに回した回転体。sx / sy で楕円に。"""
        m = Matrix.LocRotScale(Vector(center), rot or Quaternion(), Vector((1, 1, 1)))
        rings = []
        for z, r in profile:
            rings.append([self.bm.verts.new(m @ Vector((math.cos(2 * math.pi * i / seg) * r * sx,
                                                          math.sin(2 * math.pi * i / seg) * r * sy, z)))
                          for i in range(seg)])
        verts = [v for r in rings for v in r]
        for k in range(len(rings) - 1):
            for i in range(seg):
                j = (i + 1) % seg
                self.bm.faces.new((rings[k][i], rings[k][j], rings[k + 1][j], rings[k + 1][i]))
        if cap_bottom and profile[0][1] > 0:
            self.bm.faces.new(list(reversed(rings[0])))
        if cap_top and profile[-1][1] > 0:
            self.bm.faces.new(rings[-1])
        self._paint(verts, mat)
        return verts

    def tube(self, mat, points, radii, flat=1.0, ring=10, tip=True, up_hint=Vector((0, 0, 1))):
        """点列に沿って太さの変わる管（髪の毛束・スカーフの端など）。radii は各点の半径。"""
        rings = []
        prev_side = None
        n = len(points)
        for i, p in enumerate(points):
            t = (points[min(i + 1, n - 1)] - points[max(i - 1, 0)]).normalized()
            side = t.cross(up_hint if abs(t.dot(up_hint)) < 0.95 else Vector((1, 0, 0))).normalized()
            if prev_side is not None and side.dot(prev_side) < 0:
                side = -side
            prev_side = side
            up = side.cross(t).normalized()
            r = radii[i]
            if tip and i == n - 1:
                rings.append([self.bm.verts.new(p)])
            else:
                rings.append([self.bm.verts.new(p + side * math.cos(2 * math.pi * j / ring) * r
                                                + up * math.sin(2 * math.pi * j / ring) * r * flat) for j in range(ring)])
        verts = [v for r in rings for v in r]
        for k in range(n - 1):
            a, b = rings[k], rings[k + 1]
            for j in range(ring):
                if len(b) == 1:
                    self.bm.faces.new((a[j], a[(j + 1) % ring], b[0]))
                else:
                    self.bm.faces.new((a[j], a[(j + 1) % ring], b[(j + 1) % ring], b[j]))
        self.bm.faces.new(list(reversed(rings[0])))
        if len(rings[-1]) > 1:
            self.bm.faces.new(rings[-1])
        self._paint(verts, mat)
        return verts

    def plate(self, mat, outline, depth, center=(0, 0, 0), rot=None, scale=(1, 1, 1)):
        """XZ 平面の輪郭 [(x, z), ...] を +Y 方向に厚み depth で押し出した板。"""
        m = Matrix.LocRotScale(Vector(center), rot or Quaternion(), Vector(scale))
        front = [self.bm.verts.new(m @ Vector((x, 0, z))) for x, z in outline]
        back = [self.bm.verts.new(m @ Vector((x, depth, z))) for x, z in outline]
        self.bm.faces.new(list(reversed(front)))
        self.bm.faces.new(back)
        for i in range(len(outline)):
            j = (i + 1) % len(outline)
            self.bm.faces.new((front[i], front[j], back[j], back[i]))
        self._paint(front + back, mat)
        return front + back

    def build(self, smooth=True, parent=None, subsurf=0, bevel=0.0, sharp_angle=None):
        bmesh.ops.recalc_face_normals(self.bm, faces=self.bm.faces)
        mesh = bpy.data.meshes.new(self.name)
        self.bm.to_mesh(mesh)
        self.bm.free()
        for poly in mesh.polygons:
            poly.use_smooth = smooth
        if sharp_angle is not None and hasattr(mesh, "set_sharp_from_angle"):
            mesh.set_sharp_from_angle(angle=math.radians(sharp_angle))
        obj = bpy.data.objects.new(self.name, mesh)
        COL[self.collection].objects.link(obj)
        for m in self.mats:
            obj.data.materials.append(bpy.data.materials[m])
        if bevel > 0:
            mod = obj.modifiers.new("Bevel", "BEVEL")
            mod.width = bevel
            mod.segments = 2
            mod.limit_method = "ANGLE"
        if subsurf > 0:
            mod = obj.modifiers.new("Subdivision", "SUBSURF")
            mod.levels = subsurf
            mod.render_levels = subsurf
        if parent is not None:
            set_parent(obj, parent)
        return obj


def set_parent(obj, parent):
    """見た目の位置を保ったまま親子付けする。"""
    obj.parent = parent
    obj.matrix_parent_inverse = parent.matrix_world.inverted()


def pivot(name, location, parent=None):
    obj = bpy.data.objects.new(name, None)
    obj.empty_display_type = "SPHERE"
    obj.empty_display_size = 0.04
    obj.location = location
    COL["body"].objects.link(obj)
    if parent:
        set_parent(obj, parent)
    PIVOTS[name] = obj
    bpy.context.view_layer.update()
    return obj


# =============================================================================
# 3. 体の支点（ポーズ用）
# =============================================================================
def build_pivots():
    root = pivot("Hero_Root", (0, 0, 0))
    upper = pivot("Pivot_Upper", (0, 0, WAIST_Z), root)
    pivot("Pivot_Head", (0, 0, NECK_Z), upper)
    pivot("Pivot_Arm_L", SHOULDER, upper)
    # 右腕（剣）はゲームで「Weapon」から始まる名前のものが攻撃時に振られる
    pivot("Weapon_Arm_R", Vector((-SHOULDER.x, SHOULDER.y, SHOULDER.z)), upper)
    pivot("Pivot_Leg_L", (HIP_X, 0, WAIST_Z - 0.04), root)
    pivot("Pivot_Leg_R", (-HIP_X, 0, WAIST_Z - 0.04), root)


# =============================================================================
# 4. 頭と顔
# =============================================================================
def head_shape(co):
    """頭の球を、ほっぺがふっくらした形に変形する（顔パーツの位置合わせにも使う）。"""
    d = co - HEAD_C
    low = max(0.0, min(1.0, -d.z / HEAD_R.z))
    front = max(0.0, -d.y / HEAD_R.y)
    bulge = math.sin(low * math.pi)
    return Vector((co.x + d.x * 0.1 * bulge, co.y - 0.03 * bulge * front, co.z))


def face_point(az, el):
    """変形後の頭の表面の点と法線。"""
    p, n = ellipsoid_point(HEAD_C, HEAD_R, az, el)
    p2 = head_shape(p)
    a = head_shape(ellipsoid_point(HEAD_C, HEAD_R, az + 1, el)[0]) - p2
    b = head_shape(ellipsoid_point(HEAD_C, HEAD_R, az, el + 1)[0]) - p2
    n2 = a.cross(b).normalized()
    if n2.dot(n) < 0:
        n2 = -n2
    return p2, n2


def build_head():
    head = Part("Hero_Head", "face")
    verts = head.sphere("MAT_Skin", HEAD_C, HEAD_R, seg=32)
    # 下半分をふっくら（ほっぺ）させ、あごを少し前に。球を足すと継ぎ目ができるので頂点を動かす
    for v in verts:
        v.co = head_shape(v.co)
    for side in (-1, 1):
        head.sphere("MAT_Skin", HEAD_C + Vector((0.315 * side, 0.03, -0.03)), (0.045, 0.06, 0.075), seg=16)  # 耳
        p, n = face_point(34 * side, -22)
        head.sphere("MAT_Blush", p - n * 0.006, (0.05, 0.012, 0.026), rot=Vector((0, -1, 0)).rotation_difference(n), seg=16)
    p, n = face_point(0, -13)
    head.sphere("MAT_Skin", p - n * 0.005, (0.022, 0.018, 0.02), seg=12)  # 鼻
    head.build(parent=PIVOTS["Pivot_Head"], subsurf=1)

    neck = Part("Hero_Neck")
    neck.cone("MAT_Skin", (0, 0, NECK_Z - 0.08), (0, 0, 1), 0.2, 0.075, 0.07)
    neck.build(parent=PIVOTS["Pivot_Head"])
    build_face()


def build_face():
    """顔のパーツ。目は頭の表面に沿わせて貼る（大きく丸い、茶色の瞳）。"""
    for side, name in ((1, "Hero_Eyes_L"), (-1, "Hero_Eyes_R")):
        eye = Part(name, "face")
        p, n = face_point(21 * side, -4)
        q = Vector((0, -1, 0)).rotation_difference(n)
        # 目の各パーツは「正面(-Y) を向いた形」を作って、頭の法線方向へ回す
        def local(v, depth=0.0):
            return p + q @ Vector(v) + n * depth
        eye.sphere("MAT_EyeWhite", local((0, 0, 0)), (0.075, 0.02, 0.098), rot=q, seg=24)
        eye.sphere("MAT_Eye", local((-0.006 * side, -0.012, -0.008)), (0.061, 0.014, 0.08), rot=q, seg=24)
        eye.sphere("MAT_Pupil", local((-0.008 * side, -0.02, -0.014)), (0.033, 0.01, 0.046), rot=q, seg=16)
        eye.sphere("MAT_EyeHighlight", local((0.018, -0.028, 0.03)), (0.019, 0.006, 0.02), rot=q, seg=12)
        eye.sphere("MAT_EyeHighlight", local((-0.02, -0.027, -0.035)), (0.01, 0.005, 0.01), rot=q, seg=10)
        # 上まつげのライン（目の上側を太く）
        eye.sphere("MAT_EyeLine", local((0.004 * side, -0.004, 0.066)), (0.08, 0.017, 0.022), rot=q @ Quaternion((0, 1, 0), math.radians(-8 * side)), seg=20)
        eye.build(parent=PIVOTS["Pivot_Head"])

    # 眉（Mirror モディファイアで左右対称）
    brow = Part("Hero_Brows", "face")
    p, n = face_point(21, 14)
    q = Vector((0, -1, 0)).rotation_difference(n) @ Quaternion((0, 1, 0), math.radians(-17))
    brow.box("MAT_Brow", p + n * 0.005, (0.1, 0.025, 0.024), rot=q)
    obj = brow.build(parent=PIVOTS["Pivot_Head"], bevel=0.008)
    mod = obj.modifiers.new("Mirror", "MIRROR")
    mod.use_axis[0] = True
    obj.modifiers.move(len(obj.modifiers) - 1, 0)

    # 口（小さく、きりっと）
    mouth = Part("Hero_Mouth", "face")
    p, n = face_point(0, -27)
    q = Vector((0, -1, 0)).rotation_difference(n)
    # ゆるい「へ」の逆（にっこり）の弧を細い管で
    pts = [p + q @ Vector((0.045 * u, 0.0, 0.012 * u * u)) + n * 0.004 for u in (-1, -0.5, 0, 0.5, 1)]
    mouth.tube("MAT_Mouth", pts, [0.009, 0.011, 0.012, 0.011, 0.009], flat=0.8, ring=8, tip=False, up_hint=n)
    mouth.build(parent=PIVOTS["Pivot_Head"])


# =============================================================================
# 5. 髪
# =============================================================================
HAIR_C = HEAD_C + Vector((0, 0.035, 0.05))
HAIR_R = Vector((0.345, 0.335, 0.33))


def hair_lock(part, az, el, length, width, direction, bend, flat=0.55, curl=0.0):
    """頭の表面 (az, el) から生える、先のとがった平たい毛束（ベジェ曲線に沿った管）。"""
    base, n = ellipsoid_point(HAIR_C, HAIR_R, az, el)
    base = base - n * 0.07
    d1 = Vector(direction).normalized()
    ctrl = base + d1 * length * 0.55
    end = ctrl + (d1 + Vector(bend)).normalized() * length * 0.55
    pts, radii = [], []
    steps = 9
    for i in range(steps + 1):
        t = i / steps
        pts.append(base * (1 - t) ** 2 + ctrl * 2 * (1 - t) * t + end * t * t)
        radii.append(width * (1 - t) ** 0.75 + 0.004)
    # 断面の平たい向き: 頭の表面に沿うように（法線を「上」とみなす）
    part.tube("MAT_Hair", pts, radii, flat=flat, ring=10, up_hint=n)


def build_hair():
    hair = Part("Hero_Hair", "hair")
    hair.sphere("MAT_Hair", HAIR_C, HAIR_R, seg=32)
    hair.sphere("MAT_Hair", HEAD_C + Vector((0, 0.1, -0.08)), (0.325, 0.25, 0.28), seg=24)  # 後頭部の下
    UP, BACK = Vector((0, 0, 1)), Vector((0, 1, 0))
    # (az, el, 長さ, 太さ, 種類) … 大きめの毛束を少なめに。上へ立ち上がってから後ろへ流れる
    locks = [
        # --- 前髪: ヘッドバンドの上から立ち上がり、斜め後ろへ
        (-10, 40, 0.34, 0.14, "front"), (16, 42, 0.32, 0.13, "front"), (-38, 34, 0.3, 0.13, "front"),
        (44, 34, 0.28, 0.12, "front"),
        # --- てっぺん（後ろへ大きく流れる）
        (-22, 64, 0.36, 0.15, "top"), (22, 66, 0.34, 0.15, "top"), (0, 82, 0.34, 0.15, "top"),
        (-60, 55, 0.3, 0.14, "top"), (60, 55, 0.3, 0.14, "top"),
        # --- 横（外へはねる）
        (-88, 28, 0.26, 0.13, "side"), (88, 28, 0.26, 0.13, "side"), (-112, 4, 0.22, 0.12, "side"),
        (112, 4, 0.22, 0.12, "side"),
        # --- 後ろ（後ろ下へとがる）
        (-140, 45, 0.3, 0.14, "back"), (140, 45, 0.3, 0.14, "back"), (180, 50, 0.3, 0.15, "back"),
        (-160, 12, 0.26, 0.13, "back"), (160, 12, 0.26, 0.13, "back"), (180, -8, 0.22, 0.13, "back"),
    ]
    for az, el, length, width, kind in locks:
        _, n = ellipsoid_point(HAIR_C, HAIR_R, az, el)
        if kind == "front":
            direction = n * 0.45 + UP * 0.8 + BACK * 0.1
            bend = BACK * 1.6 - UP * 0.2
        elif kind == "top":
            direction = n * 0.5 + UP * 0.45 + BACK * 0.6
            bend = BACK * 1.2 - UP * 0.35
        elif kind == "side":
            direction = n + UP * 0.35 + BACK * 0.35
            bend = UP * 0.35 + BACK * 0.3
        else:
            direction = n + BACK * 0.3 + UP * 0.1
            bend = -UP * 0.35
        hair_lock(hair, az, el, length, width, direction, bend, flat=0.45)
    # 額に少しかかる小さな毛束（ヘッドバンドの上）
    for az, ln in ((-14, 0.14), (12, 0.12)):
        p, n = ellipsoid_point(HAIR_C, HAIR_R, az, 30)
        hair.tube("MAT_Hair", [p - n * 0.04, p + n * 0.04 + Vector((0, -0.03, -0.04)), p + n * 0.05 + Vector((az * 0.001, -0.05, -ln))],
                  [0.055, 0.04, 0.0], flat=0.6, up_hint=n)
    # もみあげ
    for side in (-1, 1):
        p, n = ellipsoid_point(HAIR_C, HAIR_R, 78 * side, -10)
        hair.tube("MAT_Hair", [p - n * 0.04, p + Vector((0.01 * side, -0.02, -0.1)), p + Vector((0.01 * side, -0.03, -0.2))],
                  [0.06, 0.045, 0.0], flat=0.6, up_hint=n)
    hair.build(parent=PIVOTS["Pivot_Head"])

    # ヘッドバンド（金）と宝石（青）
    band = Part("Hero_Headband", "face")
    band.torus("MAT_Gold", HEAD_C + Vector((0, 0.015, 0.105)), 1.0, 0.075, rot=Euler((math.radians(-13), 0, 0)).to_quaternion(),
               scale=(0.338, 0.322, 0.338), seg=48, ring=10)
    gem_p = HEAD_C + Vector((0, -0.318, 0.1))
    band.lathe("MAT_Gold", [(-0.012, 0.0), (-0.012, 0.068), (0.012, 0.074), (0.02, 0.062), (0.02, 0.0)], center=gem_p,
               seg=32, rot=Euler((math.radians(90), 0, 0)).to_quaternion())
    band.build(parent=PIVOTS["Pivot_Head"], sharp_angle=50)
    gem = Part("Hero_Gem", "face")
    gem.sphere("MAT_BlueGem", gem_p + Vector((0, -0.02, 0)), (0.05, 0.03, 0.05), seg=24)
    gem.build(parent=PIVOTS["Pivot_Head"])


# =============================================================================
# 6. 胴体・服
# =============================================================================
def build_body():
    body = Part("Hero_Body")
    body.lathe("MAT_BlueCloth", [(0.64, 0.19), (0.75, 0.2), (0.9, 0.21), (0.99, 0.19), (1.05, 0.13), (1.09, 0.06)], sy=0.8)
    body.build(parent=PIVOTS["Pivot_Upper"], subsurf=1)

    tunic = Part("Hero_Tunic")
    tunic.lathe("MAT_BlueCloth", [(0.36, 0.0), (0.36, 0.305), (0.42, 0.29), (0.52, 0.255), (0.6, 0.232), (0.72, 0.232),
                                  (0.86, 0.235), (0.97, 0.22), (1.03, 0.17), (1.07, 0.1)], sy=0.84, cap_bottom=False, cap_top=False)
    tunic.lathe("MAT_Cream", [(0.345, 0.3), (0.36, 0.315), (0.39, 0.308), (0.395, 0.29)], sy=0.84, cap_bottom=False, cap_top=False)
    tunic.build(parent=PIVOTS["Pivot_Upper"], subsurf=1)

    belt = Part("Hero_Belt")
    belt.lathe("MAT_Leather", [(0.575, 0.238), (0.585, 0.245), (0.635, 0.245), (0.645, 0.238)], sy=0.85)
    # たすき掛けの革ベルト（右肩から左腰へ、胸に沿わせる）
    pts = []
    for i in range(9):
        t = i / 8
        z = 1.0 - t * 0.38
        x = -0.17 + t * 0.34
        y = -0.2 * 0.84 * math.sqrt(max(0.0, 1 - (x / 0.24) ** 2)) - 0.012
        pts.append(Vector((x, y, z)))
    for i in range(len(pts) - 1):
        a, b = pts[i], pts[i + 1]
        belt.box("MAT_Leather", (a + b) / 2, (0.058, 0.018, (b - a).length + 0.01), rot=quat_to(b - a))
    belt.box("MAT_Leather", (0.2, -0.13, 0.52), (0.085, 0.07, 0.1))           # ポーチ
    belt.box("MAT_LeatherDark", (0.2, -0.166, 0.55), (0.08, 0.01, 0.04))
    belt.build(parent=PIVOTS["Pivot_Upper"], bevel=0.006)

    buckle = Part("Hero_Belt_Buckle")
    front = -0.245 * 0.85
    buckle.box("MAT_Gold", (0, front - 0.012, 0.61), (0.1, 0.02, 0.075))
    buckle.box("MAT_LeatherDark", (0, front - 0.023, 0.61), (0.05, 0.004, 0.035))
    buckle.box("MAT_Gold", (-0.09, -0.2, 0.9), (0.05, 0.018, 0.045), rot=quat_to(pts[2] - pts[1]))   # たすきの金具
    buckle.build(parent=PIVOTS["Pivot_Upper"], bevel=0.006, sharp_angle=40)

    scarf = Part("Hero_Scarf")
    scarf.torus("MAT_RedScarf", (0, 0.0, 1.1), 0.13, 0.075, scale=(1.15, 1.0, 1.0), seg=32, ring=12)
    scarf.torus("MAT_RedScarf", (0, 0.0, 1.03), 0.16, 0.06, scale=(1.15, 1.0, 1.0), seg=32, ring=12)
    scarf.sphere("MAT_RedScarf", (-0.1, -0.14, 1.05), (0.065, 0.055, 0.06))  # 結び目（キャラの右）
    # 後ろへなびく 2 本の端
    for off, ln in ((0.0, 0.3), (0.06, 0.24)):
        start = Vector((-0.12 + off, 0.1, 1.05))
        scarf.tube("MAT_RedScarf", [start, start + Vector((-0.05, 0.12, -0.08)), start + Vector((-0.1, 0.2, -ln))],
                   [0.05, 0.045, 0.0], flat=0.35, up_hint=Vector((0, 1, 0)))
    scarf.build(parent=PIVOTS["Pivot_Upper"], subsurf=1)


# =============================================================================
# 7. 腕・手・脚・ブーツ（A ポーズで作り、あとで支点を回してポーズをつける）
# =============================================================================
def build_limbs():
    for side, suffix in ((1, "L"), (-1, "R")):
        piv = PIVOTS["Pivot_Arm_L" if side == 1 else "Weapon_Arm_R"]
        sh = Vector((SHOULDER.x * side, 0, SHOULDER.z))
        # 腕は真下に下ろした形で作り、支点を回して A ポーズ・待機ポーズにする
        arm = Part("Hero_Arm_" + suffix)
        arm.sphere("MAT_BlueCloth", sh + Vector((0.015 * side, 0, -0.01)), (0.095, 0.09, 0.095))       # ふくらんだ袖
        arm.cone("MAT_Skin", sh + Vector((0.01 * side, 0, -0.06)), (0, 0, -1), 0.12, 0.052, 0.05, seg=16)  # 二の腕
        arm.lathe("MAT_Leather", [(-0.34, 0.058), (-0.31, 0.066), (-0.2, 0.062), (-0.185, 0.056)],
                  center=sh + Vector((0.01 * side, 0, 0.0)), seg=16)                                      # 革の小手
        arm.lathe("MAT_LeatherDark", [(-0.215, 0.064), (-0.2, 0.07), (-0.19, 0.064)], center=sh + Vector((0.01 * side, 0, 0)), seg=16)
        arm.build(parent=piv, subsurf=1)
        glove = Part("Hero_Glove_" + suffix)
        hand = sh + Vector((0.01 * side, -0.005, -0.4))
        glove.sphere("MAT_Leather", hand, (0.074, 0.07, 0.08))                  # 手（少し大きめ）
        glove.sphere("MAT_Leather", hand + Vector((-0.045 * side, -0.04, 0.02)), (0.028, 0.028, 0.035))  # 親指
        glove.build(parent=piv, subsurf=1)

        # 脚とブーツ
        leg_piv = PIVOTS["Pivot_Leg_L" if side == 1 else "Pivot_Leg_R"]
        x = HIP_X * side
        leg = Part("Hero_Leg_" + suffix)
        leg.cone("MAT_Pants", (x, 0, WAIST_Z - 0.02), (0, 0, -1), 0.3, 0.08, 0.072, seg=16)
        leg.build(parent=leg_piv, subsurf=1)
        boot = Part("Hero_Boot_" + suffix)
        boot.lathe("MAT_Leather", [(0.1, 0.082), (0.2, 0.084), (0.27, 0.088)], center=(x, 0.0, 0), seg=16, cap_top=False)
        boot.lathe("MAT_Leather", [(0.25, 0.09), (0.26, 0.108), (0.34, 0.112), (0.35, 0.095), (0.33, 0.085)],
                   center=(x, 0.0, 0), seg=16, cap_bottom=False, cap_top=False)                                 # 折り返し
        boot.sphere("MAT_Leather", (x, -0.05, 0.075), (0.09, 0.16, 0.085), seg=20)                        # つま先（丸く大きめ）
        boot.box("MAT_LeatherDark", (x, -0.04, 0.012), (0.17, 0.3, 0.025))                                # 靴底
        boot.lathe("MAT_LeatherDark", [(0.21, 0.087), (0.23, 0.09), (0.235, 0.087)], center=(x, 0.0, 0), seg=16)
        boot.build(parent=leg_piv, subsurf=1)


# =============================================================================
# 8. 剣（右手）
# =============================================================================
def build_sword():
    hand_piv = PIVOTS["Weapon_Arm_R"]
    hand = Vector((-SHOULDER.x - 0.01, -0.005, SHOULDER.z - 0.4))
    sword = bpy.data.objects.new("Hero_Sword", None)
    sword.empty_display_type = "ARROWS"
    sword.empty_display_size = 0.12
    COL["gear"].objects.link(sword)
    # 剣のローカル座標: +Z = 刃の向き。腕を下ろした状態で刃が前（-Y）を向くように置く
    sword.matrix_world = Matrix.LocRotScale(hand, quat_to((0, -1, 0.0)), Vector((1, 1, 1)))
    set_parent(sword, hand_piv)
    bpy.context.view_layer.update()

    def part(name, fn, **kw):
        p = Part(name, "gear")
        fn(p)
        obj = p.build(**kw)
        obj.parent = sword
        obj.matrix_parent_inverse = Matrix.Identity(4)
        return obj

    def blade(p):
        # ひし形断面の刃（中央に稜線）と、とがった先端
        L, W, T = 0.78, 0.068, 0.02
        rings = []
        for z, w in ((0.0, W * 0.9), (0.62, W), (0.72, W * 0.8)):
            rings.append([p.bm.verts.new((x, y, z)) for x, y in ((w, 0), (0, -T), (-w, 0), (0, T))])
        tip = p.bm.verts.new((0, 0, L))
        for k in range(len(rings) - 1):
            for i in range(4):
                j = (i + 1) % 4
                p.bm.faces.new((rings[k][i], rings[k][j], rings[k + 1][j], rings[k + 1][i]))
        for i in range(4):
            p.bm.faces.new((rings[-1][i], rings[-1][(i + 1) % 4], tip))
        p.bm.faces.new(list(reversed(rings[0])))
        p._paint([v for r in rings for v in r] + [tip], "MAT_Silver")
        for v in p.bm.verts:
            v.co.z += 0.075

    def guard(p):
        p.box("MAT_Gold", (0, 0, 0.045), (0.26, 0.055, 0.05))
        for s in (-1, 1):
            p.sphere("MAT_Gold", (0.13 * s, 0, 0.06), (0.032, 0.03, 0.035))
            p.cone("MAT_Gold", (0.12 * s, 0, 0.05), (s, 0, 0.7), 0.06, 0.028, 0.0, seg=10)
        p.lathe("MAT_Gold", [(-0.03, 0.0), (-0.03, 0.035), (0.03, 0.035), (0.03, 0.0)], center=(0, 0, 0.05),
                seg=20, rot=Euler((math.radians(90), 0, 0)).to_quaternion())

    def handle(p):
        p.lathe("MAT_Leather", [(-0.14, 0.024), (-0.12, 0.027), (0.0, 0.026), (0.02, 0.024)], seg=12)
        for z in (-0.1, -0.065, -0.03):
            p.lathe("MAT_LeatherDark", [(z - 0.006, 0.027), (z, 0.031), (z + 0.006, 0.027)], seg=12)
        p.sphere("MAT_Gold", (0, 0, -0.165), (0.036, 0.036, 0.036), seg=16)

    def gems(p):
        for s in (-1, 1):
            p.sphere("MAT_BlueGem", (0, 0.035 * s, 0.05), (0.024, 0.012, 0.024), seg=16)
        p.sphere("MAT_BlueGem", (0, 0, -0.2), (0.016, 0.016, 0.016), seg=12)

    part("Hero_Sword_Blade", blade, smooth=False, bevel=0.004)
    part("Hero_Sword_Guard", guard, bevel=0.006, sharp_angle=45)
    part("Hero_Sword_Handle", handle)
    part("Hero_Sword_Gem", gems)
    return sword


# =============================================================================
# 9. 盾（左腕）
# =============================================================================
def heater_outline(w, h, n=12):
    """上辺がゆるく弧を描き、下がとがった盾の輪郭（XZ 平面）。"""
    pts = []
    for i in range(7):
        t = i / 6
        x = -w / 2 + w * t
        pts.append((x, h * 0.46 + math.sin(math.pi * t) * h * 0.04))
    for i in range(1, n + 1):
        t = i / n
        pts.append(((w / 2) * (1 - t ** 1.7), h * 0.46 - t * h * 0.96))
    for i in range(n - 1, 0, -1):
        t = i / n
        pts.append((-(w / 2) * (1 - t ** 1.7), h * 0.46 - t * h * 0.96))
    return pts


BIRD = [  # 翼を広げた鳥の紋章（右半分。左は反転）
    (0.0, 0.2), (0.028, 0.175), (0.03, 0.125), (0.07, 0.15), (0.115, 0.2), (0.15, 0.17), (0.155, 0.11),
    (0.13, 0.06), (0.1, 0.02), (0.055, 0.0), (0.06, -0.09), (0.1, -0.15), (0.04, -0.125), (0.0, -0.18),
]


def build_shield():
    arm_piv = PIVOTS["Pivot_Arm_L"]
    W, H = 0.44, 0.54
    center = Vector((SHOULDER.x + 0.1, -0.07, SHOULDER.z - 0.3))
    shield = Part("Hero_Shield", "gear")
    shield.plate("MAT_Gold", heater_outline(W, H), 0.045)
    shield.plate("MAT_ShieldBlue", heater_outline(W * 0.84, H * 0.84), 0.04, center=(0, -0.012, -0.005))
    shield.box("MAT_LeatherDark", (0, 0.06, 0), (0.06, 0.03, 0.2))  # 持ち手
    obj = shield.build(smooth=False, bevel=0.01)
    emblem = Part("Hero_Shield_Emblem", "gear")
    bird = BIRD + [(-x, z) for x, z in reversed(BIRD[1:-1])]
    emblem.plate("MAT_Gold", bird, 0.02, center=(0, -0.03, 0.005), scale=(1.02, 1, 1.0))
    emblem_obj = emblem.build(smooth=False, bevel=0.004)
    emblem_obj.parent = obj
    # 盾の置き場所: 左の前腕の外側。待機ポーズで正面を向くように、腕の回転を打ち消す向きにしておく
    obj.matrix_world = Matrix.LocRotScale(center, Euler((0, 0, math.radians(-12))).to_quaternion(), Vector((1, 1, 1)))
    set_parent(obj, arm_piv)
    return obj


# =============================================================================
# 10. マント（Cloth Simulation で形を作ってメッシュ化。失敗したら手続き生成）
# =============================================================================
def _cape_grid(rows=16, cols=14):
    """肩から下へ、裾が広がる初期形状（背中側 +Y）。"""
    bm = bmesh.new()
    grid = []
    for r in range(rows + 1):
        t = r / rows
        z = 1.03 - t * 0.78
        half_w = 0.2 + t * 0.32
        row = []
        for c in range(cols + 1):
            u = c / cols * 2 - 1
            x = u * half_w
            y = 0.2 + t * 0.2 + (1 - u * u) * 0.07 * (0.3 + t) - 0.05 * (1 - t) * u * u
            row.append(bm.verts.new((x, y, z)))
        grid.append(row)
    for r in range(rows):
        for c in range(cols):
            bm.faces.new((grid[r][c], grid[r][c + 1], grid[r + 1][c + 1], grid[r + 1][c]))
    return bm, (cols + 1)


def build_cape():
    bm, row_len = _cape_grid()
    mesh = bpy.data.meshes.new("Hero_Cape")
    bm.to_mesh(mesh)
    bm.free()
    cape = bpy.data.objects.new("Hero_Cape", mesh)
    COL["body"].objects.link(cape)
    cape.data.materials.append(bpy.data.materials["MAT_RedCape"])
    used_sim = False
    if USE_CLOTH_SIM:
        try:
            used_sim = _simulate_cape(cape, row_len)
        except Exception as exc:  # シミュレーションが使えない環境では手続き生成の形のまま
            print("Cloth Simulation をスキップしました:", exc)
    for poly in cape.data.polygons:
        poly.use_smooth = True
    mod = cape.modifiers.new("Solidify", "SOLIDIFY")
    mod.thickness = 0.022
    mod.offset = 0.0
    mod = cape.modifiers.new("Subdivision", "SUBSURF")
    mod.levels = 1
    mod.render_levels = 1
    # 襟（肩にかかる部分）
    collar = Part("Hero_Cape_Collar")
    collar.torus("MAT_RedCape", (0, 0.04, 1.02), 0.2, 0.035, scale=(1.05, 0.95, 0.6), seg=32, ring=8)
    collar.build(parent=PIVOTS["Pivot_Upper"])
    set_parent(cape, PIVOTS["Pivot_Upper"])
    print("マント:", "Cloth Simulation で作成" if used_sim else "手続き生成で作成")
    return cape


def _simulate_cape(cape, row_len):
    scene = bpy.context.scene
    group = cape.vertex_groups.new(name="Pin")
    group.add(list(range(row_len)), 1.0, "REPLACE")          # 一番上の列（肩）を固定
    # 体の当たり判定（見えない楕円体）
    proxy_bm = bmesh.new()
    bmesh.ops.create_uvsphere(proxy_bm, u_segments=16, v_segments=10, radius=1.0,
                              matrix=Matrix.LocRotScale(Vector((0, 0.02, 0.72)), Quaternion(), Vector((0.3, 0.26, 0.42))))
    proxy_mesh = bpy.data.meshes.new("CapeCollider")
    proxy_bm.to_mesh(proxy_mesh)
    proxy_bm.free()
    proxy = bpy.data.objects.new("CapeCollider", proxy_mesh)
    COL["body"].objects.link(proxy)
    proxy.modifiers.new("Collision", "COLLISION")
    cloth = cape.modifiers.new("Cloth", "CLOTH")
    s = cloth.settings
    s.quality = 6
    s.mass = 0.2
    s.tension_stiffness = 20
    s.compression_stiffness = 20
    s.bending_stiffness = 2.0
    s.vertex_group_mass = "Pin"
    cloth.collision_settings.distance_min = 0.012
    old_frame = scene.frame_current
    for f in range(1, 26):
        scene.frame_set(f)
    depsgraph = bpy.context.evaluated_depsgraph_get()
    baked = bpy.data.meshes.new_from_object(cape.evaluated_get(depsgraph))
    scene.frame_set(old_frame)
    cape.modifiers.remove(cloth)
    old = cape.data
    cape.data = baked
    baked.name = "Hero_Cape"
    bpy.data.meshes.remove(old)
    cape.vertex_groups.clear()
    bpy.data.objects.remove(proxy, do_unlink=True)
    bpy.data.meshes.remove(proxy_mesh)
    return True


# =============================================================================
# 11. ポーズ
# =============================================================================
def apply_pose(name):
    """支点（Empty）を回してポーズをつける。"""
    def rot(piv, x=0.0, y=0.0, z=0.0):
        PIVOTS[piv].rotation_euler = Euler((math.radians(x), math.radians(y), math.radians(z)))

    if name == "A":
        rot("Pivot_Arm_L", y=-38)
        rot("Weapon_Arm_R", y=38)
        for p in ("Pivot_Upper", "Pivot_Head", "Pivot_Leg_L", "Pivot_Leg_R"):
            rot(p)
    else:  # IDLE: 足を少し開き、剣を前に構え、盾を前に出し、少し胸を張る
        rot("Pivot_Upper", x=4)
        rot("Pivot_Head", x=-3, z=4)
        rot("Pivot_Arm_L", x=-38, y=-18, z=12)
        rot("Weapon_Arm_R", x=-58, y=22, z=-8)
        rot("Pivot_Leg_L", y=-6)
        rot("Pivot_Leg_R", y=6)
    bpy.context.view_layer.update()


# =============================================================================
# 12. カメラとライト
# =============================================================================
def build_cameras_and_lights():
    target = Vector((0, 0, 0.98))
    views = {"Cam_Front": (0, 0), "Cam_Side": (90, 0), "Cam_Back": (180, 0), "Cam_Front34": (-35, 12)}
    for name, (az, el) in views.items():
        cam_data = bpy.data.cameras.new(name)
        cam_data.type = "ORTHO"
        cam_data.ortho_scale = 2.5
        cam = bpy.data.objects.new(name, cam_data)
        COL["setup"].objects.link(cam)
        a, e = math.radians(az), math.radians(el)
        cam.location = target + Vector((math.sin(a) * math.cos(e), -math.cos(a) * math.cos(e), math.sin(e))) * 6
        cam.rotation_euler = (target - cam.location).to_track_quat("-Z", "Y").to_euler()
    persp = bpy.data.cameras.new("Cam_Preview")
    persp.lens = 60
    cam = bpy.data.objects.new("Cam_Preview", persp)
    COL["setup"].objects.link(cam)
    cam.location = target + Vector((-2.4, -4.6, 1.2))
    cam.rotation_euler = (target + Vector((0, 0, 0.1)) - cam.location).to_track_quat("-Z", "Y").to_euler()
    bpy.context.scene.camera = cam

    def area(name, loc, energy, size, color=(1, 1, 1)):
        light = bpy.data.lights.new(name, "AREA")
        light.energy = energy
        light.size = size
        light.color = color
        obj = bpy.data.objects.new(name, light)
        COL["setup"].objects.link(obj)
        obj.location = loc
        obj.rotation_euler = (target - Vector(loc)).to_track_quat("-Z", "Y").to_euler()
    area("Key_Light", (-2.2, -3.2, 3.2), 500, 2.5, (1.0, 0.96, 0.9))
    area("Fill_Light", (3.0, -2.2, 1.6), 260, 3.0, (0.9, 0.95, 1.0))
    area("Rim_Light", (0.8, 3.2, 2.8), 520, 2.0, (1.0, 0.95, 0.85))

    world = bpy.data.worlds.get("Hero_World") or bpy.data.worlds.new("Hero_World")
    bpy.context.scene.world = world
    world.use_nodes = True
    bg = world.node_tree.nodes.get("Background")
    bg.inputs[0].default_value = (0.33, 0.35, 0.42, 1.0)
    bg.inputs[1].default_value = 0.9
    bpy.context.scene.view_settings.view_transform = "Standard"


# =============================================================================
# 13. アーマチュア
# =============================================================================
BONES = [
    # (名前, 親, 根元, 先)
    ("root", None, (0, 0, 0), (0, 0, 0.15)),
    ("pelvis", "root", (0, 0, 0.5), (0, 0, 0.64)),
    ("spine", "pelvis", (0, 0, 0.64), (0, 0, 0.8)),
    ("chest", "spine", (0, 0, 0.8), (0, 0, 1.0)),
    ("neck", "chest", (0, 0, 1.0), (0, 0, 1.13)),
    ("head", "neck", (0, 0, 1.13), (0, 0, 1.85)),
]
for _s, _n in ((1, "L"), (-1, "R")):
    BONES += [
        ("upper_arm." + _n, "chest", (0.2 * _s, 0, 0.98), (0.26 * _s, 0, 0.8)),
        ("forearm." + _n, "upper_arm." + _n, (0.26 * _s, 0, 0.8), (0.31 * _s, 0, 0.64)),
        ("hand." + _n, "forearm." + _n, (0.31 * _s, 0, 0.64), (0.34 * _s, -0.02, 0.54)),
        ("thigh." + _n, "pelvis", (HIP_X * _s, 0, 0.56), (HIP_X * _s, 0, 0.34)),
        ("shin." + _n, "thigh." + _n, (HIP_X * _s, 0, 0.34), (HIP_X * _s, 0, 0.1)),
        ("foot." + _n, "shin." + _n, (HIP_X * _s, 0, 0.1), (HIP_X * _s, -0.16, 0.03)),
    ]


def build_armature():
    arm_data = bpy.data.armatures.new("Hero_Armature")
    arm = bpy.data.objects.new("Hero_Armature", arm_data)
    COL["rig"].objects.link(arm)
    arm.show_in_front = True
    bpy.context.view_layer.objects.active = arm
    for obj in bpy.context.view_layer.objects:
        obj.select_set(False)
    arm.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    for name, parent, head, tail in BONES:
        b = arm_data.edit_bones.new(name)
        b.head = head
        b.tail = tail
        if parent:
            b.parent = arm_data.edit_bones[parent]
    bpy.ops.object.mode_set(mode="OBJECT")
    if BIND_TO_ARMATURE:
        _bind_parts(arm)
    return arm


def _bind_parts(arm):
    """第 2 段階用: 各パーツをボーンに親子付けする（ウェイトなしの剛体バインド）。"""
    pairs = {"Pivot_Upper": "spine", "Pivot_Head": "head", "Pivot_Arm_L": "upper_arm.L", "Weapon_Arm_R": "upper_arm.R",
             "Pivot_Leg_L": "thigh.L", "Pivot_Leg_R": "thigh.R"}
    for piv_name, bone in pairs.items():
        piv = PIVOTS[piv_name]
        mw = piv.matrix_world.copy()
        piv.parent = arm
        piv.parent_type = "BONE"
        piv.parent_bone = bone
        piv.matrix_world = mw


# =============================================================================
# 14. 保存と書き出し
# =============================================================================
def output_dir():
    return OUTPUT_DIR or (os.path.dirname(bpy.data.filepath) if bpy.data.filepath else os.path.expanduser("~"))


def export_glb():
    path = os.path.join(output_dir(), GLB_NAME)
    for obj in bpy.context.view_layer.objects:
        obj.select_set(False)
    for key in ("body", "face", "hair", "gear"):
        for obj in COL[key].all_objects:
            obj.select_set(True)
    bpy.ops.export_scene.gltf(filepath=path, export_format="GLB", use_selection=True, export_apply=True)
    print("ゲーム用モデルを書き出しました:", path)


def save_blend():
    path = os.path.join(output_dir(), BLEND_NAME)
    bpy.ops.wm.save_as_mainfile(filepath=path)
    print("保存しました:", path)


# =============================================================================
# 実行
# =============================================================================
def main():
    reset_scene()
    make_materials()
    build_pivots()
    build_head()
    build_hair()
    build_body()
    build_limbs()
    build_sword()
    build_shield()
    build_cape()
    apply_pose(POSE)
    build_cameras_and_lights()
    if CREATE_ARMATURE:
        build_armature()
    if EXPORT_GLB:
        export_glb()
    if SAVE_BLEND:
        save_blend()
    print("勇者の生成が完了しました（ポーズ: %s）" % POSE)


main()
