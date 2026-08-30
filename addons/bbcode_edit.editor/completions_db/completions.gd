@tool
extends Object


const GodotVersion = preload("res://addons/bbcode_edit.editor/completions_db/godot_version.gd")
const Scraper = preload("res://addons/bbcode_edit.editor/editor_interface_scraper.gd")

const _BUILTIN_COMPLETIONS_PATH_BEGINING = "res://addons/bbcode_edit.editor/completions_db/builtin_classes_"
const DONT_ASK_TO_FETCH_SETTING_PATH = "addons/bbcode_edit/editor/dont_ask_to_fetch_builtin_classes"

const equivalent_versions: Dictionary = {
	"4.4.1": "4.4",
	"4.6.1": "4.6",
	"4.6.2": "4.6",
	"4.7.1": "4.7",
	"4.7.2": "4.7",
}


static var _BUILTIN_COMPLETIONS_PATH: String
static func get_builtin_completions_path() -> String:
	if _BUILTIN_COMPLETIONS_PATH:
		return _BUILTIN_COMPLETIONS_PATH
	
	var version_string: String = GodotVersion.get_short_string()
	if version_string in equivalent_versions:
		version_string = equivalent_versions.get(version_string)
	
	_BUILTIN_COMPLETIONS_PATH = (
		_BUILTIN_COMPLETIONS_PATH_BEGINING
		+ version_string
		+ ".txt"
	)
	
	return _BUILTIN_COMPLETIONS_PATH 


# TODO add all tags and classify them between Documentation Only, Documentation Forbidden, Universal
const TAGS_UNIVERSAL: Array[String] = [
	"b]|[/b",
	"u]|[/u",
	"i]|[/i",
	"s]|[/s",
	"code]|[/code",
	"color=|][/color",
	"lb||",
	"rb||",
	"font=|][/font",
	"img]res://|[/img",
	"img width=| height=]res://[/img",
	"url]|[/url",
	"url=https://|][/url",
	"center]|[/center",
]
const TAGS_DOC_COMMENT_REFERENCE: Array[String] = [
	"annotation |",
	"constant |",
	"enum |",
	"member |",
	"method |",
	"constructor |",
	"operator |",
	"signal |",
	"theme_item |",
]

static var TAGS_DOC_COMMENT_FORMATTING: Array[String] = [
	"codeblock]|[/codeblock",
	"br||",
	"kbd]|[/kbd",
]
## See [url=https://github.com/godotengine/godot/pull/111375]Godot#111375[/url] 
const ADMONITIONS = [
	"note]|[/note][br",
	"warning]|[/warning][br",
	"tip]|[/tip][br",
	"important]|[/important][br",
]
static var ADMONITIONS_SUPPORTED = Engine.get_version_info().hex >= 0x040800 

# TODO add all tags
const TAGS_RICH_TEXT_LABEL: Array[String] = [
	# TODO complete with all options
	"font name=| size=][/font]",
	'url={"|": }][/url',
]
const COLORS: Array[StringName] = [
	"alice_blue",
	"antique_white",
	"aqua",
	"aquamarine",
	"azure",
	"beige",
	"bisque",
	"black",
	"blanched_almond",
	"blue",
	"blue_violet",
	"brown",
	"burlywood",
	"cadet_blue",
	"chartreuse",
	"chocolate",
	"coral",
	"cornflower_blue",
	"cornsilk",
	"crimson",
	"cyan",
	"dark_blue",
	"dark_cyan",
	"dark_goldenrod",
	"dark_gray",
	"dark_green",
	"dark_khaki",
	"dark_magenta",
	"dark_olive_green",
	"dark_orange",
	"dark_orchid",
	"dark_red",
	"dark_salmon",
	"dark_sea_green",
	"dark_slate_blue",
	"dark_slate_gray",
	"dark_turquoise",
	"dark_violet",
	"deep_pink",
	"deep_sky_blue",
	"dim_gray",
	"dodger_blue",
	"firebrick",
	"floral_white",
	"forest_green",
	"fuchsia",
	"gainsboro",
	"ghost_white",
	"gold",
	"goldenrod",
	"gray",
	"green",
	"green_yellow",
	"honeydew",
	"hot_pink",
	"indian_red",
	"indigo",
	"ivory",
	"khaki",
	"lavender",
	"lavender_blush",
	"lawn_green",
	"lemon_chiffon",
	"light_blue",
	"light_coral",
	"light_cyan",
	"light_goldenrod",
	"light_gray",
	"light_green",
	"light_pink",
	"light_salmon",
	"light_sea_green",
	"light_sky_blue",
	"light_slate_gray",
	"light_steel_blue",
	"light_yellow",
	"lime",
	"lime_green",
	"linen",
	"magenta",
	"maroon",
	"medium_aquamarine",
	"medium_blue",
	"medium_orchid",
	"medium_purple",
	"medium_sea_green",
	"medium_slate_blue",
	"medium_spring_green",
	"medium_turquoise",
	"medium_violet_red",
	"midnight_blue",
	"mint_cream",
	"misty_rose",
	"moccasin",
	"navajo_white",
	"navy_blue",
	"old_lace",
	"olive",
	"olive_drab",
	"orange",
	"orange_red",
	"orchid",
	"pale_goldenrod",
	"pale_green",
	"pale_turquoise",
	"pale_violet_red",
	"papaya_whip",
	"peach_puff",
	"peru",
	"pink",
	"plum",
	"powder_blue",
	"purple",
	"rebecca_purple",
	"red",
	"rosy_brown",
	"royal_blue",
	"saddle_brown",
	"salmon",
	"sandy_brown",
	"sea_green",
	"seashell",
	"sienna",
	"silver",
	"sky_blue",
	"slate_blue",
	"slate_gray",
	"snow",
	"spring_green",
	"steel_blue",
	"tan",
	"teal",
	"thistle",
	"tomato",
	"transparent",
	"turquoise",
	"violet",
	"web_gray",
	"web_green",
	"web_maroon",
	"web_purple",
	"wheat",
	"white",
	"white_smoke",
	"yellow",
	"yellow_green",
]

