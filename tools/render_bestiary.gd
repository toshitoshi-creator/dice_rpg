extends SceneTree
## 敵図鑑の確認用画像を作る（チャプターごとに 12 体を 1 枚に並べる）。
##
## 実行（画面のある環境 / xvfb-run で）:
##   godot --path . --rendering-driver opengl3 -s res://tools/render_bestiary.gd -- 1 2 3
## 引数なしなら全チャプター。出力: tests/output/bestiary/chapter_XX.png と docs/bestiary/chapter_XX.jpg
##
## 並び: 列 = 雑魚 A / B / C / ボス、行 = 色違い 1 / 2 / 3

const TILE := 300
const OUT_DIR := "res://tests/output/bestiary/"
const DOCS_DIR := "res://docs/bestiary/"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var chapters: Array[int] = []
	for a in OS.get_cmdline_user_args():
		if a.is_valid_int():
			chapters.append(a.to_int())
	if chapters.is_empty():
		for c in EnemyDatabase.chapter_scripts().size():
			chapters.append(c + 1)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DOCS_DIR))
	for c in chapters:
		await _render_chapter(c)
	quit()


func _render_chapter(chapter: int) -> void:
	var enemies := EnemyDatabase.chapter_enemies(chapter)
	var viewports: Array[SubViewport] = []
	var cells: Array[Vector2i] = []
	for e in enemies:
		var local := e.no - (chapter - 1) * EnemyDatabase.PER_CHAPTER - 1
		var cell := Vector2i(3, local - 9) if e.is_boss else Vector2i(local % 3, local / 3)
		viewports.append(_make_tile(e))
		cells.append(cell)
	for i in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	var sheet := Image.create(TILE * 4, TILE * 3, false, Image.FORMAT_RGBA8)
	for i in viewports.size():
		var img := viewports[i].get_texture().get_image()
		img.convert(Image.FORMAT_RGBA8)
		sheet.blit_rect(img, Rect2i(0, 0, TILE, TILE), cells[i] * TILE)
	var path := ProjectSettings.globalize_path(OUT_DIR + "chapter_%02d.png" % chapter)
	sheet.save_png(path)
	sheet.save_jpg(ProjectSettings.globalize_path(DOCS_DIR + "chapter_%02d.jpg" % chapter), 0.88)
	print("saved ", path)
	for vp in viewports:
		vp.queue_free()
	await process_frame


func _make_tile(data: EnemyData) -> SubViewport:
	var vp := SubViewport.new()
	vp.size = Vector2i(TILE, TILE)
	vp.own_world_3d = true
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.2, 0.18, 0.28) if data.is_boss else Color(0.3, 0.36, 0.42)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.75, 0.75, 0.8)
	env.ambient_light_energy = 0.3
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var we := WorldEnvironment.new()
	we.environment = env
	vp.add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, 30, 0)
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	vp.add_child(sun)
	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(30, 30)
	floor_mesh.mesh = plane
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = env.background_color.lightened(0.05)
	floor_mesh.material_override = floor_mat
	vp.add_child(floor_mesh)

	var enemy := EnemyActor.new()
	enemy.setup(data)
	vp.add_child(enemy)
	enemy.stop_idle()
	var size := enemy.get_model_size()
	var h := maxf(size.y, 1.0)
	var span := maxf(h, size.x * 0.8)
	var cam := Camera3D.new()
	cam.fov = 40
	vp.add_child(cam)
	var dist := span * 1.9 + 1.2
	var target := Vector3(0, h * 0.5 - span * 0.12, 0)
	cam.look_at_from_position(Vector3(dist * 0.42, h * 0.55 + dist * 0.28, dist), target)

	var label := Label3D.new()
	label.text = "No.%03d %s" % [data.no, data.display_name]
	label.font_size = 64 if data.display_name.length() <= 7 else 50
	label.pixel_size = span * 0.0028
	label.outline_size = 16
	label.modulate = Color(1, 0.85, 0.35) if data.is_boss else Color(1, 1, 1)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.position = target + Vector3(0, -span * 0.62, 0)
	vp.add_child(label)
	var stats := Label3D.new()
	stats.text = "HP %d  ATK %d  DEF %d" % [data.max_hp, data.attack, data.defense]
	stats.font_size = 48
	stats.pixel_size = span * 0.0026
	stats.outline_size = 12
	stats.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	stats.no_depth_test = true
	stats.position = label.position + Vector3(0, -span * 0.15, 0)
	vp.add_child(stats)
	return vp
