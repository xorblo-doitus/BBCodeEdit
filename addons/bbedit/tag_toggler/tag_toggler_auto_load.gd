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
	get_window().gui_focus_changed.connect(_on_focus_changed)


func disconnect_from(editor: TextEdit) -> void:
	editor.gui_input.disconnect(_on_focused_editor_gui_input)

func connect_to(editor: TextEdit) -> void:
	editor.gui_input.connect(_on_focused_editor_gui_input.bind(editor))


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
