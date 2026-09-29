class_name HeroPortrait
extends SubViewport
## カットイン用に、主人公の顔のアップをリアルタイムで描く小さな 3D 画面。
## get_texture() を TextureRect に渡して使う。普段は描画を止めておき、start() / stop() で切り替える。

var _actor: PlayerActor


func _init() -> void:
	size = Vector2i(512, 512)
	transparent_bg = false
	own_world_3d = true
	render_target_update_mode = SubViewport.UPDATE_DISABLED


func _ready() -> void:
	var env := Environment.new()
	# カットインらしい、赤〜オレンジの背景
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.75, 0.12, 0.05)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 0.9, 0.75)
	env.ambient_light_energy = 0.6
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var key := DirectionalLight3D.new()
	key.light_color = Color(1.0, 0.92, 0.8)
	key.light_energy = 1.4
	key.rotation_degrees = Vector3(-25, 150, 0)
	add_child(key)
	var rim := DirectionalLight3D.new()
	rim.light_color = Color(1.0, 0.6, 0.2)
	rim.light_energy = 1.2
	rim.rotation_degrees = Vector3(-10, -30, 0)
	add_child(rim)

	_actor = PlayerActor.new()
	add_child(_actor)
	var top := maxf(ModelKit.compute_aabb(_actor.model).end.y, 1.0)
	var cam := Camera3D.new()
	cam.fov = 30
	add_child(cam)
	# 主人公は -Z を向いているので、-Z 側の少し右上から顔を狙う
	var face := Vector3(0, top * 0.7, 0)
	cam.look_at_from_position(face + Vector3(-0.5, 0.15, -top * 1.05), face + Vector3(0, -top * 0.03, 0))


func start() -> void:
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	if _actor:
		_actor.start_idle()


func stop() -> void:
	render_target_update_mode = SubViewport.UPDATE_DISABLED
