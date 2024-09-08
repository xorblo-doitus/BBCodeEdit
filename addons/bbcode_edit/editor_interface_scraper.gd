extends Object


## This singleton has utility methods to scrap the Editor's interface


const TYPE_TO_NAME = {
	TYPE_NIL: &"Variant",
	
	TYPE_BOOL: &"bool",
	TYPE_INT: &"int",
	TYPE_FLOAT: &"float",
	TYPE_STRING: &"String",
	
	TYPE_VECTOR2: &"Vector2",
	TYPE_VECTOR2I: &"Vector2i",
	TYPE_RECT2: &"Rect2",
	TYPE_RECT2I: &"Rect2i",
	TYPE_VECTOR3: &"Vector3",
	TYPE_VECTOR3I: &"Vector3i",
	TYPE_TRANSFORM2D: &"Transform2D",
	TYPE_VECTOR4: &"Vector4",
	TYPE_VECTOR4I: &"Vector4i",
	TYPE_PLANE: &"Plane",
	TYPE_QUATERNION: &"Quaternion",
	TYPE_AABB: &"AABB",
	TYPE_BASIS: &"Basis",
	TYPE_TRANSFORM3D: &"Transform3D",
	TYPE_PROJECTION: &"Projection",
	
	TYPE_COLOR: &"Color",
	TYPE_STRING_NAME: &"StringName",
	TYPE_NODE_PATH: &"NodePath",
	TYPE_RID: &"RID",
	TYPE_OBJECT: &"Object",
	TYPE_CALLABLE: &"Callable",
	TYPE_SIGNAL: &"Signal",
	TYPE_DICTIONARY: &"Dictionary",
	TYPE_ARRAY: &"Array",
	
	TYPE_PACKED_BYTE_ARRAY: &"PackedByteArray",
	TYPE_PACKED_INT32_ARRAY: &"PackedInt32Array",
	TYPE_PACKED_INT64_ARRAY: &"PackedInt64Array",
	TYPE_PACKED_FLOAT32_ARRAY: &"PackedFloat32Array",
	TYPE_PACKED_FLOAT64_ARRAY: &"PackedFloat64Array",
	TYPE_PACKED_STRING_ARRAY: &"PackedStringArray",
	TYPE_PACKED_VECTOR2_ARRAY: &"PackedVector2Array",
	TYPE_PACKED_VECTOR3_ARRAY: &"PackedVector3Array",
	TYPE_PACKED_COLOR_ARRAY: &"PackedColorArray",
	TYPE_PACKED_VECTOR4_ARRAY: &"PackedVector4Array",
}


static func get_icon(icon: StringName) -> Texture2D:
	return EditorInterface.get_base_control().get_theme_icon(icon, &"EditorIcons")


static func get_color_icon() -> Texture2D:
	return get_icon(&"Color")


static func get_reference_icon() -> Texture2D:
	return get_icon(&"Help")


static func try_get_icon(icon: StringName, fallback: StringName) -> Texture2D:
	var result: Texture2D = get_icon(icon)
	if result == get_icon(&"za86e81czxe1s89az6ee7s1"): # Random
		return get_icon(fallback)
	return result


static func get_builtin_class_icon(class_name_: StringName) -> Texture2D:
	var result: Texture2D = get_icon(class_name_)
	var file_broken: Texture2D = get_icon(&"za86e81czxe1s89az6ee7s1") # Random
	while result == file_broken and class_name_ != &"":
		class_name_ = ClassDB.get_parent_class(class_name_)
		result = get_icon(class_name_)
	return result


static func get_class_icon(name: StringName, fallback: StringName) -> Texture2D:
	if ClassDB.class_exists(name):
		return get_builtin_class_icon(name)
	var base_name = name
	var global_class_list := ProjectSettings.get_global_class_list()
	var found: bool = true
	while found:
		found = false
		for class_ in global_class_list:
			if class_["class"] == name:
				if class_["icon"]:
					return load(class_["icon"])
				else:
					name = class_["base"]
					if ClassDB.class_exists(name):
						return get_builtin_class_icon(name)
					found = true
					break
	
	# This can happen for type union (ex: CanvasItemMaterial,ShaderMaterial)
	return get_icon(fallback)


static func get_type_icon(value: Variant, fallback: StringName) -> Texture2D:
	var type: int = typeof(value)
	if type == TYPE_OBJECT:
		if value is Script:
			var to_check: Script = value
			while true:
				if to_check.get_global_name():
					return get_class_icon(to_check.get_global_name(), fallback)
				# TODO MAYBE Read first line for @icon
				if to_check.get_base_script():
					to_check = to_check.get_base_script()
				else:
					return get_builtin_class_icon(to_check.get_instance_base_type())
		
		var script: Script = value.get_script()
		if script:
			var search_for: Script = script
			while true:
				for class_ in ProjectSettings.get_global_class_list():
					if class_["path"] == search_for.resource_path:
						return get_class_icon(class_["class"], fallback)
				if search_for.get_base_script():
					search_for = search_for.get_base_script()
				else:
					return get_builtin_class_icon(search_for.get_instance_base_type())
		
		return get_builtin_class_icon(value.get_class())
	
	return get_icon(TYPE_TO_NAME.get(type, fallback))


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
