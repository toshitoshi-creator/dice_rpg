# 装備アイコン

装備画面で使うアイコンは 4 セット × 50 枚＝ 200 枚あります（背景は透明、128×128）。

| セット | 中身 | 一覧（元画像） | ファイル |
|---|---|---|---|
| `weapons` | いろいろな武器（剣・斧・槍・杖・弓・矢筒・盾・短剣・手裏剣など） | [art/icon_sheets/weapons.png](../art/icon_sheets/weapons.png) | `assets/icons/weapons/01.png`〜`50.png` |
| `swords` | 剣 | [art/icon_sheets/swords.png](../art/icon_sheets/swords.png) | `assets/icons/swords/01.png`〜`50.png` |
| `armors` | よろい・服 | [art/icon_sheets/armors.png](../art/icon_sheets/armors.png) | `assets/icons/armors/01.png`〜`50.png` |
| `shields` | 盾 | [art/icon_sheets/shields.png](../art/icon_sheets/shields.png) | `assets/icons/shields/01.png`〜`50.png` |

番号は一覧の左上から右へ、1 段ずつ下へ数えた順です（元画像に書いてある番号と同じ）。
`weapons` には番号が書いてないので、上の段の左から 01, 02, … と数えます。
※ `swords` の一覧の 29 番目は、元画像では「24」と書かれていますが、ファイルは `29.png` です。

## 装備にアイコンを付ける

`scripts/data/weapon_database.gd`（ぶき）や `scripts/data/equipment_database.gd`（たて・よろい）の
装備に `"icon": "セット/番号"` を書くだけです。

```gdscript
"icon": "swords/09",   # 炎の剣
```

どの装備がどのアイコンを使っているかは、それぞれの定義ファイルの `"icon"` を見てください。
サイコロのアイコン（`assets/icons/dice/<id>.png`）は画像ではなく、`scripts/data/dice_database.gd` の色と目から
`godot --headless --path . -s res://tools/make_dice_icons.gd` で自動で作ります。

## 新しいアイコン画像を追加する

同じような「暗い背景にマス目で並んだ画像」なら、自動で切り分けられます。

```
pip install pillow numpy
python3 tools/slice_icon_sheet.py art/icon_sheets/<名前>.png assets/icons/<名前> --cols 5 --rows 10 --labels
```

- `--labels` はマスの左上の番号を消します（番号が無い画像では付けない）
- 新しいセットを作ったら `EquipmentDatabase.ICON_SETS` にも追加してください（テストで全ファイルがあるか確認します）
