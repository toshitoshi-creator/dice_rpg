class_name DamagePopup
extends Label3D
## 3D 空間に浮かぶダメージ数字。上へ移動しながら拡大→フェードアウトして消える。


static func spawn(parent: Node, world_position: Vector3, text_value: String, color: Color, big: bool = false) -> DamagePopup:
	var popup := DamagePopup.new()
	popup.text = text_value
	popup.modulate = color
	popup.font_size = 160 if big else 110
	popup.outline_size = 36
	popup.outline_modulate = Color(0.08, 0.02, 0.05)
	popup.pixel_size = 0.006
	popup.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	popup.no_depth_test = true
	popup.shaded = false
	popup.render_priority = 10
	popup.outline_render_priority = 9
	popup.position = world_position
	parent.add_child(popup)
	popup._animate(big)
	return popup


func _animate(big: bool) -> void:
	scale = Vector3.ONE * 0.4
	var peak := 1.5 if big else 1.2
	var start := position
	var drift := Vector3(randf_range(-0.3, 0.3), 0, 0)
	var t := create_tween()
	t.tween_property(self, "scale", Vector3.ONE * peak, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(self, "position", start + Vector3(0, 0.6, 0) + drift * 0.5, 0.15)
	t.tween_property(self, "scale", Vector3.ONE, 0.2)
	t.parallel().tween_property(self, "position", start + Vector3(0, 1.4, 0) + drift, 0.9).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(self, "modulate:a", 0.0, 0.5).set_delay(0.45)
	t.parallel().tween_property(self, "outline_modulate:a", 0.0, 0.5).set_delay(0.45)
	t.tween_callback(queue_free)
