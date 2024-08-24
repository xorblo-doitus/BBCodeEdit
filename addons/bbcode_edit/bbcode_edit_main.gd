@tool
extends EditorPlugin


## Type of [url]res://addons/bbcode_edit/bbcode_edit.gd[/url] ab
const BBCodeEdit: GDScript = preload("res://addons/bbcode_edit/bbcode_edit.gd")
const ADDON_NAME = "BBCode Editor"


const ACTION_SETTINGS: Array[StringName] = [
	&"input/bbcode_edit/editor/open_current_file_documentation",
]


#var current_code_edit: CodeEdit[code
## [[codeblock][/codeblock][code
#[codeblo],[codeblock][/codeblock],,,[



func _enable_plugin() -> void:
	print("Enabling ", ADDON_NAME)
	add_keybinds()
	_on_editor_startup.call_deferred()
	print("Enabled ", ADDON_NAME)


func _disable_plugin() -> void:
	print("Disabling ", ADDON_NAME)
	for editor in EditorInterface.get_script_editor().get_open_script_editors():
		editor.get_base_editor().set_script(null)
	remove_keybinds()
	for setting in ACTION_SETTINGS:
		InputMap.erase_action(setting.substr(6))
	print("Disabled ", ADDON_NAME)


## See [method check_current
func _enter_tree() -> void:
	print("ENTER TREE")
	if not EditorInterface.has_meta(&"bbcode_edit_saved_once"):
		EditorInterface.set_meta(&"bbcode_edit_saved_once", PackedStringArray())
	_on_editor_startup.call_deferred()
	#EditorInterface.get_script_editor().editor_script_changed.connect(check_current.unbind(1))
	# TODO Fix this line at editor startup (get_current_editor() returns null, so need to call_deferred+check null)
	#add_bbcode_handling(EditorInterface.get_script_editor().get_current_editor().get_base_editor())
	#InputMap.add_action(&"open_current_file_documentation")
	#print(&"open_current_file_documentation" in InputMap.get_actions())


func _exit_tree() -> void:
	pass


var started_up: bool = false
func _on_editor_startup() -> void:
	if started_up:
		return
	started_up = true
	
	print("STARTING_UP")
	# TODO check if InputMap.load_from_project_settings() is better
	for setting in ACTION_SETTINGS:
		var action_dict: Dictionary = ProjectSettings.get_setting(setting)
		var action_name: StringName = setting.substr(6)
		InputMap.add_action(action_name, action_dict["deadzone"])
		for event in action_dict["events"]:
			InputMap.action_add_event(action_name, event)
	
	EditorInterface.get_script_editor().editor_script_changed.connect(check_current.unbind(1))


func add_keybinds() -> void:
	var open_current_file_documentation := InputEventKey.new()
	open_current_file_documentation.shift_pressed = true
	open_current_file_documentation.physical_keycode = 4194332
	ProjectSettings.set_setting(
		&"input/bbcode_edit/editor/open_current_file_documentation",
		{
			"deadzone": 0.5,
			"events": [open_current_file_documentation],
		}
	)
	# NB: Initial values DON'T work, see [url]https://github.com/godotengine/godot/issues/56598[/url]
	#ProjectSettings.set_initial_value(&"input/bbcode_edit/editor/open_current_file_documentation", open_current_file_documentation.duplicate())
	
	ProjectSettings.save()
	print_rich("[color=orange]If you don't see the keybinds in the InputMap, please reload the Project.[/color]")	




func remove_keybinds() -> void:
	
	# This calls ProjectSettings.save(), so please call it last
	remove_editor_keybinds()


func remove_editor_keybinds() -> void:
	ProjectSettings.set_setting(&"input/bbcode_edit/editor/open_current_file_documentation", null)
	ProjectSettings.save()



func check_current() -> void:
	check_bbcode_pretendant(EditorInterface.get_script_editor().get_current_editor().get_base_editor())
	#var new_code_edit: Control = 
	#
	#if new_code_edit is CodeEdit and not new_code_edit.has_meta(&"BBCode_utilities"):
		#add_bbcode_handling(new_code_edit)

# [center][/center][codeblock][/codeblock]
# [code[code[[[[[[
func check_bbcode_pretendant(pretendant: Control) -> void:
	if pretendant is CodeEdit and not pretendant.has_meta(&"BBCode_utilities"):
		add_bbcode_handling(pretendant)


func add_bbcode_handling(code_edit: CodeEdit) -> void:
	print("Script was: ", code_edit.get_script())
	code_edit.set_meta(&"never_changed", true)
	code_edit.set_script(BBCodeEdit)
	print("Script is: ", code_edit.get_script())
	#code_edit.gui_input.connect(_on_code_edit_input)
	#code_edit.code_completion_requested.connect(add_completion_options.bind(code_edit))
	#print(code_edit.code_completion_prefixes)
	#code_edit.code_completion_prefixes += ["["] # Use assignation because append don't work
	#print(code_edit.code_completion_prefixes)
	print("Added BBCode utilities.")
	#code_edit.set_meta(&"BBCode_utilities", true)

# [[[[[[[[[[[[[[b][/b][codeblock][/codeblock][[
## [codeblock][/codeblock][[[[[[[[[[[code[code[codeblock][/codeblock][


#func add_completion_options(code_edit: CodeEdit) -> void:
	##print("===============================================\n", code_edit.get_code_completion_options())
	#var current_line: int = code_edit.get_caret_line()
	#var current_column: int = code_edit.get_caret_column()
	#if code_edit.is_in_comment(current_line, current_column) == -1 and code_edit.is_in_string(current_line, current_column) == -1:
		#return
	#var completions: Array[String]
	#var line: String = code_edit.get_line(current_line)
	#if line.length() > current_column and line[current_column] == "]":
		#completions = COMPLETIONS.map(func(str: String): return str.substr(0, len(str)-1))
	#else:
		#completions = COMPLETIONS.duplicate()
	#print("First completion is: ", completions[0])
	#for completion in completions:
		#code_edit.add_code_completion_option(
			#CodeEdit.KIND_PLAIN_TEXT,
			#completion,
			#completion,
			#code_edit.get_theme_color(&"font_color"),
			##null,
			##null,
			##CodeEdit.LOCATION_OTHER,
		#)
	##code_edit.update_code_completion_options(false)
	##print(code_edit.get_code_completion_options())



#func _on_code_edit_input(event: InputEvent) -> void:
	#if event.is_action("ui_text_completion_accept"):
		#print("Completed")
		#"ADDON_NAME"
		#"ADDON_NAME"
		#"ADDON_NAME"
		#"ADDON_NAME"
		#"A"


#func _process(delta: float) -> void:
	#return
	#print(EditorInterface.get_script_editor().get_current_editor().get_base_editor().text)


#func _process(delta: float) -> void:
	#print("HELLO")
	#print(InputMap.get_actions())
	##if InputMap.event_is_action(event, &"bbcode_edit/editor/open_current_file_documentation"):
		##print_rich("[color=green]OPEN[/color]")
