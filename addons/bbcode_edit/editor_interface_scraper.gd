extends Object


## This singleton has utility methods to scrap the Editor's interface



static func get_icon(icon: StringName) -> Texture2D:
	return EditorInterface.get_base_control().get_theme_icon(icon, &"EditorIcons")


static func get_color_icon() -> Texture2D:
	return get_icon(&"Color")


static func get_reference_icon() -> Texture2D:
	return get_icon(&"Help")


static func get_class_icon(class_name_: StringName) -> Texture2D:
	var result: Texture2D = get_icon(class_name_)
	var file_broken: Texture2D = get_icon(&"za86e81czxe1s89az6ee7s1") # Random
	while result == file_broken and class_name_ != &"":
		class_name_ = ClassDB.get_parent_class(class_name_)
		result = get_icon(class_name_)
	return result


## Scrap the Editor tree to find if it's unsaved.
static func is_current_script_unsaved() -> bool:
	# Reference path: $"../../../../../../@VSplitContainer@9820/@VBoxContainer@9821/@ItemList@9824"
	var current_editor := EditorInterface.get_script_editor().get_current_editor().get_base_editor()
	if current_editor is not CodeEdit:
		return false
	
	var pointer: Node = current_editor.get_node(^"../../../../../..")
	
	if pointer == null:
		return false
	
	for node_type: String in ["VSplitContainer", "VBoxContainer", "ItemList"]:
		pointer = _fetch_node(pointer, node_type)
		if pointer == null:
			return false
	
	var item_list: ItemList = pointer
	return item_list.get_item_text(item_list.get_selected_items()[0]).ends_with("(*)")


static func _fetch_node(parent: Node, type: String) -> Node:
	type = "@" + type
	for child in parent.get_children():
		if child.name.begins_with(type):
			return child
	return null
