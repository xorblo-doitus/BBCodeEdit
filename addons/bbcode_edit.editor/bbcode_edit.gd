@tool
extends CodeEdit


enum CompletionKind {
	IGNORE,
	FORMATTING,
	COLOR,
	COMMAND,
	CLASS_REFERENCE,
	REFERENCE_START,
	REFERENCE_END,
	REFERENCING_TAG,
	ANNOTATION,
}


const Completions = preload("res://addons/bbcode_edit.editor/completions_db/completions.gd")
const Scraper = preload("res://addons/bbcode_edit.editor/editor_interface_scraper.gd")

const BBCODE_COMPLETION_ICON = preload("res://addons/bbcode_edit.editor/bbcode_completion_icon.svg")
const COLOR_PICKER_CONTAINER_PATH = ^"_BBCodeEditColorPicker"
const COLOR_PICKER_PATH = ^"_BBCodeEditColorPicker/ColorPicker"

const MALFORMED = "MALFORMED"
const COMMAND_PREFIX_CHAR = "\u0001"
const ORDER_PREFIX = "\ufffe"
const CLASS_REFERENCE_PREFIX_CHAR = "\uffff"
const REFERENCE_START_SUFFIX_CHAR = "\uffff"
const REFERENCE_END_SUFFIX_CHAR = "\ufffe"
const ANNOTATION_SUFFIX_CHAR = "\ufff0"
const _COMMAND_COLOR_PICKER = "color_picker"

const CLASS_DOC_ENDERS: Array[String] = [
	"##",
	"signal",
	"enum",
	"const",
	"@export",
	"var",
	"@onready",
	"static",
	"func",
	"class ",
]

static var REGEX_PARENTHESES = RegEx.create_from_string(r"\(([^)]+)\)")


func _init() -> void:
	set_process_input(true)
	if has_meta(&"initialized"):
		return
	code_completion_requested.connect(add_completion_options)
	text_changed.connect(_on_text_changed)
	code_completion_prefixes += ["["] # Use assignation because append don't work
	set_meta(&"initialized", true)


