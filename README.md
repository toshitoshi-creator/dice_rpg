# DICE BATTLE

3D のサイコロを **実際に物理演算で転がして** 敵と戦う、ターン制バトルゲームのプロトタイプ（MVP）です。
Godot 4.3 以降 / GDScript。外部アセット不要（モデル・エフェクト・仮 SE はすべてコードで生成）。

## 遊び方

1. Godot 4.3+ でこのフォルダ（`project.godot`）を開き、F5 で実行
2. 「サイコロを振る」ボタン（または Space / Enter）を押す
3. サイコロが飛んで転がり、止まった時の上面の数字でダメージが決まる
4. 敵が生きていれば反撃してくる
5. 敵を倒すとステージクリア（経験値とジェム）→「つぎのステージへ」で主人公が歩いて前進（地面がスクロールし、次の敵が近づいてくる）。
   c-10 のボスを倒せば CHAPTER CLEAR
6. 負けたら「もう一度 たたかう」。勝てないときは前のステージでレベルを上げるか、そうびを見直す

### スペシャル技

- 敵にダメージを与える（その敵の HP の割合に応じて）・ダメージを受けると **SP ゲージ** が溜まる。ステージをまたいで持ち越す
  （雑魚 1 体を倒しきると約 32%。チュートリアルではボス戦の始まりごろに満タンになる）
- 満タンになると「SP」ボタンが光り、押すと派手な演出（光の柱 → カットイン → サイコロ変身）のあとに攻撃する
- 技は **武器ごとに違う**。最初の武器「ゆうしゃのつるぎ」の技「ブレイブ・ロール」は、サイコロの 6 面が 4・5・6 だけの金色のサイコロになる
- 武器と技の定義: `scripts/data/weapon_database.gd`、効果の処理: `BattleManager._activate_special()`、ゲージの溜まり方: `GameProgress`

### 画面の流れ

```
ホーム（チャプターを左右スワイプで選ぶ）─ ぼうけんに でる → ステージ選択（c-1〜c-10）→ バトル → つぎのステージへ / ホームへ
      ├ そうび（ぶき・たて・よろい・ダイス を付けかえ）
      └ ガチャ（そうびガチャ / ダイスガチャ）
```

- 画面の切りかえ: `scripts/app/game_app.gd`（main.tscn）。画面: `scripts/ui/home_screen.gd`（チャプターのカードは `chapter_carousel.gd`）,
  `stage_select_screen.gd`, `gacha_screen.gd`, `equipment_screen.gd`
- チャプターのカードの背景はそのチャプターのボス。クリア前は黒いシルエット、クリアするとちゃんと表示される。
  ボスの画像 `assets/images/bosses/chapter_XX.png` は `tools/render_boss_portraits.gd` で作る（ボスの見た目を変えたら作り直す）

### ステージとレベル（数式はすべて `scripts/game/balance.gd`）

- **20 チャプター × 10 ステージ**（1-1〜20-10）。c-10 がボス。ひとつ前のステージをクリアすると次が遊べる
- **敵は 1〜3 体のグループ**で出てくる（そのチャプターと前のチャプターの雑魚からいろいろな組み合わせ。ボスには手下がつく）。
  あふれたダメージは次の敵へ。敵は全員が順番に攻撃してくる
- 敵はステージごとになめらかに強くなる。おすすめレベル: 1-1 = Lv1、10-10 = Lv51、20-10 = Lv76
- 敵をたおすと **経験値** と **ゴールド**（1-1 の敵で 10,000）。**Lv40 をこえるとレベルが上がりにくくなる**
- **レベル 10 ごとにサイコロが 1 つ増える**（Lv10 で 2 こ、Lv20 で 3 こ … Lv50 で 6 こ）
- **サイコロはかけ算**: ダメージ = 1 こ目の出目のダメージ（下の表）×（2 こ目以降の倍率 1:×1 2:×2 3:×3 4:×4 5:×6 6:×10）× ゾロ目 × レベルの攻撃力
- **ゾロ目**: 同じ目が 2 こで ×2、3 こで ×4、4 こで ×8 …、全部同じ（オールゾロ目）ならさらに ×2。派手な演出つき
- **クリティカル**: 6 がサイコロの半分以上（1 こなら 6）。フラッシュ・光の線・スローモーションの演出
- **「サイコロを振る」を長押し**するとサイコロが浮かんで高速回転し、はなすと勢いよく投げる
- チャプター 10 は Lv50（サイコロ 6 こ）くらいでないと厳しい
- たては「受けるダメージ −○%」、よろいは「最大 HP +○%」（数値がインフレしても効くように割合）

