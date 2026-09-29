# Blender でキャラクターを作ってゲームに入れる

Claude が書いた Blender 用スクリプト（Python）を Blender で実行してモデルを作り、
`.glb` ファイルとしてゲームに入れる手順です。Blender 4.2 以降（4.5 で動作確認済み）。

## 全体の流れ

```
Claude にスクリプトを頼む → Blender で実行 → 手直し（任意）→ .glb を書き出す
  → GitHub の assets/models/ にアップロード → 自動でテスト・公開（Cloudflare）
```

## 1. スクリプトを実行する

用意してあるスクリプト:

| ファイル | 作られるもの | 書き出されるファイル |
|---|---|---|
| `tools/blender/make_player.py` | 主人公（勇者・設定資料をもとにしたもの。ゲームに入っている） | `player.glb` |
| `tools/blender/make_enemy_slime.py` | 敵のお手本（スライム） | `slime.glb` |

1. Blender を開く
2. 画面上のタブから **Scripting** を選ぶ
3. テキストエディタの **＋ 新規** を押し、スクリプトの中身をすべて貼り付ける
4. **▶（スクリプト実行）** を押す
5. `DiceBattle_Player`（または `DiceBattle_Enemy`）コレクションにモデルができ、
   `.glb` が書き出される。場所は **.blend を保存していればその隣、未保存ならホームフォルダ**
   （スクリプト先頭の `EXPORT_DIR` で変更可）

何度実行しても、前回そのスクリプトが作ったものだけを消して作り直します。
スクリプト先頭の `COLORS` を書き換えると色を変えられます。

## 2. 手直しする（任意）

Blender で自由に形や色を変えてかまいません。変えたあとは次の方法で書き出し直します。

1. `DiceBattle_…` コレクションの中身をすべて選択（コレクションを右クリック → オブジェクトを選択）
2. **ファイル → エクスポート → glTF 2.0 (.glb/.gltf)**
3. 右側の設定で **形式: glTF バイナリー (.glb)**、**含む → 選択したオブジェクト** にチェック
4. ファイル名を下の「ファイル名のルール」どおりにして書き出す

## 3. ゲームに入れる

書き出した `.glb` を GitHub のリポジトリに置くだけです（コードの変更は不要）。

- 主人公: `assets/models/player.glb`
- 敵: `assets/models/enemies/<ファイル名>.glb`

GitHub のページで `assets/models/enemies` フォルダを開き、**Add file → Upload files** で
ドラッグ＆ドロップ → **Commit changes**。数分でテストと Cloudflare への公開が自動で行われます。

### ファイル名のルール（敵）

名前は [ENEMY_LIST.md](ENEMY_LIST.md) の敵に対応します。

| ファイル名 | 差し替わる敵 |
|---|---|
| `slime.glb`（種族 ID） | その種族の色違い 3 体すべて（スライム / ベリースライム / ゴールドスライム） |
| `slime_2.glb`（ID＋色番号） | その 1 体だけ（No.4 ベリースライム） |

種族 ID の一覧: slime, mushroom, bee, king_slime, goblin, wolf, treant, ogre, scorpion, cactus,
mummy, sandworm, skeleton, ghost, zombie, lich, bat, spider, golem, cyclops, snowman, penguin,
yeti, mammoth, wisp, salamander, fire_turtle, phoenix, crab, jellyfish, merman, kraken, imp,
living_armor, gargoyle, dragon, evil_eye, mimic, reaper, demon_lord

ファイルが無い敵は、今までどおりコードで作ったモデルが使われます。

## 4. Blender で作るときの約束

| 項目 | 約束 |
|---|---|
| 向き | キャラクターの**正面を「正面ビュー（テンキー 1）」から見える側（-Y 方向）**に向ける |
| 足元 | 地面を **Z = 0** にする（空を飛ぶ敵は浮かせてよい） |
| 大きさ | 自由。ゲームが自動で決まった大きさに合わせる |
| 色違い | マテリアル名をゲームの「役割名」にすると、色違いの敵ではその色に置き換わる（下の表） |
| 動き | オブジェクト名で自動的に動く（下の表）。**原点**が回転の中心になる |

### 動く部位の名前

| オブジェクト名（先頭が一致すれば OK） | 動き |
|---|---|
| `Weapon`（例: Weapon, Weapon_Club） | 攻撃のときに振りかぶって振り下ろす（原点 = 肩や手首） |
| `Wing`（例: Wing_L, Wing_R） | 羽ばたく（原点 = 翼の付け根。左右は位置で自動判定） |
| `Tail` | しっぽを左右に振る（原点 = 付け根） |

中身の無い **Empty** を作って `Weapon` と名付け、腕や武器をその子にするのがおすすめです
（`make_player.py` がその作り方になっています）。

`make_player.py` の勇者の見た目（4 方向）: [blender/hero_preview.jpg](blender/hero_preview.jpg)
体全体の動き（ぷるぷる・ふわふわ・のけぞり・踏み込み・撃破）はゲーム側が付けます。

### 色違い用のマテリアル名（役割名）

各種族の役割名は `scripts/enemies/chapter_XX.gd` の `palettes` に書いてあります。例:

| 種族 | 役割名 |
|---|---|
| スライム / スライムキング | `body`, `body2`（キングは `crown`, `gem` も） |
| マッシュ | `cap`, `spot`, `stem`, `gill` |
| ハニービー | `body`, `stripe`, `wing` |
| ゴブリン | `skin`, `cloth`, `eye_glow` |
| ドラゴン | `scales`, `belly`, `membrane`, `horn`, `eye_glow` |

役割名にしなかったマテリアル（目・口など）は Blender で付けた色のまま使われます。

### アニメーション（任意）

Blender で「idle」という名前のアクション（アニメーション）を付けて書き出すと、待機中にループ再生されます。
付けなくても、ゲーム側の動きだけで十分動きます。

## 5. Claude への頼み方の例

- 「No.13 ゴブリンの Blender スクリプトを make_enemy_slime.py と同じ形式で作って」
- 「make_player.py の主人公を、魔法使いの見た目に変えて（とんがり帽子と杖）」
- 「このスクリーンショットの頭をもっと大きく、目を丸くして」（Blender の画面を貼り付ける）
- 「assets/models/enemies に wolf.glb を置いたので、ゲームで確認して」

## うまくいかないとき

| 症状 | 確認すること |
|---|---|
| ゲームで差し替わらない | ファイル名・フォルダ名（`assets/models/enemies/slime.glb`）、拡張子が `.glb` か |
| 後ろ向き・横向きになる | Blender で正面が -Y（正面ビューで顔が見える向き）になっているか |
| 武器が変な方向に回る | `Weapon` の原点が肩（回転の中心）にあるか。回転を適用（Ctrl+A → 回転）してから書き出す |
| 金属が真っ黒に見える | Blender のプレビューだけの場合あり。ゲーム内では空が映り込むので明るくなる |
| スクリプトが「bmesh が無い」などで止まる | Blender 4.2 以降を使う |
