@tool
extends EditorPlugin


## Type of [url]res://addons/bbcode_edit/bbcode_edit.gd[/url]
const BBCodeEdit: GDScript = preload("res://addons/bbcode_edit/bbcode_edit.gd")


const ADDON_NAME = "BBCode Editor"
const ACTION_SETTINGS: Array[StringName] = [
	&"input/bbcode_edit/editor/open_current_file_documentation",
]


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


func _enter_tree() -> void:
	if not EditorInterface.has_meta(&"bbcode_edit_saved_once"):
		EditorInterface.set_meta(&"bbcode_edit_saved_once", PackedStringArray())
	_on_editor_startup.call_deferred()


var started_up: bool = false
func _on_editor_startup() -> void:
	if started_up:
		return
	started_up = true
	
	# TODO check if InputMap.load_from_project_settings() is better
	for setting in ACTION_SETTINGS:
		var action_dict: Dictionary = ProjectSettings.get_setting(setting)
		var action_name: StringName = setting.substr(6)
		InputMap.add_action(action_name, action_dict["deadzone"])
		for event in action_dict["events"]:
			InputMap.action_add_event(action_name, event)
	
	EditorInterface.get_script_editor().editor_script_changed.connect(check_current.unbind(1))
	check_current.call_deferred()


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
	# ... Possible other keybinds here
	
	# This calls ProjectSettings.save(), so please call it last
	remove_editor_keybinds()


func remove_editor_keybinds() -> void:
	ProjectSettings.set_setting(&"input/bbcode_edit/editor/open_current_file_documentation", null)
	ProjectSettings.save()


func check_current() -> void:
	var current_editor := EditorInterface.get_script_editor().get_current_editor()
	if current_editor == null:
		return
	check_bbcode_pretendant(current_editor.get_base_editor())


func check_bbcode_pretendant(pretendant: Control) -> void:
	if pretendant is CodeEdit and not pretendant.has_meta(&"BBCode_utilities"):
		add_bbcode_handling(pretendant)


func add_bbcode_handling(code_edit: CodeEdit) -> void:
	# TODO MAYBE implement automatic script inheritence if script is already overriden by another addon 
	code_edit.set_meta(&"never_changed", true)
	code_edit.set_script(BBCodeEdit)
