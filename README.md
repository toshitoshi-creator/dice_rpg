# DICE BATTLE

3D のサイコロを **実際に物理演算で転がして** 敵と戦う、ターン制バトルゲームのプロトタイプ（MVP）です。
Godot 4.3 以降 / GDScript。外部アセット不要（モデル・エフェクト・仮 SE はすべてコードで生成）。

## 遊び方

1. Godot 4.3+ でこのフォルダ（`project.godot`）を開き、F5 で実行
2. 「サイコロを振る」ボタン（または Space / Enter）を押す
3. サイコロが飛んで転がり、止まった時の上面の数字でダメージが決まる
4. 敵が生きていれば反撃してくる
5. 敵の HP を 0 にすれば VICTORY、自分の HP が 0 になれば DEFEAT
6. 「もう一度戦う」でバトルを最初から

| 出目 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| ダメージ | 5 | 10 | 15 | 20 | 30 | 50 (CRITICAL) |

## 仕組み

- サイコロは `RigidBody3D`。ランダムな位置・向き・速度・回転で投げ、床と見えない壁に当たって転がる
- 一定時間ほぼ静止したら停止と判定し、**6 面の法線のうち真上 (Vector3.UP) とのドット積が最大の面** を出目にする
- 斜めに立てかかって止まった場合は軽く弾いて転がし直す。確定後は `freeze` で姿勢を固定するので、見えている上面と出目が必ず一致する
- バトルは `BattleState` の状態遷移で進行し、`PLAYER_TURN` 以外ではサイコロを振れない（連打対策）

## ファイル構成

```
scenes/main.tscn                 エントリーシーン（BattleManager）
scripts/
├── battle/
│   ├── battle_manager.gd        ターン進行・状態遷移・演出の順序制御
│   ├── battle_state.gd          状態 enum と「振れるか」等の判定
│   ├── damage_calculator.gd     ダメージ表・クリティカル・サイコロ能力フック
│   ├── attack_result.gd         攻撃結果データ
│   └── battle_camera.gd         カメラの寄り・揺れ
├── dice/
│   ├── dice.gd                  物理サイコロ・出目判定
│   └── dice_result.gd           出目データ
├── actors/
│   ├── battle_actor.gd          HP・ステータス・被弾/攻撃/撃破アニメの共通基底
│   ├── player.gd                プレイヤー（剣士モデル）
│   └── enemy.gd                 敵（EnemyData からモデル生成）
├── data/
│   ├── enemy_data.gd            敵データ Resource
│   └── enemy_database.gd        敵一覧（Slime。ここに Goblin 等を追加）
├── ui/
│   ├── battle_ui.gd             HP バー・ボタン・出目表示・勝敗画面
│   ├── hp_bar.gd                滑らかに減る HP バー
│   └── damage_popup.gd          浮かび上がるダメージ数字
├── vfx/hit_effect.gd            ヒットエフェクト
├── world/battle_field.gd        空・ライト・床・サイコロ台・背景
└── audio/sound_manager.gd       効果音（ファイルが無ければ合成音で代用）
tests/run_tests.gd               自動統合テスト
```

## 調整・拡張ポイント

- **ダメージ表**: `DamageCalculator.dice_damage`、クリティカル倍率は `critical_multiplier`
- **サイコロ能力**（偶数で追加ダメージ、1 で毒など）: `DamageCalculator._apply_dice_abilities()` と `AttackResult.tags`
- **サイコロの種類**: `Dice.dice_type` / `Dice.face_values`（面ごとの数字を差し替え可能）
- **敵の追加**: `EnemyDatabase.ENEMIES` にデータを追加し、必要なら `EnemyActor._build_model()` にモデルを追加
- **効果音**: `assets/sounds/` に `dice_roll`, `dice_hit`, `attack`, `damage`, `critical`, `enemy_attack`, `enemy_die`, `victory`, `defeat`, `button` という名前で `.ogg` / `.wav` / `.mp3` を置くだけで差し替わる

## テスト

```bash
godot --headless --path . --import               # 初回のみ（クラスキャッシュ生成）
godot --headless --path . -s res://tests/run_tests.gd
```

サイコロの面判定・ダメージ表の単体テストに加え、実際にバトルを起動して
「振る → 物理で転がる → 出目 → ダメージ → 反撃 → 勝利 / 敗北 → リトライ」と連打耐性を検証します。
