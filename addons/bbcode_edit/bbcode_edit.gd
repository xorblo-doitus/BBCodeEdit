@tool
extends CodeEdit


const BBCODE_COMPLETION_ICON = preload("res://addons/bbcode_script_editor.editor/bbcode_completion_icon.svg")

const EQUAL_UNICODE: int = 61

const LONGEST_COMPLETION: int = len("codeblock][/codeblock")
# TODO add all tags and sort them between Documentation Only, Documentation Forbidden, Universal
const COMPLETIONS: Array[String] = [
	"br",
	"b][/b",
	"u][/u",
	"i][/i",
	"s][/s",
	"codeblock][/codeblock",
	"code][/code",
	"color=][/color",
	"lb",
	"rb",
	"url][/url",
	"url=https://][/url",
	"center][/center",
	"kbd][/kbd",
]

const LONGEST_COLOR: int = len("medium_spring_green")
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


func _init() -> void:
	if has_meta(&"initialized"):
		return
	print("INIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIT")
	code_completion_requested.connect(add_completion_options)
	code_completion_prefixes += ["["] # Use assignation because append don't work
	set_meta(&"initialized", true)


func add_completion_options() -> void:
	print("Code completion options requested")
	var line_i: int = get_caret_line()
	var line: String = get_line(line_i)
	# [color=medium_spring_gree][/color][co[col
	#print(get_code_completion_options())
	#for completion in get_code_completion_options():
		#add_code_completion_option(
			#completion["type"],
			#completion["display_text"],
			#completion["insert_text"],
			#completion["text_color"],
			#completion["icon"],
			#completion["value"],
			#completion["location"],
		#)
	#print(color_completion)
	#if color_completion:
		#var to_test: String = line.substr(color_completion-1, LONGEST_COLOR).split("]")[0]
		#print(to_test)
		#if to_test.find("=") != -1 and get_caret_column() < color_completion + to_test.length() - 1:
			#add_color_completions()
			## [color=a][/color]
		#else:
			#color_completion = 0
	var column_i: int = get_caret_column()
	if is_in_comment(line_i, column_i) == -1 and is_in_string(line_i, column_i) == -1:
		return
	
	check_other_completions()
	# aze[coo[codeblock][color=al][/color][/codeblock] "ahb".get_slice("=", -1)
	#if line[column_i-1] != "[":
		#return
	# ziehjazen
	var to_test: String = substr_clamped_start(
		line,
		column_i - LONGEST_COMPLETION,
		LONGEST_COMPLETION
	)
			#LONGEST_COMPLETION)
	#if column_i - LONGEST_COMPLETION >= 0:
		#to_test = to_test.substr(
			#column_i - LONGEST_COMPLETION,
			#LONGEST_COMPLETION
		#)
	#else:
		#to_test = to_test.substr(
			#0,
			#column_i
		#)
	print("SPlit is : ", to_test)
	to_test = to_test.split("]")[-1].split("=")[-1]
	#print(LONGEST_COMPLETION)
	#print(line.substr(
		#max(0, column_i - LONGEST_COMPLETION),
		#LONGEST_COMPLETION
	#).get_slice("]", -1))
	print(to_test)
	
	if "[" not in to_test:
		print("No BRACKET")
		update_code_completion_options(true)
		return
	
	var completions: Array[String] = COMPLETIONS
	#var line: String = get_line(line_i)
	#if line.length() > column_i and line[column_i] == "]":
		#completions = COMPLETIONS.map(func(str: String): return str.substr(0, len(str)-1))
	#else:
		#completions = COMPLETIONS.duplicate()
	#codeblock][/codeblock]
	print("First completion is: ", completions[0])
	for completion in completions:
		add_code_completion_option(
			CodeEdit.KIND_PLAIN_TEXT,
			"[" + completion + "]",
			completion,
			get_theme_color(&"font_color"),
			BBCODE_COMPLETION_ICON,
			#null,
			#CodeEdit.LOCATION_OTHER,
		)
	# [c
	update_code_completion_options(true) # NEEDED so that `[` triggers popup
	#print(get_code_completion_options())codeblock][/codeblockcode[[codeblock][/codeblock][codeblock][/codeblock
	#[cod[codeblock][/codeblock[[color=][/color[code[code

