@tool
extends EditorPlugin



const ADDON_NAME = "BBEdit: Tag Toggler"






func _enable_plugin() -> void:
	print("Enabling ", ADDON_NAME)
	add_autoload_singleton("TagToggler", "res://addons/bbedit/tag_toggler/tag_toggler_auto_load.gd")
	print("Enabled ", ADDON_NAME)


func _disable_plugin() -> void:
	print("Disabling ", ADDON_NAME)
	remove_autoload_singleton("TagToggler")
	print("Disabled ", ADDON_NAME)
