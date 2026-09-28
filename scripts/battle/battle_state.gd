class_name BattleState
extends RefCounted
## バトルの状態定義。
## 状態ごとに「何ができるか」をここに集約し、UI やマネージャーはこれを参照する。

enum State {
	SETUP,        ## バトル準備中（ステージ開始演出中）
	PLAYER_TURN,  ## プレイヤーの入力待ち（サイコロを振れる唯一の状態）
	ROLLING,      ## サイコロが転がっている
	RESULT,       ## 出目確定〜演出中
	PLAYER_ATTACK,## プレイヤーの攻撃演出中
	ENEMY_TURN,   ## 敵の行動中
	VICTORY,      ## ステージクリア（敵を倒した）
	DEFEAT,       ## 敗北
	GAME_CLEAR,   ## ボスを倒して全ステージクリア
}


static func to_name(state: State) -> String:
	return State.keys()[state]


static func can_roll(state: State) -> bool:
	return state == State.PLAYER_TURN


static func is_battle_over(state: State) -> bool:
	return state == State.VICTORY or state == State.DEFEAT or state == State.GAME_CLEAR