# [color=a][/color]

func check_other_completions() -> bool:
	var line: String = get_line(get_caret_line())
	var column: int = get_caret_column()
	var to_check
	
	var to_test: String = substr_clamped_start(
		line,
		column - LONGEST_COLOR,
		LONGEST_COLOR
	)
	#line.substr(
		#max(0, column - LONGEST_COLOR),
		#LONGEST_COLOR
	#)
	print("Color substr is: ", to_test)
	to_test = to_test.split("[")[-1].get_slice("]", 0)
	
	print("Color final to_test is: ", to_test)
	
	#if column > color_completion + to_test.length():
		#print("Outside test window.")
		#return
	
	#if to_test.find("=") != -1 and column < color_completion + to_test.length() - 1:
		#add_color_completions()
		# [color=a][/color]
	#else:
		#color_completion = 0
	
	
	var parameter: String = to_test.get_slicec(EQUAL_UNICODE, 0)
	
	match parameter:
		"":
			return false
		"color":
			add_color_completions()
			#color_completion = get_caret_column()
			return true
	
	return false


func substr_clamped_start(str: String, from: int, len: int) -> String:
	if from < 0:
		if len != -1:
			len += from
			if len < 0:
				len = 0
		from = 0
	
	return str.substr(from, len)
	
	#if column_i - LONGEST_COMPLETION >= 0:
		#to_test = to_test.substr(
			#column_i - LONGEST_COMPLETION,
			#LONGEST_COMPLETION
		#)
	#else:
		#to_test = to_test.substr(
			#0,
			#column_i
		#)
	#print("SPlit is : ", to_test)


var color_completion: int = 0:
	set(new):
		color_completion = new
		print("COLOERJEZRIJZER? is ", new)
func add_color_completions() -> void:
	var icon = EditorInterface.get_base_control().get_theme_icon("Color", "EditorIcons")
	for color in COLORS:
		add_code_completion_option(
			CodeEdit.KIND_PLAIN_TEXT,
			color,
			color,
			get_theme_color(&"font_color"),
			icon,
			Color.from_string(color, Color.RED),
			#CodeEdit.LOCATION_OTHER,
		)# [color=]ali[/color]


func _confirm_code_completion(replace: bool = false) -> void:
	begin_complex_operation()
	
	var selected_completion: Dictionary = get_code_completion_option(get_code_completion_selected_index())
	var is_bbcode: bool = selected_completion["icon"] == BBCODE_COMPLETION_ICON
	
	if is_bbcode:
		for caret in get_caret_count():
			var line: String = get_line(get_caret_line(caret))
			var column: int = get_caret_column(caret)
			if not(line.length() > column and line[column] == "]"):
				insert_text_at_caret("]", caret)
				set_caret_column(get_caret_column(caret)-1, false, caret)
	#if get_car
	
	
	# Disclaimer: don't use the following code, it's a dev crime.
	# Oops, I just did...
	# This code block allows to call the code that is meant to be executed
	# when the virtual method isn't implemented.
	var script: GDScript = get_script()
	print("====")
	set_script(null)
	super.confirm_code_completion(replace)
	set_script(script)
	
	var inserted_text: String = selected_completion["insert_text"]
	var first_bracket: int = inserted_text.find("]")
	var first_equal: int = inserted_text.find("=")
	var column_backward: int = 9999
	
	if first_bracket != -1:
		column_backward = first_bracket
	
	if first_equal != -1 and first_equal < column_backward:
		column_backward = first_equal
	
	if column_backward != 9999:
		column_backward = inserted_text.length() - column_backward - 1
		for caret in get_caret_count():
			set_caret_column(get_caret_column(caret) - column_backward, false, caret)
	
	end_complex_operation()
	
	if check_other_completions():
		update_code_completion_options(true)
	#if first_equal:
		#match inserted_text.split("=", true, 1)[0].trim_prefix("["):
			#"color":
				#add_color_completions()
				#color_completion = get_caret_column()
			#_:
				#color_completion = 0
	#a  color=][/color][co]azeazecode[codeblock][/codeblock]
	#color=][/color][co]code[codeblock][/codeblock]colo[c[co[co
	# co[color[color[c[colo[col
	