func add_completion_options() -> void:
	#print("Code completion options requested")
	var line_i: int = get_caret_line()
	var line: String = get_line(line_i)
	var column_i: int = get_caret_column()
	var comment_i: int = is_in_comment(line_i, column_i)
	
	if comment_i == -1 or get_delimiter_start_key(comment_i) != "##":
		if line[column_i-1] == "[":
			#print_rich("[color=red]Emergency cancel[/color]")
			cancel_code_completion()
		#print_rich("[color=red]not in bbcode completion[/color]")
		return
	#print_rich("[color=red]in bbcode completion[/color]")
	
	var to_test: String = trim_doc_comment_start(line.left(column_i))
	var line_only: String = to_test
	
	if line_only[0] == "@" and not (
		line_only.begins_with("@tutorial: ")
		or line_only.begins_with("@deprecated: ")
		or line_only.begins_with("@experimental: ")
	):
		add_code_completion_option(
			CodeEdit.KIND_PLAIN_TEXT,
			"@deprecated" + ANNOTATION_SUFFIX_CHAR,
			"deprecated\n## ",
			get_theme_color(&"font-color"),
			Scraper.get_icon(&"StatusError"),
		)
		add_code_completion_option(
			CodeEdit.KIND_PLAIN_TEXT,
			"@deprecated: Some explaination" + ANNOTATION_SUFFIX_CHAR,
			"deprecated: ",
			get_theme_color(&"font-color"),
			Scraper.get_icon(&"StatusError"),
		)
		add_code_completion_option(
			CodeEdit.KIND_PLAIN_TEXT,
			"@experimental" + ANNOTATION_SUFFIX_CHAR,
			"experimental\n## ",
			get_theme_color(&"font-color"),
			Scraper.get_icon(&"NodeWarning"),
		)
		add_code_completion_option(
			CodeEdit.KIND_PLAIN_TEXT,
			"@experimental: Some explaination" + ANNOTATION_SUFFIX_CHAR,
			"experimental: ",
			get_theme_color(&"font-color"),
			Scraper.get_icon(&"NodeWarning"),
		)
		
		var class_comment_end_line: int = 0
		while not _is_line_class_doc_ender(get_line(class_comment_end_line)):
			class_comment_end_line += 1
		while get_line(class_comment_end_line).begins_with("##"):
			class_comment_end_line += 1
		if _is_line_class_doc_ender(get_line(class_comment_end_line)):
			class_comment_end_line = -1
		
		if line_i < class_comment_end_line:
			add_code_completion_option(
				CodeEdit.KIND_PLAIN_TEXT,
				"@tutorial: https://example.com" + ANNOTATION_SUFFIX_CHAR,
				"tutorial: https://",
				get_theme_color(&"font-color"),
				Scraper.get_icon(&"ExternalLink"),
			)
			add_code_completion_option(
				CodeEdit.KIND_PLAIN_TEXT,
				"@tutorial(Title): https://example.com" + ANNOTATION_SUFFIX_CHAR,
				"tutorial(|): https://",
				get_theme_color(&"font-color"),
				Scraper.get_icon(&"ExternalLink"),
			)
		
		update_code_completion_options(true)
		return
	
	var prev_line_i: int = line_i - 1
	var prev_line: String = get_line(prev_line_i).strip_edges(true, false)
	while prev_line.begins_with("##"):
		to_test = prev_line.trim_prefix("##").strip_edges() + " " + to_test
		prev_line_i -= 1
		prev_line = get_line(prev_line_i).strip_edges(true, false)
	
	to_test = to_test.split("]")[-1]#.split("=")[-1]
	#print_rich("to_test:[color=magenta][code] ", to_test)
	
	if "[" not in to_test:
		#print("No BRACKET")
		update_code_completion_options(true)
		return
	
	var describes_i: int = line_i
	while is_in_comment(describes_i) != -1:
		describes_i += 1
	var describes: String = get_line(describes_i)
	
	if check_parameter_completions(to_test, describes_i, describes):
		return
	
	var font_color: Color = get_theme_color(&"font_color")
	
	if line_only[0] == "[":
		add_code_completion_option(
			CodeEdit.KIND_PLAIN_TEXT,
			"Note:",
			"b]Note:[/b] ",
			font_color,
			Scraper.get_icon(&"TextMesh"),
		)
		add_code_completion_option(
			CodeEdit.KIND_PLAIN_TEXT,
			"Warning:",
			"b]Warning:[/b] ",
			font_color,
			Scraper.get_icon(&"TextMesh"),
		)
		add_code_completion_option(
			CodeEdit.KIND_PLAIN_TEXT,
			"Example:",
			"b]Example:[/b] ",
			font_color,
			Scraper.get_icon(&"TextMesh"),
		)
	
	# TODO only propose valid tags
	var completions: Array[String] = (
		Completions.TAGS_UNIVERSAL
		+ Completions.TAGS_DOC_COMMENT_FORMATTING
		# TODO MAYBE: I have to refactor everything related to tag availability.
		#+ Completions.TAGS_RICH_TEXT_LABEL
	)
	var displays: Array[String] = []
	displays.assign(completions.map(_bracket))
	
	#print("First completion is: ", completions[0])
	
	for i in completions.size():
		add_code_completion_option(
			CodeEdit.KIND_PLAIN_TEXT,
			displays[i].replace("|", ""),
			completions[i],
			font_color,
			BBCODE_COMPLETION_ICON,
		)
	
	var reference_completions: Array[String] = Completions.TAGS_DOC_COMMENT_REFERENCE
	var reference_displays: Array[String] = []
	for completion in reference_completions:
		reference_displays.append(_bracket(completion.trim_suffix("|") + "Class.name"))
	
	var reference_icon: Texture2D = Scraper.get_reference_icon()
	for i in reference_completions.size():
		add_code_completion_option(
			CodeEdit.KIND_PLAIN_TEXT,
			reference_displays[i].replace("|", ""),
			reference_completions[i],
			font_color,
			reference_icon,
		)
	
	if describes.begins_with("func "):
		add_code_completion_option(
			CodeEdit.KIND_PLAIN_TEXT,
			"[param name]",
			"param |",
			font_color,
			reference_icon,
		)
	
	var class_completions := Completions.get_class_completions()
	for i in len(class_completions.names):
		var name_: String = class_completions.names[i]
		add_code_completion_option(
			CodeEdit.KIND_CLASS,
			CLASS_REFERENCE_PREFIX_CHAR + "[" + name_ + "]",
			name_ + "||",
			font_color,
			class_completions.icons[i],
		)
	
	update_code_completion_options(true) # NEEDED so that `[` triggers popup


