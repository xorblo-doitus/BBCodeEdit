extends Object


const Scraper = preload("res://addons/bbcode_edit.editor/editor_interface_scraper.gd")


const PATH_BUILTIN_COMPLETIONS = "res://addons/bbcode_edit.editor/completions_db/builtin_classes.txt"


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
const TAGS_DOC_COMMENT_FORMATTING: Array[String] = [
	"codeblock]|[/codeblock",
	"br||",
	"kbd]|[/kbd",
]
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
		icons.append(Scraper.get_builtin_class_icon(class_name_))
	
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
				icon_cache[class_name_] = Scraper.get_builtin_class_icon(icon_class)
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