static func _static_init() -> void:
	if ADMONITIONS_SUPPORTED:
		TAGS_DOC_COMMENT_FORMATTING.append_array(ADMONITIONS)

static var _BUILTIN_CLASSES: PackedStringArray = PackedStringArray()


static func get_builtin_classes() -> PackedStringArray:
	if _BUILTIN_CLASSES.is_empty():
		if FileAccess.file_exists(get_builtin_completions_path()):
			var file: FileAccess = FileAccess.open(get_builtin_completions_path(), FileAccess.READ)
			
			if FileAccess.get_open_error():
				push_error(
					"Failed to open "
					+ get_builtin_completions_path()
					+ ", error is:"
					+ error_string(FileAccess.get_open_error())
				)
			else:
				_BUILTIN_CLASSES = file.get_as_text().split("\n")
		elif !ProjectSettings.get_setting(DONT_ASK_TO_FETCH_SETTING_PATH):
			var dialog: AcceptDialog = AcceptDialog.new()
			dialog.title = "BBCodeEdit"
			dialog.dialog_text = (
				"Builtin classes are not cached for version "
				+ GodotVersion.get_short_string()
				+ " of Godot."
				+ "\n\nDo you want to fetch them? It should take less than 15 seconds."
				+ "\n\n(This will play a scene that will close automatically once the work is done)"
			)
			dialog.ok_button_text = "Fetch builtin classes"
			dialog.add_cancel_button("No, and don't ask again")
			dialog.confirmed.connect(fetch_builtin_classes)
			dialog.canceled.connect(
				ProjectSettings.set_setting.bind(
					DONT_ASK_TO_FETCH_SETTING_PATH,
					true
				)
			)
			EditorInterface.popup_dialog_centered(dialog)
	return _BUILTIN_CLASSES


static func get_type_and_class_completions() -> ClassCompletions:
	var result: ClassCompletions = get_class_completions()
	_add_type_completions(result)
	return result


static var icon_cache: Dictionary = {}
static func get_class_completions() -> ClassCompletions:
	var class_names: PackedStringArray = get_builtin_classes().duplicate()
	var icons: Array[Texture2D] = []
	for class_name_ in class_names:
		icons.append(AnyIcon.get_builtin_class_icon(class_name_))
	
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
					icons.append(icon_cache[class_name_])
					break
			if len(icons) != len(class_names):
				icon_cache[class_name_] = AnyIcon.get_builtin_class_icon(icon_class)
				icons.append(icon_cache[class_name_])
	
	return ClassCompletions.new(
		class_names,
		icons,
	)


static func fetch_builtin_classes() -> void:
	EditorInterface.play_custom_scene("res://addons/bbcode_edit.editor/completions_db/fetch_builtin_classes.tscn")
	while EditorInterface.is_playing_scene():
		await EditorInterface.get_base_control().get_tree().create_timer(0.1, true, false, true).timeout
	
	_BUILTIN_CLASSES = (get_builtin_classes() as Array[String]).filter(ClassDB.class_exists)
	var file := FileAccess.open(get_builtin_completions_path(), FileAccess.WRITE)
	if FileAccess.get_open_error():
		push_error(
			"Failed to open "
			+ get_builtin_completions_path()
			+ ", error is:"
			+ error_string(FileAccess.get_open_error())
		)
	else:
		file.store_string("\n".join(_BUILTIN_CLASSES))
		print_rich("[color=web_green]Filtered classes successfuly")


static func _add_type_completions(completions: ClassCompletions) -> void:
	var names: PackedStringArray = PackedStringArray()
	var icons: Array[Texture2D] = []
	
	for type in TYPE_MAX:
		names.append(type_string(type))
		icons.append(AnyIcon.get_type_icon(type))
	
	completions.names = names + completions.names
	completions.icons = icons + completions.icons


class ClassCompletions:
	var names: PackedStringArray
	var icons: Array[Texture2D]
	
	func _init(_names: PackedStringArray, _icons: Array[Texture2D]) -> void:
		names = _names
		icons = _icons
