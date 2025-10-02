extends Object


## This singleton has utility methods to scrap the Editor's interface



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
