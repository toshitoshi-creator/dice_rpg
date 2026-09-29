extends SceneTree
## ホーム画面のチャプター選択で背景に出す、各チャプターのボスの画像を作る（背景は透明）。
## ボスの見た目（scripts/enemies/chapter_XX.gd）や assets/models/enemies の .glb を変えたら実行する:
##   xvfb-run godot --path . --rendering-driver opengl3 -s res://tools/render_boss_portraits.gd
## 出力: assets/images/bosses/chapter_XX.png（512×512）

const SIZE := 512
const OUT_DIR := "res://assets/images/bosses/"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	for c in range(1, EnemyDatabase.CHAPTER_COUNT + 1):
		await _render(c)
	quit()


## チャプター c のボス（1 色目）の図鑑番号
static func boss_no(c: int) -> int:
	return (c - 1) * EnemyDatabase.PER_CHAPTER + 10


func _render(c: int) -> void:
	var data := EnemyDatabase.get_enemy(boss_no(c))
	var vp := SubViewport.new()
	vp.size = Vector2i(SIZE, SIZE)
	vp.own_world_3d = true
	vp.transparent_bg = true
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var env := Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.8, 0.8, 0.85)
	env.ambient_light_energy = 0.45
	var we := WorldEnvironment.new()
	we.environment = env
	vp.add_child(we)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-35, 25, 0)
	key.light_energy = 1.1
	vp.add_child(key)
	var rim := DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(-20, 200, 0)
	rim.light_energy = 0.6
	vp.add_child(rim)

	var enemy := EnemyActor.new()
	enemy.setup(data)
	vp.add_child(enemy)
	enemy.stop_idle()
	var size := enemy.get_model_size()
	var h := maxf(size.y, 1.0)
	var span := maxf(h, size.x * 0.9)
	var cam := Camera3D.new()
	cam.fov = 35
	vp.add_child(cam)
	var dist := span * 1.95 + 0.8
	var target := Vector3(0, h * 0.5, 0)
	# 敵は +Z（プレイヤーの方）を向いているので、+Z 側の少し斜め上から
	cam.look_at_from_position(target + Vector3(dist * 0.3, dist * 0.18, dist), target)
	for i in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	var img := vp.get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	var path := OUT_DIR + "chapter_%02d.png" % c
	img.save_png(ProjectSettings.globalize_path(path))
	print("boss portrait: ", path, " ", data.display_name)
	vp.queue_free()
	await process_frame
