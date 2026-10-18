class_name DragScroll
extends ScrollContainer
## 指（またはマウス）でドラッグしてスクロールできる ScrollContainer。
##
## 中身のボタンがタッチを受け取ってしまうと、ふつうの ScrollContainer はスクロールしない。
## そこで _input で押した位置と動きを見て、自分でスクロールする（はなすと少しすべる）。
## ドラッグしたあとのボタンの pressed は、was_dragged() を見て無視すること。
## タッチはマウスのイベントとしても届く（emulate_mouse_from_touch）ので、マウスのイベントだけを見る。

## この距離（px）より動いたらドラッグ（それまではタップ）
const DRAG_THRESHOLD := 14.0
## マウスホイール 1 目盛りのスクロール量
const WHEEL_STEP := 90.0
## はなしたあとのすべり（速さが 1 秒でこの割合になる）
const FLING_DECAY := 0.02

var _pressing := false
var _dragged := false
var _start := Vector2.ZERO
var _start_scroll := 0
var _velocity := 0.0
var _last_y := 0.0
var _last_time := 0


func _init() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED


## 最後の操作がドラッグだったか（ボタンの pressed でタップかどうか見分ける）
func was_dragged() -> bool:
	return _dragged


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		_pressing = false
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if mb.pressed and _is_mine(mb.position):
				scroll_vertical += roundi(WHEEL_STEP * mb.factor if mb.factor > 0.0 else WHEEL_STEP) * (1 if mb.button_index == MOUSE_BUTTON_WHEEL_DOWN else -1)
				_velocity = 0.0
				get_viewport().set_input_as_handled()
			return
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		if mb.pressed:
			_pressing = _is_mine(mb.position)
			if _pressing:
				_dragged = false
				_start = mb.position
				_start_scroll = scroll_vertical
				_velocity = 0.0
				_last_y = mb.position.y
				_last_time = Time.get_ticks_msec()
		elif _pressing:
			_pressing = false
			if not _dragged:
				_velocity = 0.0
	elif event is InputEventMouseMotion and _pressing:
		var mm := event as InputEventMouseMotion
		var dy := mm.position.y - _start.y
		if not _dragged and absf(dy) >= DRAG_THRESHOLD:
			_dragged = true
			_start.y += signf(dy) * DRAG_THRESHOLD
			dy = mm.position.y - _start.y
		if _dragged:
			scroll_vertical = _start_scroll - roundi(dy)
			var now := Time.get_ticks_msec()
			var dt := maxf((now - _last_time) / 1000.0, 0.001)
			_velocity = lerpf(_velocity, -(mm.position.y - _last_y) / dt, 0.5)
			_last_y = mm.position.y
			_last_time = now


func _process(delta: float) -> void:
	if _pressing or absf(_velocity) < 20.0:
		return
	var before := scroll_vertical
	scroll_vertical += roundi(_velocity * delta)
	if scroll_vertical == before:
		_velocity = 0.0
		return
	_velocity *= pow(FLING_DECAY, delta)


## 位置がこのスクロールの中か
func _is_mine(pos: Vector2) -> bool:
	return get_global_rect().has_point(pos)
