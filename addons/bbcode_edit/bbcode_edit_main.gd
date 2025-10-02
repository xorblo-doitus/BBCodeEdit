@tool
extends EditorPlugin



#const ADDON_NAME = "BBCodeEdit"
#
#
#const SUB_PLUGINS: Array[String] = [
	#"doc_comment.editor",
	#"tag_toggler",
#]
#
#
#func _enable_plugin() -> void:
	#print("Enabling ", ADDON_NAME)
	#set_sub_plugins_enabled(true)
	#print("Enabled ", ADDON_NAME)
#
#
#func _disable_plugin() -> void:
	#print("Disabling ", ADDON_NAME)
	#set_sub_plugins_enabled(false)
	#print("Disabled ", ADDON_NAME)
#
#
#func set_sub_plugins_enabled(enabled: bool) -> void:
	#for sub_plugin in SUB_PLUGINS:
		#if DirAccess.dir_exists_absolute("res://addons/bbcode_edit".path_join(sub_plugin)):
			#EditorInterface.set_plugin_enabled(
				#"bbcode_edit".path_join(sub_plugin),
				#true
			#)