func _is_line_class_doc_ender(line: String) -> bool:
	for doc_ender in CLASS_DOC_ENDERS:
		if line.begins_with(doc_ender):
			return true
	return false


func _bracket(string: String) -> String:
	return "[" + string + "]"


func trim_doc_comment_start(line: String) -> String:
	return line.strip_edges(true, false).trim_prefix("##").strip_edges(true, false)


func check_parameter_completions(to_test: String, describes_i: int, describes: String) -> bool:
	to_test = to_test.split("[")[-1]
	var parts: PackedStringArray = to_test.split(" ", false)
	
	var parameters: PackedStringArray = PackedStringArray()
	var values: PackedStringArray = PackedStringArray()
	for part in parts:
		# TODO MAYBE impleement sub parameter handling ? (e.g. [font otv="wght=200,wdth=400"])
		var split: PackedStringArray = part.split("=", 1)
		parameters.append(split[0])
		values.append(split[1] if split.size() == 2 else MALFORMED)
	
	#print_rich("Parameters:[color=magenta] ", parameters)
	#print_rich("Values:[color=magenta] ", values)
	
	if parameters.is_empty():
		return false
	
	if parameters.size() == 1 and values[0] != "MALFORMED":
		var value: String = values[0]
		match parameters[0]:
			"color":
				if value.begins_with(HEX_PREFIX) and value.substr(HEX_PREFIX.length()).is_valid_html_color():
					add_hex_color(value.substr(HEX_PREFIX.length()), true)
				elif value.is_valid_html_color():
					if value.is_valid_int():
						insert_text(HEX_PREFIX, get_caret_line(), get_caret_column()-value.length())
						request_code_completion.call_deferred(true)
					add_hex_color(value)
					
				add_color_completions(value.length())
				return true
	
	match parameters[0]:
		"param":
			if not describes.begins_with("func "):
				return false
			
			if ")" not in describes:
				var next_line_i: int = describes_i + 1
				var next_line: String = get_line(next_line_i)
				while ")" not in next_line:
					describes += next_line
					next_line_i += 1
					next_line = get_line(next_line_i)
				describes += next_line
			#print_rich("Describes: [color=purple][code]", describes)
			
			for part in (
				REGEX_PARENTHESES.search(describes).get_string().trim_prefix("(").trim_suffix(")").split(",")
			):
				var param_parts := part.split(":", true, 1)
				var parameter: String = param_parts[0].strip_edges()
				
				add_code_completion_option(
					CodeEdit.KIND_PLAIN_TEXT,
					parameter + REFERENCE_END_SUFFIX_CHAR,
					parameter + "||",
					get_theme_color(&"font_color"),
					Scraper.get_icon(&"Variant")
					if param_parts.size() == 1 else
					Scraper.try_get_icon(param_parts[1].split("=", true, 1)[0].strip_edges(), &"Variant")
				)
			
			update_code_completion_options(true)
			return true
		"member":
			if parameters.size() >= 2:
				var path: PackedStringArray = parameters[1].split(".")
				if path.size() >= 2:
					if ClassDB.class_exists(path[0]):
						add_member_completion_from_class_name(path[0])
					else:
						for other_class_ in ProjectSettings.get_global_class_list():
							if other_class_["class"] == path[0]:
								add_member_completion_from_script(load(other_class_["path"]))
								break
					update_code_completion_options(true)
					return true
			add_member_completion_from_script(EditorInterface.get_script_editor().get_current_script())
			add_classes_completion()
			return true
		"method":
			if parameters.size() >= 2:
				var path: PackedStringArray = parameters[1].split(".")
				if path.size() >= 2:
					if ClassDB.class_exists(path[0]):
						add_method_completion_from_class_name(path[0])
					else:
						for other_class_ in ProjectSettings.get_global_class_list():
							if other_class_["class"] == path[0]:
								add_method_completion_from_script(load(other_class_["path"]))
								break
					update_code_completion_options(true)
					return true
			add_method_completion_from_script(EditorInterface.get_script_editor().get_current_script())
			add_classes_completion()
			return true
		"constant":
			if parameters.size() >= 2:
				var path: PackedStringArray = parameters[1].split(".")
				if path.size() >= 2:
					if ClassDB.class_exists(path[0]):
						add_constant_completion_from_class_name(path[0])
					else:
						for other_class_ in ProjectSettings.get_global_class_list():
							if other_class_["class"] == path[0]:
								add_constant_completion_from_script(load(other_class_["path"]))
								break
					update_code_completion_options(true)
					return true
			add_constant_completion_from_script(EditorInterface.get_script_editor().get_current_script())
			add_classes_completion()
			return true
		"signal":
			if parameters.size() >= 2:
				var path: PackedStringArray = parameters[1].split(".")
				if path.size() >= 2:
					if ClassDB.class_exists(path[0]):
						add_signal_completion_from_class_name(path[0])
					else:
						for other_class_ in ProjectSettings.get_global_class_list():
							if other_class_["class"] == path[0]:
								add_signal_completion_from_script(load(other_class_["path"]))
								break
					update_code_completion_options(true)
					return true
			add_signal_completion_from_script(EditorInterface.get_script_editor().get_current_script())
			add_classes_completion()
			return true
		"enum":
			if parameters.size() >= 2:
				var path: PackedStringArray = parameters[1].split(".")
				if path.size() >= 2:
					if ClassDB.class_exists(path[0]):
						add_enum_completion_from_class_name(path[0])
					else:
						for other_class_ in ProjectSettings.get_global_class_list():
							if other_class_["class"] == path[0]:
								add_enum_completion_from_script(load(other_class_["path"]))
								break
					update_code_completion_options(true)
					return true
			add_enum_completion_from_script(EditorInterface.get_script_editor().get_current_script())
			add_classes_completion()
			return true
	
	return false


