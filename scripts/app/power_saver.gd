class_name PowerSaver
extends RefCounted
## スマホ（ブラウザ版）が熱くならないように、描画を軽くする設定。
##
## - フレームレートの上限: メニューは 30、バトルは 60（120Hz の画面でも 120 回は描かない）
## - 3D は画面の解像度そのままではなく、縦 TARGET_3D_HEIGHT ピクセルくらいで描いて引きのばす
##   （スマホは 1 ピクセルが細かいので、そのまま描くと何倍も重い。文字などの 2D はくっきりのまま）
## - 影は 1 枚・小さめ、グロー（光のにじみ）は切る（BattleField で is_light() を見る）

const MENU_FPS := 30
const BATTLE_FPS := 60
const TARGET_3D_HEIGHT := 1100.0
const MIN_3D_SCALE := 0.5
## テストで軽量モードを試すとき true にする
static var force_light := false


## 軽くするか（ブラウザ版とスマホ版）
static func is_light() -> bool:
	return force_light or OS.has_feature("web") or OS.has_feature("mobile")


## メニュー画面（3D なし）
static func enter_menu() -> void:
	if is_light():
		Engine.max_fps = MENU_FPS


## バトル画面
static func enter_battle(viewport: Viewport) -> void:
	if not is_light():
		return
	Engine.max_fps = BATTLE_FPS
	viewport.scaling_3d_scale = scale_for_height(DisplayServer.window_get_size().y)


## 窓の高さ（ピクセル）→ 3D の描画の倍率
static func scale_for_height(height: float) -> float:
	if height <= 0.0:
		return 1.0
	return clampf(TARGET_3D_HEIGHT / height, MIN_3D_SCALE, 1.0)
