@tool
extends Node

const TagToggler = preload("res://addons/bbedit/tag_toggler/tag_toggler.gd")

const ACTION_TOGGLE_BOLD = &"bbcode_edit/toggle_bold"
const ACTION_TOGGLE_ITALIC = &"bbcode_edit/toggle_italic"
const ACTION_TOGGLE_UNDERLINE = &"bbcode_edit/toggle_underline"
const ACTION_TOGGLE_STRIKE = &"bbcode_edit/toggle_strike"

const TOGGLING_ACTIONS = {
	ACTION_TOGGLE_BOLD: "b",
	ACTION_TOGGLE_ITALIC: "i",
	ACTION_TOGGLE_UNDERLINE: "u",
	ACTION_TOGGLE_STRIKE: "s",
}

#var focused_editor: TextEdit = null


func _ready() -> void:
	print("ready")
	connect_to_window(get_window())
	connect_to_window(await get_current_focused_window())


func disconnect_from(editor: TextEdit) -> void:
	editor.gui_input.disconnect(_on_focused_editor_gui_input)

func connect_to(editor: TextEdit) -> void:
	editor.gui_input.connect(_on_focused_editor_gui_input.bind(editor))


func connect_to_window(window: Window) -> void:
	if window.gui_focus_changed.is_connected(_on_focus_changed):
		print_rich("[color=green]Skipping already connected " + str(window))
		return
	
	print_rich("[color=green]Connecting to " + str(window))
	window.gui_focus_changed.connect(_on_focus_changed)
	window.focus_exited.connect(_on_window_focus_exited.call_deferred)
	_on_focus_changed(window.gui_get_focus_owner())


func _on_window_focus_exited() -> void:
	print_rich("[color=red]FOCUS LOST")
	connect_to_window(await get_current_focused_window())


func get_current_focused_window() -> Window:
	if Engine.get_version_info().hex >= 0x04_05_00: # only in Godot 4.5
		var focused_window: Window = null
		while focused_window == null:
			await get_tree().process_frame
			
			focused_window = get_window().get_focused_window() # I know that
			# calling the static method directly on Window would be more elegant,
			# but it would cause a static analysis error on Godot 4.4 and before.
			
			print("attempting")
		return focused_window
	
	print("Compatibility problem with Godot 4.4-")
	# TODO Find a way to do that pre Godot 4.4
	return get_window()


#func _process(_delta: float) -> void:
	#print(Window.get_focused_window())

func _on_focus_changed(control: Control) -> void:
	#if focused_editor:
		#disconnect_from(focused_editor)
	print("focus changed to", control)
	if control is TextEdit:
		print("connecting to: ", control)
		connect_to(control)


func _on_focused_editor_gui_input(input_event: InputEvent, editor: TextEdit) -> void:
	if not input_event.is_pressed() or input_event.is_echo():
		return
	
	print("gui input: ", editor)
	for action in TOGGLING_ACTIONS:
		if is_action(input_event, action):
			print("TOGGLED BY THE TOGGLER")
			TagToggler.toggle_tag(editor, TOGGLING_ACTIONS[action])


# TODO Find some place to put this with the one of BBCodeEdit
static func is_action(event: InputEvent, action: StringName) -> bool:
	return InputMap.has_action(action) and event.is_action(action, true)
