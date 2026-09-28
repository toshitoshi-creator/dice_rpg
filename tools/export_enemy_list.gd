extends SceneTree
## 敵図鑑の一覧（docs/ENEMY_LIST.md）を EnemyDatabase から生成する。
##   godot --headless --path . -s res://tools/export_enemy_list.gd

const OUT := "res://docs/ENEMY_LIST.md"


func _initialize() -> void:
	var lines: PackedStringArray = []
	lines.append("# 敵図鑑（全 %d 体）" % EnemyDatabase.count())
	lines.append("")
	lines.append("> このファイルは `tools/export_enemy_list.gd` で自動生成しています。直接編集しないでください。")
	lines.append("")
	lines.append("- No. が大きいほど強い（HP は必ず増え、攻撃力・防御力は下がらない）")
	lines.append("- ステータス式: `EnemyDatabase.stats_for(no)`")
	lines.append("- 各チャプター = 雑魚 3 種族 × 色違い 3 ＋ ボス 1 種族 × 色違い 3")
	lines.append("- 画像: `docs/bestiary/chapter_XX.jpg`（列 = 雑魚 A / B / C / ボス、行 = 色違い 1〜3）")
	lines.append("")
	var scripts := EnemyDatabase.chapter_scripts()
	for c in scripts.size():
		var consts: Dictionary = (scripts[c] as Script).get_script_constant_map()
		lines.append("## CHAPTER %d「%s」" % [c + 1, consts["AREA"]])
		lines.append("")
		lines.append("![chapter %d](bestiary/chapter_%02d.jpg)" % [c + 1, c + 1])
		lines.append("")
		lines.append("| No. | 名前 | 区分 | HP | 攻撃 | 防御 | 攻撃名 | 説明 |")
		lines.append("|---:|---|---|---:|---:|---:|---|---|")
		for e in EnemyDatabase.chapter_enemies(c + 1):
			lines.append("| %03d | %s | %s | %d | %d | %d | %s | %s |" % [
				e.no, e.display_name, "**ボス**" if e.is_boss else "雑魚",
				e.max_hp, e.attack, e.defense, e.attack_name, e.description])
		lines.append("")
	var f := FileAccess.open(OUT, FileAccess.WRITE)
	f.store_string("\n".join(lines) + "\n")
	f.close()
	print("wrote ", OUT)
	quit()
