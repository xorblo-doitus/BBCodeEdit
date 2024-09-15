@tool
extends EditorPlugin


const BBCodeEdit: GDScript = preload("res://addons/bbcode_edit.editor/bbcode_edit.gd")
const Scraper = preload("res://addons/bbcode_edit.editor/editor_interface_scraper.gd")


const ADDON_NAME = "BBCode Editor"
const ACTION_SETTINGS: Array[StringName] = [
	&"input/bbcode_edit/editor/open_current_file_documentation",
	&"input/bbcode_edit/toggle_bold",
	&"input/bbcode_edit/toggle_italic",
	&"input/bbcode_edit/toggle_underline",
	&"input/bbcode_edit/toggle_strike",
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
	var toggle_bold := InputEventKey.new()
	toggle_bold.alt_pressed = true
	toggle_bold.keycode = 66
	ProjectSettings.set_setting(
		&"input/bbcode_edit/toggle_bold",
		{
			"deadzone": 0.5,
			"events": [toggle_bold],
		}
	)
	
	var toggle_italic := InputEventKey.new()
	toggle_italic.alt_pressed = true
	toggle_italic.keycode = 73
	ProjectSettings.set_setting(
		&"input/bbcode_edit/toggle_italic",
		{
			"deadzone": 0.5,
			"events": [toggle_italic],
		}
	)
	
	var toggle_underline := InputEventKey.new()
	toggle_underline.alt_pressed = true
	toggle_underline.keycode = 85
	ProjectSettings.set_setting(
		&"input/bbcode_edit/toggle_underline",
		{
			"deadzone": 0.5,
			"events": [toggle_underline],
		}
	)
	
	var toggle_strike := InputEventKey.new()
	toggle_strike.alt_pressed = true
	toggle_strike.keycode = _get_striketrough_keycode()
	ProjectSettings.set_setting(
		&"input/bbcode_edit/toggle_strike",
		{
			"deadzone": 0.5,
			"events": [toggle_strike],
		}
	)
	
	if Engine.is_editor_hint():
		add_editor_keybinds()
	
	ProjectSettings.save()
	print_rich("[color=orange]If you don't see the keybinds in the InputMap, please reload the Project.[/color]")	


func _get_striketrough_keycode() -> int:
	var editor_shortcuts: Variant = EditorInterface.get_editor_settings().get(&"shortcuts")
	
	if editor_shortcuts == null:
		return KEY_C
	
	for shortcut: Dictionary in editor_shortcuts:
		if shortcut["name"] == "bottom_panels/toggle_shader_editor_bottom_panel":
			var input_events: Array = shortcut.get("shortcuts")
			for input_event: InputEvent in input_events:
				if input_event.keycode == KEY_S:
					return KEY_C
			return KEY_S
	
	return KEY_C


func add_editor_keybinds() -> void:
	var open_current_file_documentation := InputEventKey.new()
	open_current_file_documentation.shift_pressed = true
	open_current_file_documentation.keycode = 4194332
	ProjectSettings.set_setting(
		&"input/bbcode_edit/editor/open_current_file_documentation",
		{
			"deadzone": 0.5,
			"events": [open_current_file_documentation],
		}
	)
	# NB: Initial values DON'T work, see [url]https://github.com/godotengine/godot/issues/56598[/url]
	#ProjectSettings.set_initial_value(&"input/bbcode_edit/editor/open_current_file_documentation", open_current_file_documentation.duplicate())
	


func remove_keybinds() -> void:
	ProjectSettings.set_setting(&"input/bbcode_edit/toggle_bold", null)
	ProjectSettings.set_setting(&"input/bbcode_edit/toggle_italic", null)
	ProjectSettings.set_setting(&"input/bbcode_edit/toggle_underline", null)
	ProjectSettings.set_setting(&"input/bbcode_edit/toggle_strike", null)
	
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


## [b]WARING:[/b] not fully implemented for non-current script
func open_doc(script: Script, code_edit: CodeEdit = null) -> void:
	var class_name_: String = script.get_global_name()
	
	if class_name_ == "":
		class_name_ = '"' + script.resource_path.trim_prefix("res://") + '"'
		var bbcode_edit_saved_once: PackedStringArray = EditorInterface.get_meta(&"bbcode_edit_saved_once", PackedStringArray())
		if code_edit and class_name_ not in bbcode_edit_saved_once:
			bbcode_edit_saved_once.append(class_name_)
			print_rich("[color=orange]The script never changed since startup: brute-forcing documentation generation. (See [url=https://github.com/godotengine/godot/pull/95821]godot#95821[/url])[/color]")
			code_edit.text = code_edit.text
			EditorInterface.save_all_scenes()
		elif Scraper.is_current_script_unsaved():
			# TODO ↑ Fix this for non-current script
			print_rich("[color=orange]Saving to make godot generate documentation.[/color]")
			EditorInterface.save_all_scenes()
	
	elif Scraper.is_current_script_unsaved():
		print_rich("[color=orange]Saving to make godot generate documentation.[/color]")
		EditorInterface.save_all_scenes()
	
	EditorInterface.get_script_editor().get_current_editor().go_to_help.emit.call_deferred("class_name:"+class_name_)



func _unhandled_input(event: InputEvent) -> void:
	if InputMap.event_is_action(event, "bbcode_edit/editor/open_current_file_documentation", true):
		# TODO find a workaround for the appearance delay of (*) to check unsaved status.
		var current_editor := EditorInterface.get_script_editor().get_current_editor()
		if current_editor == null:
			return
		
		var code_edit := current_editor.get_base_editor()
		if code_edit is CodeEdit:
			open_doc(EditorInterface.get_script_editor().get_current_script(), code_edit)
