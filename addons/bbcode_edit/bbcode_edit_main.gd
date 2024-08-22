@tool
extends EditorPlugin

const BBCodeEdit: GDScript = preload("res://addons/bbcode_script_editor.editor/bbcode_edit.gd")
const ADDON_NAME = "BBCode Editor"



#var current_code_edit: CodeEdit[code
## [[codeblock][/codeblock][code
#[codeblo],[codeblock][/codeblock],,,[

## See [method check_current
func _enter_tree() -> void:
	print("Enabling", ADDON_NAME)
	EditorInterface.get_script_editor().editor_script_changed.connect(check_current.unbind(1))
	add_bbcode_handling(EditorInterface.get_script_editor().get_current_editor().get_base_editor())
	print("Enabled", ADDON_NAME)

func check_current() -> void:
	var new_code_edit: Control = EditorInterface.get_script_editor().get_current_editor().get_base_editor()
	
	if new_code_edit is CodeEdit and not new_code_edit.has_meta(&"BBCode_utilities"):
		add_bbcode_handling(new_code_edit)

# [center][/center][codeblock][/codeblock]
# [code[code[[[[[[

func add_bbcode_handling(code_edit: CodeEdit) -> void:
	print("Script was: ", code_edit.get_script())
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

func _exit_tree() -> void:
	print("Disabling", ADDON_NAME)
	for editor in EditorInterface.get_script_editor().get_open_script_editors():
		editor.get_base_editor().set_script(null)
	print("Disabled", ADDON_NAME)