func substr_clamped_start(string: String, from: int, len: int) -> String:
	if from < 0:
		if len != -1:
			len += from
			if len < 0:
				len = 0
		from = 0
	
	return string.substr(from, len)


const HEX_PREFIX = "0x"
func add_hex_color(hex: String, include_prefix: bool = false) -> void:
	print_rich("Valid color: ", hex, " [color=", hex, "]██████")
	add_code_completion_option(
		CodeEdit.KIND_PLAIN_TEXT,
		HEX_PREFIX + hex + " ",
		HEX_PREFIX + hex if include_prefix else hex,
		get_theme_color(&"font_color"),
		Scraper.get_color_icon(),
		Color.html(hex),
	)


func add_color_completions(chars_typed: int) -> void:
	var icon = Scraper.get_color_icon()
	for color in Completions.COLORS:
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
		_COMMAND_COLOR_PICKER + "," + str(chars_typed),
		get_theme_color(&"font_color"),
		EditorInterface.get_base_control().get_theme_icon("ColorPicker", "EditorIcons"),
	)
	update_code_completion_options(true)


## Add completion for classes WITH SUBSCRIPT (aka it will add a dot at the end)
func add_classes_completion() -> void:
	var class_completions := Completions.get_class_completions()
	for i in len(class_completions.names):
		var name_: String = class_completions.names[i]
		add_code_completion_option(
			CodeEdit.KIND_CLASS,
			ORDER_PREFIX + name_ + "." + REFERENCE_START_SUFFIX_CHAR,
			name_ + ".",
			get_theme_color(&"font_color"),
			class_completions.icons[i],
		)
	update_code_completion_options(true)


func add_member_completion_from_script(class_: Script) -> void:
	add_members(class_.get_script_property_list())
	# Don't show inherited things, because the reference won't work.
	#add_member_completion_from_class_name(class_.get_instance_base_type())



func add_member_completion_from_class_name(class_: StringName) -> void:
	add_members(ClassDB.class_get_property_list(class_, true))


func add_members(members: Array[Dictionary]) -> void:
	for member in members:
		if member["usage"] & (
			PROPERTY_USAGE_INTERNAL
			| PROPERTY_USAGE_CATEGORY
			| PROPERTY_USAGE_GROUP
			| PROPERTY_USAGE_SUBGROUP
		):
			continue
		
		add_code_completion_option(
			CodeEdit.KIND_MEMBER,
			member["name"] + REFERENCE_END_SUFFIX_CHAR,
			member["name"] + "||",
			get_theme_color(&"font-color"),
			get_icon_for_member(member),
		)