### ジェムとガチャ

- 最初に **1000 ジェム**。ステージクリアで **50**、ボス（c-10）で **150**、はじめてチャプターをクリアすると **+300**
- ガチャ: 1 回 100 / 10 回 900 ジェム。確率は SSR 2% / SR 8% / R 30% / N 60%、10 回は SR 以上が 1 つ確定
- 持っているものが出たらジェムに変わる（N 10 / R 30 / SR 100 / SSR 300）
- ロジック: `scripts/game/gacha.gd`、ジェムと持ち物: `GameProgress`（`user://save.cfg` に保存。Web 版はブラウザに保存）

### そうび

「そうび」（ホーム・バトル中の自分のターン・結果画面）で付けかえる。バトル中の付けかえはすぐに反映される。

| 部位 | 効果 | 数 | 定義 |
|---|---|---|---|
| ぶき | ダメージ +atk、武器ごとのスペシャル技 | 15 | `scripts/data/weapon_database.gd` |
| たて | 受けるダメージ −def% | 9 | `scripts/data/equipment_database.gd` |
| よろい | 最大 HP +hp% | 9 | 同上 |
| ダイス | サイコロの 6 面の目と色 | 8 | `scripts/data/dice_database.gd` |

スペシャル技の種類: 目を変える（4〜6 / 3〜6 / 1 か 6 / 5 か 6 / ぜんぶ 6）、ダメージ 2 倍・3 倍、HP 回復。
アイコンは `docs/ICONS.md`、サイコロのアイコンは `tools/make_dice_icons.gd` で作る。

**強化**（ゴールド）: 装備画面の「きょうか」。いちばん安くて 100,000 ゴールド、レベル・レア度が高いほど高い（最大 Lv20）。
ぶき・ダイスはダメージ倍率、たてはダメージカット、よろいは最大 HP が上がる。
**売却**: ぶきとダイスは「うる」でゴールドに。ダイスのほうが高く売れる（装備中・最初から持っている物は売れない）。

| 出目 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| ダメージ | 5 | 10 | 15 | 20 | 30 | 50 (CRITICAL) |

## 敵図鑑（全 240 体）

- 雑魚 60 種族 × 色違い 3 = 180 体、ボス 20 種族 × 色違い 3 = 60 体
- 20 チャプター × 12 体。チャプター c の No. は `(c-1)*12+1` 〜 `c*12`
  （雑魚 A/B/C の 1 色目 → 2 色目 → 3 色目 → ボスの 1〜3 色目 の順）
- 強さは出てくるステージで決まる（`EnemyDatabase.stats_for(no)` → `Balance`）
- 一覧: [docs/ENEMY_LIST.md](docs/ENEMY_LIST.md)、画像: `docs/bestiary/`

| CH | エリア | 雑魚 | ボス |
|---|---|---|---|
| 1 | はじまりの草原 | スライム / マッシュ / ハニービー | スライムキング |
| 2 | ゴブリンの森 | ゴブリン / ウルフ / トレント | オーガ |
| 3 | 灼熱の砂漠 | スコーピオン / カクタス / マミー | サンドワーム |
| 4 | さまよう墓場 | スケルトン / ゴースト / ゾンビ | リッチ |
| 5 | くらやみの洞窟 | バット / スパイダー / ゴーレム | サイクロプス |
| 6 | こおりの山 | スノーマン / ペンギンナイト / イエティ | マンモス |
| 7 | ほのおの火山 | ウィスプ / サラマンダー / ファイアタートル | フェニックス |
| 8 | しずみの海 | クラブ / ジェリー / マーマン | クラーケン |
| 9 | 魔王城 | インプ / リビングアーマー / ガーゴイル | ドラゴン |
| 10 | 魔界 | イビルアイ / ミミック / リーパー | デーモンロード |
| 11 | おかしの国 | カップケーキ / グミベア / キャンディスネーク | ケーキキング |
| 12 | からくり工場 | ネジロボ / プロペラドローン / ハグルマン | ギガロボ |
| 13 | ようせいの花園 | ピクシー / マンドラゴラ / バタフライ | フェアリークイーン |
| 14 | ゆうれい船 | ガイコツかいぞく / ヤドカリ / オウム | ゆうれいせんちょう |
| 15 | てんくうの城 | グリフォン / クラウドン / てんくうナイト | サンダーバード |
| 16 | こだいの神殿 | スカラベ / アヌビスせんし / トーテム | ファラオ |
| 17 | ひみつのジャングル | ゴリラ / カメレオン / ジャングルスネーク | ティラノ |
| 18 | ほしぞらの宇宙 | UFO / エイリアン / ほしのかけら | エイリアンクイーン |
| 19 | ゆめのせかい | ねむりヒツジ / テディベア / ピエロ | ナイトメア |
| 20 | かみがみの領域 | エンジェル / ライトスピリット / ゴッドナイト | オメガ |

