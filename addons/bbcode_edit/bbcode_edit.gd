@tool
extends CodeEdit


const BBCODE_COMPLETION_ICON = preload("res://addons/bbcode_edit/bbcode_completion_icon.svg")

const EQUAL_UNICODE: int = 61

const LONGEST_COMPLETION: int = len("codeblock][/codeblock")
# TODO add all tags and classify them between Documentation Only, Documentation Forbidden, Universal
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
	set_process_input(true)
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
	var column_i: int = get_caret_column()
	
	if is_in_comment(line_i, column_i) == -1 and is_in_string(line_i, column_i) == -1:
		return
	
	check_other_completions()
	
	var to_test: String = substr_clamped_start(
		line,
		column_i - LONGEST_COMPLETION,
		LONGEST_COMPLETION
	)
	print("Split is : ", to_test)
	to_test = to_test.split("]")[-1].split("=")[-1]
	print(to_test)
	
	if "[" not in to_test:
		print("No BRACKET")
		update_code_completion_options(true)
		return
	
	var completions: Array[String] = COMPLETIONS
	print("First completion is: ", completions[0])
	for completion in completions:
		add_code_completion_option(
			CodeEdit.KIND_PLAIN_TEXT,
			"[" + completion + "]",
			completion,
			get_theme_color(&"font_color"),
			BBCODE_COMPLETION_ICON,
		)
	
	update_code_completion_options(true) # NEEDED so that `[` triggers popup

func check_other_completions() -> bool:
	var line: String = get_line(get_caret_line())
	var column: int = get_caret_column()
	var to_check
	
	var to_test: String = substr_clamped_start(
		line,
		column - LONGEST_COLOR,
		LONGEST_COLOR
	)
	
	print("Color substr is: ", to_test)
	to_test = to_test.split("[")[-1].get_slice("]", 0)
	print("Color final to_test is: ", to_test)
	
	var parameter: String = to_test.get_slicec(EQUAL_UNICODE, 0)
	
	match parameter:
		"":
			return false
		"color":
			add_color_completions()
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


func get_color_icon() -> Texture2D:
	return EditorInterface.get_base_control().get_theme_icon("Color", "EditorIcons")


func add_color_completions() -> void:
	var icon = get_color_icon()
	for color in COLORS:
		add_code_completion_option(
			CodeEdit.KIND_PLAIN_TEXT,
			color,
			color,
			get_theme_color(&"font_color"),
			icon,
			Color.from_string(color, Color.RED),
		)


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
	
	# Don't use the following code, it's a dev crime.
	# Oops, I just did...
	# This code block allows to call the code that is meant to be executed
	# when the virtual method isn't implemented.
	var script: GDScript = get_script()
	set_script(null)
	super.confirm_code_completion(replace)
	set_script(script)
	
	if is_bbcode:
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
	elif selected_completion["icon"] == get_color_icon():
		for caret in get_caret_count():
			set_caret_column(get_caret_column(caret) + 1, false, caret) 
	
	end_complex_operation()
	
	if check_other_completions():
		update_code_completion_options(true)
		


#[color=alice_blue][/color][code][/code]aa
func _gui_input(event: InputEvent) -> void:
	pass
	#print("HELLO")
	#print(InputMap.get_actions())
	#print(ProjectSettings.get_setting(&"input/bbcode_edit/editor/open_current_file_documentation"))
	if InputMap.event_is_action(event, "bbcode_edit/editor/open_current_file_documentation", true):
		# TODO find a workaround for the appearance delay of (*) to check unsaved status.
		print(event.is_pressed())
		print_rich("[color=green]OPEN[/color]")
		var current_script: Script = EditorInterface.get_script_editor().get_current_script()
		
		var class_name_: String = current_script.get_global_name()
		if class_name_ == "":
			print_rich("[color=orange]Unamed[/color]")
			class_name_ = '"' + current_script.resource_path.trim_prefix("res://") + '"'
			var bbcode_edit_saved_once: PackedStringArray = EditorInterface.get_meta(&"bbcode_edit_saved_once", PackedStringArray())
			if not class_name_ in bbcode_edit_saved_once:
				bbcode_edit_saved_once.append(class_name_)
				print_rich("[color=orange]Never changed[/color]")
				text = text
				#text += "\n"
				#text = text.trim_suffix("\n")
				EditorInterface.save_all_scenes()
			elif is_unsaved():
				print_rich("[color=orange]Is unsaved[/color]")
				EditorInterface.save_all_scenes()
			#text
			#text = text
			#print(get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_tree_string_pretty())
			#get_parent().get_parent().get_parent().get_parent().get_parent().modulate = Color.WHITE
			#$"../../../../../../@VSplitContainer@9820/@VBoxContainer@9821/@ItemList@9824".modulate = Color.WHEAT
			#print(get_path())
			#print("unsaved is: ", is_unsaved())
			#print($"../../../../_addons_bbcode_edit_bbcode_edit_gd_".get_method_list())
			#print($"../../../../_addons_bbcode_edit_bbcode_edit_gd_".get_property_list())
			#text += "\n"
			#text = text.trim_suffix("\n")
			#EditorInterface.get_script_editor().get_current_editor().request_save_history.emit()
			#Input.action_press("save")
			#var save := InputEventKey.new()
			#save.keycode = 83
			##save.ctrl_pressed = true
			#save.command_or_control_autoremap = true
			#Input.parse_input_event(save)
			#EditorInterface.save_all_scenes()
			#text_changed.emit()
		elif is_unsaved():
			print_rich("[color=orange]Is unsaved[/color]")
			EditorInterface.save_all_scenes()
		print(class_name_)
		
		EditorInterface.get_script_editor().get_current_editor().go_to_help.emit.call_deferred("class_name:"+class_name_)
		#EditorInterface.get_script_editor().get_current_editor().go_to_help.emit("class_name:\"addons/bbcode_edit/bbcode_edit.gd\"")


## Scrap the Editor tree to find if it's unsaved.
func is_unsaved() -> bool:
	# Reference path: $"../../../../../../@VSplitContainer@9820/@VBoxContainer@9821/@ItemList@9824"
	var pointer: Node = $"../../../../../.."
	
	if pointer == null:
		print("FAILURE")
		return false
	
	for node_type: String in ["VSplitContainer", "VBoxContainer", "ItemList"]:
		pointer = _fetch_node(pointer, node_type)
		if pointer == null:
			print("FAILURE")
			return false
	
	print("SUCCED")
	var item_list: ItemList = pointer
	return item_list.get_item_text(item_list.get_selected_items()[0]).ends_with("(*)")


func _fetch_node(parent: Node, type: String) -> Node:
	type = "@" + type
	for child in parent.get_children():
		if child.name.begins_with(type):
			return child
	return null