func get_icon_for_member(member: Dictionary, fallback: StringName = &"MemberProperty") -> Texture2D:
	if member["type"] == TYPE_OBJECT:
		return Scraper.get_class_icon(member["class_name"], fallback)
	
	return Scraper.get_builtin_type_icon(member["type"], fallback)


func add_method_completion_from_script(class_: Script) -> void:
	add_methods(class_.get_method_list())
	# Don't show inherited things, because the reference won't work.
	#add_method_completion_from_class_name(class_.get_instance_base_type())


func add_method_completion_from_class_name(class_: StringName) -> void:
	add_methods(ClassDB.class_get_method_list(class_, true))


func add_methods(methods: Array[Dictionary]) -> void:
	for method in methods:
		add_code_completion_option(
			CodeEdit.KIND_FUNCTION,
			method["name"] + REFERENCE_END_SUFFIX_CHAR,
			method["name"] + "||",
			get_theme_color(&"font-color"),
			get_icon_for_method(method),
		)


func get_icon_for_method(method: Dictionary) -> Texture2D:
	var returned: Dictionary = method["return"]
	
	if returned["type"] == TYPE_NIL:
		return Scraper.get_icon(&"MemberMethod")
	
	return get_icon_for_member(returned, &"Function")


func add_constant_completion_from_script(class_: Script) -> void:
	add_constants(class_.get_script_constant_map())
	# Don't show inherited things, because the reference won't work.
	#add_constant_completion_from_class_name(class_.get_instance_base_type())


func add_constant_completion_from_class_name(class_: StringName) -> void:
	for constant_name in ClassDB.class_get_integer_constant_list(class_, true):
		add_constants({constant_name: ClassDB.class_get_integer_constant(class_, constant_name)})


func add_constants(constants: Dictionary) -> void:
	for constant in constants:
		var value: Variant = constants[constant]
		var type: int = typeof(value)
		
		if type == TYPE_OBJECT and value is Script and value.resource_path.is_empty():
			# Inner classes don't work in class
			continue
		
		var display_text: String = constant
		if type != TYPE_COLOR:
			var repr: String = var_to_str(value)
			if repr.is_empty():
				if type == TYPE_OBJECT:
					repr = value.to_string()
				else:
					repr = str(repr)
			if repr.length() > 32:
				repr = repr.left(32) + "..."
			display_text += " (" + repr + ")"
		display_text += REFERENCE_END_SUFFIX_CHAR
		
		add_code_completion_option(
			CodeEdit.KIND_CONSTANT,
			display_text,
			constant + "||",
			get_theme_color(&"font-color"),
			Scraper.get_type_icon(value, &"MemberConstant"),
			value
		)


func add_signal_completion_from_script(class_: Script) -> void:
	add_signals(class_.get_script_signal_list())
	# Don't show inherited things, because the reference won't work.
	#add_signal_completion_from_class_name(class_.get_instance_base_type())


func add_signal_completion_from_class_name(class_: StringName) -> void:
	add_signals(ClassDB.class_get_signal_list(class_, true))


func add_signals(signals: Array[Dictionary]) -> void:
	var icon: Texture2D = Scraper.get_icon(&"MemberSignal")
	for signal_ in signals:
		add_code_completion_option(
			CodeEdit.KIND_SIGNAL,
			signal_["name"] + REFERENCE_END_SUFFIX_CHAR,
			signal_["name"] + "||",
			get_theme_color(&"font-color"),
			icon,
		)


func add_enum_completion_from_script(class_: Script) -> void:
	var map := class_.get_script_constant_map()
	var probable_enums: PackedStringArray
	
	for constant in map:
		if typeof(map[constant]) == TYPE_DICTIONARY:
			var candidate: Dictionary = map[constant]
			if candidate.values().all(_is_int):
				probable_enums.append(constant)
	
	if probable_enums:
		add_enums(probable_enums)
	
	# Don't show inherited things, because the reference won't work.
	#add_enum_completion_from_class_name(class_.get_instance_base_type())


static func _is_int(value: Variant) -> bool:
	return typeof(value) == TYPE_INT


