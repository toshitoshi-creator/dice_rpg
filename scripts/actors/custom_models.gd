class_name CustomModels
extends RefCounted
## Blender などで作った .glb モデルへの差し替え。
##
## 置き場所（あればそちらを使い、なければ今までのコードで作ったモデルを使う）:
##   プレイヤー: res://assets/models/player.glb
##   敵:         res://assets/models/enemies/<ID>.glb       … 1 体だけ（例: slime_2.glb = ベリースライム）
##               res://assets/models/enemies/<種族ID>.glb    … 色違い 3 体すべて（例: slime.glb）
##
## Blender 側の約束（詳しくは docs/BLENDER_GUIDE.md）:
##   - キャラクターの正面を「正面ビュー（テンキー 1）」側（-Y 方向）に向け、足元を Z = 0 に置く
##   - 大きさは自由（ゲーム側で自動調整）
##   - マテリアル名を敵パレットの役割名（body, belly, eye_glow など）にすると、色違いでその色に置き換わる
##   - オブジェクト（空の Empty でもよい）の名前で動きが付く:
##       Weapon… = 攻撃で振る（原点が回転の中心）
##       Wing…   = 羽ばたく（原点が付け根。左右は位置で判定）
##       Tail…   = しっぽを振る
##   - glTF のアニメーションに "idle" があれば待機中にループ再生する

const PLAYER_PATH := "res://assets/models/player.glb"
const ENEMY_DIR := "res://assets/models/enemies/"


static func player_path() -> String:
	return PLAYER_PATH if ResourceLoader.exists(PLAYER_PATH) else ""


## 敵の差し替えモデルのパス（無ければ空文字）。ID 専用 → 種族共通 の順に探す。
static func enemy_path(data: EnemyData) -> String:
	if data == null:
		return ""
	for file_name in [String(data.id), String(data.species_id)]:
		var path := "%s%s.glb" % [ENEMY_DIR, file_name]
		if ResourceLoader.exists(path):
			return path
	return ""


## .glb を読み込んで parent に追加し、マテリアルと動く部位を ModelKit に登録する。
static func attach(path: String, parent: Node3D, kit: ModelKit) -> Node3D:
	var scene := load(path) as PackedScene
	if scene == null:
		push_warning("could not load model: " + path)
		return null
	var inst := scene.instantiate() as Node3D
	if inst == null:
		return null
	parent.add_child(inst)
	_prepare(inst, kit)
	return inst


static func _prepare(root: Node, kit: ModelKit) -> void:
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		stack.append_array(node.get_children())
		if node is MeshInstance3D:
			_prepare_materials(node as MeshInstance3D, kit)
		if node is Node3D:
			_register_part(node as Node3D, kit)
		if node is AnimationPlayer:
			_play_idle(node as AnimationPlayer)


## 被弾フラッシュ・フェードで個別に色を変えられるよう、マテリアルを複製して登録する。
## マテリアル名がパレットの役割名と同じなら、色違いの色に置き換える。
static func _prepare_materials(mi: MeshInstance3D, kit: ModelKit) -> void:
	if mi.mesh == null:
		return
	for i in mi.mesh.get_surface_count():
		var src := mi.get_active_material(i)
		var role := StringName(src.resource_name.to_lower()) if src else &""
		var m: BaseMaterial3D
		if role != &"" and kit.palette.has(role):
			m = kit.mat(role)
		elif src is BaseMaterial3D:
			m = (src as BaseMaterial3D).duplicate() as BaseMaterial3D
			kit.materials.append(m)
		else:
			continue
		mi.set_surface_override_material(i, m)


static func _register_part(node: Node3D, kit: ModelKit) -> void:
	var n := node.name.to_lower()
	if n.begins_with("weapon") and kit.parts.get("weapon") == null:
		kit.parts["weapon"] = node
	elif n.begins_with("wing"):
		kit.add_wing(node, -1.0 if node.position.x < 0.0 else 1.0)
	elif n.begins_with("tail") and kit.parts.get("tail") == null:
		kit.parts["tail"] = node


static func _play_idle(player: AnimationPlayer) -> void:
	for anim_name in player.get_animation_list():
		if String(anim_name).to_lower().begins_with("idle"):
			var anim := player.get_animation(anim_name)
			anim.loop_mode = Animation.LOOP_LINEAR
			player.play(anim_name)
			return
