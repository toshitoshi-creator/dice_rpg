class_name EnemyDatabase
extends RefCounted
## 敵図鑑（全 120 体）。
##
## 構成: 10 チャプター × 12 体
##   各チャプター = 雑魚 3 種族 × 色違い 3 = 9 体  ＋  ボス 1 種族 × 色違い 3 = 3 体
##   → 雑魚 30 種族 × 3 = 90 体、ボス 10 種族 × 3 = 30 体
##
## 図鑑番号（No.）の並び（チャプター c の先頭を B = (c-1)*12 とする）:
##   B+1〜B+3   雑魚 A/B/C の 1 色目
##   B+4〜B+6   雑魚 A/B/C の 2 色目
##   B+7〜B+9   雑魚 A/B/C の 3 色目
##   B+10〜B+12 ボスの 1〜3 色目
##
## ステータスは No. だけから計算する（stats_for）。No. が大きいほど HP・攻撃力が高い。
## 種族の見た目・名前・色は scripts/enemies/chapter_XX.gd に書く。

const CHAPTER_COUNT := 10
const PER_CHAPTER := 12
const TOTAL := CHAPTER_COUNT * PER_CHAPTER

static var _all: Array[EnemyData] = []
static var _by_id: Dictionary = {}


## チャプター定義スクリプト（順番 = チャプター番号）
static func chapter_scripts() -> Array:
	return [
		EnemyChapter01, EnemyChapter02, EnemyChapter03, EnemyChapter04, EnemyChapter05,
		EnemyChapter06, EnemyChapter07, EnemyChapter08, EnemyChapter09, EnemyChapter10,
	]


## No. → ステータス。ここを変えれば全敵のバランスが変わる。
static func stats_for(no: int) -> Dictionary:
	var n := float(no)
	return {
		"max_hp": roundi(35.0 + 6.0 * n + 0.4 * n * n),
		"attack": roundi(4.0 + 0.6 * n + 0.012 * n * n),
		"defense": no / 10,
	}


static func all() -> Array[EnemyData]:
	if _all.is_empty():
		_build()
	return _all


static func count() -> int:
	return all().size()


## 図鑑番号から取得（1〜120）。
static func get_enemy(no: int) -> EnemyData:
	var list := all()
	return list[clampi(no, 1, list.size()) - 1]


## ID から取得（例: &"slime_1"）。無ければ null。
static func find(id: StringName) -> EnemyData:
	all()
	return _by_id.get(id, null)


static func has_enemy(id: StringName) -> bool:
	return find(id) != null


## チャプター c（1〜）の敵一覧。
static func chapter_enemies(chapter: int) -> Array[EnemyData]:
	var result: Array[EnemyData] = []
	for e in all():
		if e.chapter == chapter:
			result.append(e)
	return result


static func _build() -> void:
	_all.clear()
	_by_id.clear()
	var scripts := chapter_scripts()
	for c in scripts.size():
		var consts: Dictionary = (scripts[c] as Script).get_script_constant_map()
		var mobs: Array = consts["MOBS"]
		var boss: Dictionary = consts["BOSS"]
		var base := c * PER_CHAPTER
		for v in 3:
			for s in mobs.size():
				_all.append(_make(base + v * mobs.size() + s + 1, c + 1, mobs[s], v, false))
		for v in 3:
			_all.append(_make(base + 3 * mobs.size() + v + 1, c + 1, boss, v, true))
	_all.sort_custom(func(a: EnemyData, b: EnemyData) -> bool: return a.no < b.no)
	for e in _all:
		_by_id[e.id] = e


static func _make(no: int, chapter: int, species: Dictionary, variant: int, is_boss: bool) -> EnemyData:
	var d := EnemyData.new()
	d.no = no
	d.species_id = species["id"]
	d.variant = variant
	d.id = StringName("%s_%d" % [species["id"], variant + 1])
	d.chapter = chapter
	d.is_boss = is_boss
	d.display_name = species["names"][variant]
	d.name_en = species["names_en"][variant]
	d.description = species.get("desc", "")
	d.attack_name = species.get("attack", "こうげき")
	d.model_type = species.get("model", species["id"])
	d.palette = species["palettes"][variant]
	d.target_height = species.get("height", 3.2 if is_boss else 1.6)
	d.max_width = species.get("width", 4.2 if is_boss else 2.6)
	d.idle_style = species.get("idle", &"sway")
	var stats := stats_for(no)
	d.max_hp = stats["max_hp"]
	d.attack = stats["attack"]
	d.defense = stats["defense"]
	return d