### 敵を追加・変更するには

- 種族（名前・色違いの色・攻撃名・説明・3D モデル）は `scripts/enemies/chapter_XX.gd` に 1 チャプター分ずつ書いてある
- モデルは `ModelKit`（`scripts/enemies/model_kit.gd`）の部品（球・カプセル・ツノ・目など）の組み合わせ。
  色は「役割名」で指定し、パレットを変えるだけで色違いになる。大きさは自動で `height` / `width` に収まる
- 変更後は次を実行して確認用画像と一覧を更新する

```bash
godot --path . --rendering-driver opengl3 -s res://tools/render_bestiary.gd   # 画像（画面が必要）
godot --headless --path . -s res://tools/export_enemy_list.gd                   # docs/ENEMY_LIST.md
python3 tools/make_font_subset.py NotoSansJP-ExtraBold.ttf                      # 新しい漢字を使ったら
```

## Blender で作ったモデルを使う

`assets/models/player.glb`（主人公）や `assets/models/enemies/<種族ID>.glb`（敵）を置くと、そのモデルに差し替わる。
Blender 用のスクリプト（`tools/blender/`）と手順は [docs/BLENDER_GUIDE.md](docs/BLENDER_GUIDE.md)。

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
│   ├── custom_models.gd         .glb モデルへの差し替え
│   ├── battle_actor.gd          HP・ステータス・被弾/攻撃/撃破アニメの共通基底
│   ├── player.gd                プレイヤー（剣士モデル）
│   └── enemy.gd                 敵（EnemyData からモデル生成）
├── data/
│   ├── enemy_data.gd            敵データ Resource（図鑑 1 体分）
│   ├── enemy_database.gd        敵図鑑 240 体・No. とステータス
│   ├── stage_data.gd            ステージデータ Resource
│   └── stage_database.gd        チャプター / ステージ構成
├── enemies/
│   ├── model_kit.gd             敵モデル用の部品・パレット・サイズ計測
│   ├── enemy_models.gd          種族 ID → モデル生成の振り分け
│   └── chapter_01.gd 〜 10.gd   各チャプターの 4 種族（データ + 3D モデル）
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
tools/render_bestiary.gd         敵図鑑の確認画像を生成
tools/blender/                   Blender でモデルを作るスクリプト（主人公・スライム）
assets/models/                   Blender で作った .glb の置き場所
tools/export_enemy_list.gd       docs/ENEMY_LIST.md を生成
docs/                            敵図鑑の一覧と画像
assets/fonts/                    Noto Sans JP サブセット + ライセンス
.github/workflows/deploy-web.yml CI（テスト・Web 書き出し・Cloudflare Pages 公開）
```

## 調整・拡張ポイント

- **ダメージ表**: `DamageCalculator.dice_damage`、クリティカル倍率は `critical_multiplier`
- **サイコロ能力**（偶数で追加ダメージ、1 で毒など）: `DamageCalculator._apply_dice_abilities()` と `AttackResult.tags`
- **サイコロの種類**: `Dice.dice_type` / `Dice.face_values`（面ごとの数字を差し替え可能）
- **敵のバランス**: `EnemyDatabase.stats_for()`（No. → HP / 攻撃 / 防御）
- **チャプター・ステージの追加**: `StageDatabase.CHAPTERS`（敵は図鑑 No. で指定、見た目テーマは `BattleField.THEMES`）
- **成長量**: `GameProgress.MAX_HP_PER_CLEAR`
- **効果音**: `assets/sounds/` に `dice_roll`, `dice_hit`, `attack`, `damage`, `critical`, `enemy_attack`, `enemy_die`, `victory`, `defeat`, `button` という名前で `.ogg` / `.wav` / `.mp3` を置くだけで差し替わる

## テスト

```bash
godot --headless --path . --import               # 初回のみ（クラスキャッシュ生成）
godot --headless --path . -s res://tests/run_tests.gd
```

サイコロの面判定・ダメージ表の単体テストに加え、実際にバトルを起動して
「振る → 物理で転がる → 出目 → ダメージ → 反撃 → 勝利 / 敗北 → リトライ」と連打耐性を検証します。
