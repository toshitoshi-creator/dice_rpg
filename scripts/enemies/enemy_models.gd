class_name EnemyModels
extends RefCounted
## model_type（種族 ID）から、担当するチャプタースクリプトのビルダーを呼び出す。


static func build(model_type: StringName, kit: ModelKit, root: Node3D) -> void:
	for script in EnemyDatabase.chapter_scripts():
		if script.build(model_type, kit, root):
			return
	push_warning("Unknown enemy model: %s" % model_type)
	EnemyChapter01.build(&"slime", kit, root)