func add_enum_completion_from_class_name(class_: StringName) -> void:
	add_enums(ClassDB.class_get_enum_list(class_, true))


func add_enums(enums: PackedStringArray) -> void:
	var icon: Texture2D = Scraper.get_icon(&"Enum")
	for enum_ in enums:
		add_code_completion_option(
			CodeEdit.KIND_ENUM,
			enum_ + REFERENCE_END_SUFFIX_CHAR,
			enum_ + "||",
			get_theme_color(&"font-color"),
			icon,
		)


func toggle_tag(tag: String) -> void:
	var prefix: String = "[" + tag + "]"
	var prefix_len: int = prefix.length()
	var suffix: String = "[/" + tag + "]"
	var suffix_len: int = suffix.length()
	
	var main_selection_from_column: int = get_selection_from_column()
	var main_selection_from_line: int = get_selection_from_line()
	var main_selection_to_column: int = get_selection_to_column()
	var main_selection_to_line: int = get_selection_to_line()
	var main_selection_end_line: String = get_line(main_selection_to_line)
	
	if (
		main_selection_from_column > prefix_len
		and get_line(main_selection_from_line).substr(
			main_selection_from_column - prefix_len,
			prefix_len
		) == prefix
		and main_selection_to_column <= main_selection_end_line.length() - suffix_len
		and main_selection_end_line.substr(
			main_selection_to_column,
			suffix_len
		) == suffix
	):
		begin_complex_operation()
		begin_multicaret_edit()
		
		for caret in get_caret_count():
			if multicaret_edit_ignore_caret(caret):
				continue
			
			var initial_text: String = get_selected_text(caret)
			var initial_start_column: int = get_selection_from_column(caret)
			var initial_end_column: int = get_selection_to_column(caret)
			
			select(
				get_selection_from_line(caret),
				initial_start_column - prefix_len,
				get_selection_to_line(caret),
				initial_end_column + suffix_len,
				caret
			)
			insert_text_at_caret(initial_text, caret)
			select(
				get_selection_from_line(caret),
				initial_start_column - prefix_len,
				get_selection_to_line(caret),
				initial_end_column - prefix_len,
				caret
			)
		
		end_multicaret_edit()
		end_complex_operation()
		return
	
	begin_complex_operation()
	begin_multicaret_edit()
	
	for caret in get_caret_count():
		if multicaret_edit_ignore_caret(caret):
			continue
		
		var initial_start_column: int = get_selection_from_column(caret)
		var initial_end_column: int = get_selection_to_column(caret)
		
		insert_text_at_caret(prefix + get_selected_text(caret) + suffix, caret)
		
		select(
			get_selection_from_line(caret),
			initial_start_column + prefix_len,
			get_selection_to_line(caret),
			initial_end_column + prefix_len,
			caret
		)
	
	end_multicaret_edit()
	end_complex_operation()


