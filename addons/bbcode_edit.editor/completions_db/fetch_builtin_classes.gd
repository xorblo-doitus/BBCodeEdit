extends Node


## This has to be a scene.
## (In an EditorScript, editor specifc classes would polute the result)

const Completions = preload("res://addons/bbcode_edit.editor/completions_db/completions.gd")


func _ready() -> void:
	print("Fetching classes...")
	var file: FileAccess = FileAccess.open(Completions.PATH_BUILTIN_COMPLETIONS, FileAccess.WRITE)
	if FileAccess.get_open_error():
		push_error(
			"Failed to open "
			+ Completions.PATH_BUILTIN_COMPLETIONS
			+ ", error is:"
			+ error_string(FileAccess.get_open_error())
		)
		return
	file.store_string("\n".join(ClassDB.get_class_list()))
	print_rich("[color=web_green]Classes successfuly pasted to clipboard")
	get_tree().quit()
