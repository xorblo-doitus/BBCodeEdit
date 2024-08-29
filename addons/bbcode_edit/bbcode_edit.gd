@tool
extends CodeEdit


const BBCODE_COMPLETION_ICON = preload("res://addons/bbcode_edit/bbcode_completion_icon.svg")
const COLOR_PICKER_CONTAINER_PATH = ^"_BBCodeEditColorPicker"
const COLOR_PICKER_PATH = ^"_BBCodeEditColorPicker/ColorPicker"

const COMMAND_PREFIX_CHAR = "\u0001"
const _COMMAND_COLOR_PICKER = "color_picker"

#region Completion options
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
const TAGS_DOC_COMMENT: Array[String] = [
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
#endregion


func _init() -> void:
	set_process_input(true)
	if has_meta(&"initialized"):
		return
	print("INIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIT")
	code_completion_requested.connect(add_completion_options)
	text_changed.connect(_on_text_changed)
	code_completion_prefixes += ["["] # Use assignation because append don't work
	set_meta(&"initialized", true)


func add_completion_options() -> void:
	print("Code completion options requested")
	var line_i: int = get_caret_line()
	var line: String = get_line(line_i)
	var column_i: int = get_caret_column()
	var comment_i: int = is_in_comment(line_i, column_i)
	
	if comment_i == -1 or get_delimiter_start_key(comment_i) != "##":
		if line[column_i-1] == "[":
			print_rich("[color=red]Emergency cancel[/color]")
			cancel_code_completion()
		print_rich("[color=red]not in bbcode completion[/color]")
		return
	print_rich("[color=red]in bbcode completion[/color]")
	#print(text)
	#check_other_completions()
	## [color=alic]Inner[/color]
	
	var to_test: String
	
	to_test = trim_doc_comment_start(line.left(column_i))
	var prev_line_i: int = line_i - 1
	var prev_line: String = get_line(prev_line_i).strip_edges(true, false)
	while prev_line.begins_with("##"):
		to_test = prev_line.trim_prefix("##").strip_edges() + " " + to_test
		prev_line_i += 1
		prev_line = get_line(prev_line_i).strip_edges(true, false)
	
	to_test = to_test.split("]")[-1]#.split("=")[-1]
	print_rich("to_test:[color=magenta][code] ", to_test)
	
	if "[" not in to_test:
		print("No BRACKET")
		update_code_completion_options(true)
		return
	
	if check_other_completions(to_test):
		return
	
	# TODO only propose valid tags
	var completions: Array[String] = TAGS_UNIVERSAL + TAGS_DOC_COMMENT + TAGS_RICH_TEXT_LABEL
	var displays: Array[String] = []
	displays.assign(completions.map(bracket))
	
	print("First completion is: ", completions[0])
	
	for i in completions.size():
		add_code_completion_option(
			CodeEdit.KIND_PLAIN_TEXT,
			displays[i],
			completions[i],
			get_theme_color(&"font_color"),
			BBCODE_COMPLETION_ICON,
		)
	
	update_code_completion_options(true) # NEEDED so that `[` triggers popup


func bracket(string: String) -> String:
	return "[" + string + "]"


func trim_doc_comment_start(line: String) -> String:
	return line.strip_edges(true, false).trim_prefix("##").strip_edges(true, false)


func check_other_completions(to_test: String) -> bool:
	to_test = to_test.split("[")[-1]
	var parts: PackedStringArray = to_test.split(" ", false)
	
	var parameters: PackedStringArray = PackedStringArray()
	var values: PackedStringArray = PackedStringArray()
	for part in parts:
		# TODO MAYBE impleement sub parameter handling ? (e.g. [font otv="wght=200,wdth=400"])
		var split: PackedStringArray = part.split("=", 1)
		parameters.append(split[0])
		values.append(split[1] if split.size() == 2 else "MALFORMED")
	
	print_rich("Parameters:[color=magenta] ", parameters)
	print_rich("Values:[color=magenta] ", values)
	
	if parameters.size() == 1 and values[0] != "MALFORMED":
		var value: String = values[0]
		match parameters[0]:
			"color":
				print("COLOR")
				if value.begins_with(HEX_PREFIX) and value.substr(HEX_PREFIX.length()).is_valid_html_color():
					print("Hex")
					add_hex_color(value.substr(HEX_PREFIX.length()), true)
				elif value.is_valid_html_color():
					print("Create hex")
					if value.is_valid_int():
						insert_text(HEX_PREFIX, get_caret_line(), get_caret_column()-value.length())
						request_code_completion.call_deferred(true)
					add_hex_color(value)
					
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


const HEX_PREFIX = "0x"
func add_hex_color(hex: String, include_prefix: bool = false) -> void:
	print_rich("Valid color: ", hex, " [color=", hex, "]██████")
	add_code_completion_option(
		CodeEdit.KIND_PLAIN_TEXT,
		HEX_PREFIX + hex + " ",
		HEX_PREFIX + hex if include_prefix else hex,
		get_theme_color(&"font_color"),
		get_color_icon(),
		Color.html(hex),
	)


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
	
	add_code_completion_option(
		CodeEdit.KIND_PLAIN_TEXT,
		COMMAND_PREFIX_CHAR + "Bring color picker",
		_COMMAND_COLOR_PICKER,
		get_theme_color(&"font_color"),
		EditorInterface.get_base_control().get_theme_icon("ColorPicker", "EditorIcons"),
	)
	update_code_completion_options(true)


func _confirm_code_completion(replace: bool = false) -> void:
	var selected_completion: Dictionary = get_code_completion_option(get_code_completion_selected_index())
	if selected_completion["display_text"][0] == COMMAND_PREFIX_CHAR:
		match selected_completion["insert_text"]:
			_COMMAND_COLOR_PICKER:
				if not has_node(^"BBCODE_EDIT_COLOR_PICKER"):
					add_child(preload("res://addons/bbcode_edit/color_picker.tscn").instantiate())
				var container: PopupPanel = get_node(COLOR_PICKER_CONTAINER_PATH)
				var picker: ColorPicker = get_node(COLOR_PICKER_PATH)
				
				container.position = Vector2(get_pos_at_line_column(get_caret_line(), get_caret_column())) + global_position + Vector2(0, get_line_height())
				container.add_theme_stylebox_override(&"panel", EditorInterface.get_base_control().get_theme_stylebox(&"Content", &"EditorStyles"))
				picker.color_changed.connect(_on_color_picker_color_changed)
		
		cancel_code_completion()
		return
	
	begin_complex_operation()
	var is_bbcode: bool = selected_completion["icon"] == BBCODE_COMPLETION_ICON
	
	var remove_redondant_quote_and_bracket: bool = false
	
	if is_bbcode:
		print_rich("[color=red]BBCode is true[/color]")
		for caret in get_caret_count():
			var line: String = get_line(get_caret_line(caret)) + " " # Add space so that column is in range
			var column: int = get_caret_column(caret)
			if not line[column] == "]":
				insert_text_at_caret("]", caret)
				# Replace caret at it's previous column
				set_caret_column(column, false, caret)
	
	# Don't use the following code, it's a dev crime.
	# Oops, I just did...
	# This code block allows to call the code that is meant to be executed
	# when the virtual method isn't implemented.
	var script: GDScript = get_script()
	set_script(null)
	super.confirm_code_completion(replace)
	set_script(script)
	
	if is_bbcode:
		for caret in get_caret_count():
			var line_i: int = get_caret_line(caret)
			var line: String = get_line(line_i)
			var first_pipe: int = line.find("|")
			if first_pipe == -1: # Just in case
				continue
			var pipe_end: int = first_pipe + 1
			while pipe_end < line.length() and line[pipe_end] == "|":
				pipe_end += 1
			set_line(line_i, line.left(first_pipe) + line.substr(pipe_end))
			set_caret_column(pipe_end-1, false, caret)
	elif selected_completion["icon"] == get_color_icon():
		## [color=000][/color]
		var line_i: int = get_caret_line()
		var line: String = get_line(line_i)
		var column: int = get_caret_column()
		var color_start: int = column - selected_completion["display_text"].length() + 1
		if line.substr(color_start).begins_with(HEX_PREFIX):
			set_line(
				line_i,
				line.left(color_start) + line.substr(color_start + HEX_PREFIX.length())
			)
			set_caret_column(column - HEX_PREFIX.length())
		
		print_rich("[color=red]Color is true[/color]")
		for caret in get_caret_count():
			set_caret_column(get_caret_column(caret) + 1, false, caret) 
	
	end_complex_operation()
	
	if is_bbcode:
		request_code_completion()


func _gui_input(event: InputEvent) -> void:
	if has_node(COLOR_PICKER_CONTAINER_PATH):
		if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
			get_node(COLOR_PICKER_CONTAINER_PATH).free()
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


#func get_text_by_coordinates(from: Vector2i, to: Vector2i) -> String:
	##if from.y == to.y:
		##return get_line(from.y).substr(from.x, to.x-from.x)
	#
	#var result: String = get_line(from.y).substr(from.x)
	#for line_i in range(from.y+1, to.y):
		#result += "\n" + get_line(line_i)
	#return result + "\n" + get_line(to.y).left(to.x)


func _fetch_node(parent: Node, type: String) -> Node:
	type = "@" + type
	for child in parent.get_children():
		if child.name.begins_with(type):
			return child
	return null


func _on_text_changed() -> void:
	var line_i: int = get_caret_line()
	var column_i: int = get_caret_column()
	var line: String = get_line(get_caret_line())
	if (
		is_in_comment(line_i, column_i) == -1
		and is_in_string(line_i, column_i) == -1
		and line[column_i-1] == "["
	):
		cancel_code_completion() # Prevent completing when typing array fast


func _on_color_picker_color_changed(color: Color) -> void:
	print("Color changed")
	var hex: String = color.to_html(color.a8 != 255)
	for caret in get_caret_count():
		var line_i: int = get_caret_line(caret)
		var line: String = get_line(line_i)
		var column_i: int = get_caret_column(caret)
		## [color=][/color]
		if line[column_i] != "]" and line[column_i] != " ":
			var to_scan: String = line.substr(column_i)
			print(to_scan)
			var end: int = to_scan.find("]")
			print(end)
			if end == -1:
				end = to_scan.find(" ")
			else:
				var other: int = to_scan.find(" ")
				if other != -1 and other < end:
					end = other
			print(line.left(column_i))
			print(to_scan.substr(end))
			set_line(line_i, line.left(column_i) + to_scan.substr(end))
		insert_text_at_caret(hex, caret)
		set_caret_column(column_i)