func _confirm_code_completion(replace: bool = false) -> void:
	var selected_completion: Dictionary = get_code_completion_option(get_code_completion_selected_index())
	var display_text: String = selected_completion["display_text"]
	var prefix: String = display_text[0]
	
	if prefix == COMMAND_PREFIX_CHAR:
		var parts: PackedStringArray = selected_completion["insert_text"].split(",")
		var chars_to_remove: int = int(parts[1]) if parts.size() >= 2 else 0
		if chars_to_remove:
			for caret in get_caret_count():
				var line_i: int = get_caret_line(caret)
				var line: String = get_line(line_i)
				var column_i: int = get_caret_column(caret)
				set_line(line_i, line.left(column_i - chars_to_remove) + line.substr(column_i))
				set_caret_column(column_i - chars_to_remove, false, caret)
		
		match parts[0]:
			_COMMAND_COLOR_PICKER:
				if not has_node(^"BBCODE_EDIT_COLOR_PICKER"):
					add_child(preload("res://addons/bbcode_edit.editor/color_picker.tscn").instantiate())
				var container: PopupPanel = get_node(COLOR_PICKER_CONTAINER_PATH)
				var picker: ColorPicker = get_node(COLOR_PICKER_PATH)
				
				container.position = Vector2(get_pos_at_line_column(get_caret_line(), get_caret_column())) + global_position + Vector2(0, get_line_height())
				container.add_theme_stylebox_override(&"panel", EditorInterface.get_base_control().get_theme_stylebox(&"Content", &"EditorStyles"))
				picker.color_changed.connect(_on_color_picker_color_changed)
		
		cancel_code_completion()
		return
	
	var icon: Texture2D = selected_completion["icon"]
	var suffix: String = display_text[-1]
	var kind: CompletionKind = (
		CompletionKind.FORMATTING if icon == BBCODE_COMPLETION_ICON else
		CompletionKind.COLOR if icon == Scraper.get_color_icon() else
		CompletionKind.CLASS_REFERENCE if prefix == CLASS_REFERENCE_PREFIX_CHAR else
		CompletionKind.REFERENCE_START if suffix == REFERENCE_START_SUFFIX_CHAR else
		CompletionKind.REFERENCE_END if suffix == REFERENCE_END_SUFFIX_CHAR else
		CompletionKind.ANNOTATION if suffix == ANNOTATION_SUFFIX_CHAR else
		CompletionKind.REFERENCING_TAG if icon == Scraper.get_reference_icon() else
		0
	)
	
	#print_rich("Kind is [color=red][code]", CompletionKind.find_key(kind))
	
	begin_complex_operation()
	
	# Don't use the following code, it's a dev crime.
	# Oops, I just did...
	# This code block allows to call the code that is meant to be executed
	# when the virtual method isn't implemented.
	var script: GDScript = get_script()
	set_script(null)
	super.confirm_code_completion(replace)
	set_script(script)
	
	if (
		kind == CompletionKind.FORMATTING
		or kind == CompletionKind.CLASS_REFERENCE
		or kind == CompletionKind.REFERENCING_TAG
	):
		for caret in get_caret_count():
			var line: String = get_line(get_caret_line(caret)) + " " # Add space so that column is in range
			var column: int = get_caret_column(caret)
			if not line[column] == "]":
				insert_text_at_caret("]", caret)
				# Replace caret at it's previous column
				set_caret_column(column, false, caret)
	
	if kind == CompletionKind.COLOR:
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
		
		for caret in get_caret_count():
			set_caret_column(get_caret_column(caret) + 1, false, caret) 
	elif kind:
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
	
	end_complex_operation()
	
	if kind == CompletionKind.REFERENCING_TAG:
		var prefixes := code_completion_prefixes
		code_completion_prefixes += [" "]
		request_code_completion()
		code_completion_prefixes = prefixes
	elif kind and kind != CompletionKind.ANNOTATION:
		request_code_completion()


func _gui_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	
	if has_node(COLOR_PICKER_CONTAINER_PATH):
		if event is InputEventKey or event is InputEventMouseButton:
			get_node(COLOR_PICKER_CONTAINER_PATH).free()
	
	if event.is_action(&"bbcode_edit/toggle_bold", true):
		toggle_tag("b")
	elif event.is_action(&"bbcode_edit/toggle_italic", true):
		toggle_tag("i")
	elif event.is_action(&"bbcode_edit/toggle_underline", true):
		toggle_tag("u")
	elif event.is_action(&"bbcode_edit/toggle_strike", true):
		toggle_tag("s")


func _on_text_changed() -> void:
	var line_i: int = get_caret_line()
	var column_i: int = get_caret_column()
	var line: String = get_line(get_caret_line())
	if (
		is_in_comment(line_i, column_i) == -1
		and is_in_string(line_i, column_i) == -1
		and line
		and line[column_i-1] == "["
	):
		cancel_code_completion() # Prevent completing when typing array fast


func _on_color_picker_color_changed(color: Color) -> void:
	var hex: String = color.to_html(color.a8 != 255)
	
	for caret in get_caret_count():
		var line_i: int = get_caret_line(caret)
		var line: String = get_line(line_i)
		var column_i: int = get_caret_column(caret)
		
		if line[column_i] != "]" and line[column_i] != " ":
			var to_scan: String = line.substr(column_i)
			var end: int = to_scan.find("]")
			
			if end == -1:
				end = to_scan.find(" ")
			else:
				var other: int = to_scan.find(" ")
				if other != -1 and other < end:
					end = other
			
			set_line(line_i, line.left(column_i) + to_scan.substr(end))
		
		insert_text_at_caret(hex, caret)
		set_caret_column(column_i, false, caret)
