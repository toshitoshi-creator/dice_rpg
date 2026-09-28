# DICE BATTLE

3D のサイコロを **実際に物理演算で転がして** 敵と戦う、ターン制バトルゲームのプロトタイプ（MVP）です。
Godot 4.3 以降 / GDScript。外部アセット不要（モデル・エフェクト・仮 SE はすべてコードで生成）。

## 遊び方

1. Godot 4.3+ でこのフォルダ（`project.godot`）を開き、F5 で実行
2. 「サイコロを振る」ボタン（または Space / Enter）を押す
3. サイコロが飛んで転がり、止まった時の上面の数字でダメージが決まる
4. 敵が生きていれば反撃してくる
5. 敵を倒すとステージクリア → 次のステージへ。4 ステージ目のボスを倒せば GAME CLEAR
6. 負けたら「このステージに再挑戦」か「最初から」

| ステージ | 敵 | HP | 攻撃 | プレイヤー最大HP |
|---|---|---|---|---|
| STAGE 1 はじまりの草原 | SLIME | 100 | 10 | 100 |
| STAGE 2 ゴブリンの森 | GOBLIN | 120 | 12 | 120 |
| STAGE 3 がいこつの墓場 | SKELETON | 150 | 13 | 140 |
| BOSS 竜の玉座 | DRAGON | 220 | 14 | 160 |

ステージをクリアするたびに最大 HP が +20 され、各ステージ開始時に HP は全回復する。

| 出目 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| ダメージ | 5 | 10 | 15 | 20 | 30 | 50 (CRITICAL) |

## スマホ / ブラウザで遊ぶ（Cloudflare Pages）

`.github/workflows/deploy-web.yml` が push のたびに「テスト → Web 書き出し → Cloudflare Pages へ公開」を行います。

1. Cloudflare で API トークンを作成（テンプレート無しの Custom token、権限 **Account → Cloudflare Pages → Edit**）
2. GitHub リポジトリの Settings → Secrets and variables → Actions に登録
   - `CLOUDFLARE_API_TOKEN` … 上のトークン
   - `CLOUDFLARE_ACCOUNT_ID` … Cloudflare ダッシュボード右側に表示されるアカウント ID
3. push する（または Actions タブから手動実行）と、`dice-battle` プロジェクトが自動作成されて公開される。URL は Actions の実行結果（Summary）に表示される

補足:
- Web 版はマルチスレッド無しで書き出すので、特別な HTTP ヘッダー無しで iPhone（Safari 16.4+）/ Android で動く
- Cloudflare Pages は 1 ファイル 25 MiB までなので、`tools/web_postprocess.py` が `index.wasm`（約 35MB）を gzip（約 8MB）し、ブラウザ内で展開するローダーを差し込む
- 日本語はシステムフォントに頼らず、同梱の Noto Sans JP（必要な文字だけのサブセット、`assets/fonts/`、SIL OFL）で表示する。UI に新しい漢字を追加したら `tools/make_font_subset.py` でフォントを作り直す

ローカルで Web 版を試す:

```bash
godot --headless --path . --export-release "Web" build/web/index.html
python3 tools/web_postprocess.py build/web
python3 -m http.server -d build/web 8000   # http://localhost:8000
```

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
│   ├── enemy_database.gd        敵一覧（Slime / Goblin / Skeleton / Dragon）
│   ├── stage_data.gd            ステージデータ Resource
│   └── stage_database.gd        ステージ構成（3 ステージ + ボス）
├── game/game_progress.gd        進行状況（現在のステージ・最大 HP の成長）
├── ui/
│   ├── battle_ui.gd             HP バー・ボタン・出目表示・勝敗画面
│   ├── hp_bar.gd                滑らかに減る HP バー
│   └── damage_popup.gd          浮かび上がるダメージ数字
├── vfx/hit_effect.gd            ヒットエフェクト
├── world/battle_field.gd        空・ライト・床・サイコロ台・背景
└── audio/sound_manager.gd       効果音（ファイルが無ければ合成音で代用）
tests/run_tests.gd               自動統合テスト
tools/web_postprocess.py         Web 書き出し後の Cloudflare 向け処理
tools/make_font_subset.py        同梱日本語フォントの生成
assets/fonts/                    Noto Sans JP サブセット + ライセンス
.github/workflows/deploy-web.yml CI（テスト・Web 書き出し・Cloudflare Pages 公開）
```

## 調整・拡張ポイント

- **ダメージ表**: `DamageCalculator.dice_damage`、クリティカル倍率は `critical_multiplier`
- **サイコロ能力**（偶数で追加ダメージ、1 で毒など）: `DamageCalculator._apply_dice_abilities()` と `AttackResult.tags`
- **サイコロの種類**: `Dice.dice_type` / `Dice.face_values`（面ごとの数字を差し替え可能）
- **敵の追加**: `EnemyDatabase.ENEMIES` にデータを追加し、`EnemyActor._build_model()` にモデルを追加
- **ステージの追加・並べ替え**: `StageDatabase.STAGES`（見た目テーマは `BattleField.THEMES`）
- **成長量**: `GameProgress.MAX_HP_PER_CLEAR`
- **効果音**: `assets/sounds/` に `dice_roll`, `dice_hit`, `attack`, `damage`, `critical`, `enemy_attack`, `enemy_die`, `victory`, `defeat`, `button` という名前で `.ogg` / `.wav` / `.mp3` を置くだけで差し替わる

## テスト

```bash
godot --headless --path . --import               # 初回のみ（クラスキャッシュ生成）
godot --headless --path . -s res://tests/run_tests.gd
```

サイコロの面判定・ダメージ表の単体テストに加え、実際にバトルを起動して
「振る → 物理で転がる → 出目 → ダメージ → 反撃 → 勝利 / 敗北 → リトライ」と連打耐性を検証します。
