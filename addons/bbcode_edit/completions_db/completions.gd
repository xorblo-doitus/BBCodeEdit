extends Object


const Scraper = preload("res://addons/bbcode_edit/editor_interface_scraper.gd")


const PATH_BUILTIN_COMPLETIONS = "res://addons/bbcode_edit/completions_db/builtin_classes.txt"


static var _BUILTIN_CLASSES = PackedStringArray()


static func get_builtin_classes() -> PackedStringArray:
	if not _BUILTIN_CLASSES:
		var file: FileAccess = FileAccess.open(PATH_BUILTIN_COMPLETIONS, FileAccess.READ)
		if FileAccess.get_open_error():
			push_error(
				"Failed to open "
				+ PATH_BUILTIN_COMPLETIONS
				+ ", error is:"
				+ error_string(FileAccess.get_open_error())
			)
		_BUILTIN_CLASSES = file.get_as_text().split("\n")
	return _BUILTIN_CLASSES


static var icon_cache: Dictionary = {}
static func get_class_completions() -> ClassCompletions:
	var class_names: PackedStringArray = get_builtin_classes().duplicate()
	var icons: Array[Texture2D] = []
	for class_name_ in class_names:
		icons.append(Scraper.get_class_icon(class_name_))
	
	var classes: Array[Dictionary] = ProjectSettings.get_global_class_list()
	var class_to_icon: Dictionary = {}
	var class_to_base: Dictionary = {}
	
	for class_ in classes:
		var class_name_: String = class_["class"]
		class_names.append(class_name_)
		
		var icon_path: String = class_.get("icon", "")
		if icon_path:
			icons.append(load(icon_path))
		elif class_name_ in icon_cache:
			icons.append(icon_cache[class_name_])
		else:
			if class_to_base.is_empty():
				for class__ in classes:
					if class__["icon"]:
						class_to_icon[class__["class"]] = class__["icon"]
					class_to_base[class__["class"]] = class__["base"]
			var icon_class: String = class_name_
			while icon_class in class_to_base:
				icon_class = class_to_base[icon_class]
				if icon_class in class_to_icon:
					icon_cache[class_name_] = load(class_to_icon[icon_class])
					print(icon_cache)
					icons.append(icon_cache[class_name_])
					break
			if len(icons) != len(class_names):
				icon_cache[class_name_] = Scraper.get_class_icon(icon_class)
				icons.append(icon_cache[class_name_])
	
	return ClassCompletions.new(
		class_names,
		icons,
	)


class ClassCompletions:
	var names: PackedStringArray
	var icons: Array[Texture2D]
	
	func _init(_names: PackedStringArray, _icons: Array[Texture2D]) -> void:
		names = _names
		icons = _icons
