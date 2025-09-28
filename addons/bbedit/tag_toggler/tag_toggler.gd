extends Object


# TODO make so that if it's surrounded by another tag it works too.
# exemple: [b][i]bold italic[/b][/i] → toggling b when selecting only the text would work.
static func toggle_tag(editor: TextEdit, tag: String) -> void:
	var prefix: String = "[" + tag + "]"
	var prefix_len: int = prefix.length()
	var suffix: String = "[/" + tag + "]"
	var suffix_len: int = suffix.length()
	
	var main_selection_from_column: int = editor.get_selection_from_column()
	var main_selection_from_line: int = editor.get_selection_from_line()
	var main_selection_to_column: int = editor.get_selection_to_column()
	var main_selection_to_line: int = editor.get_selection_to_line()
	var main_selection_end_line: String = editor.get_line(main_selection_to_line)
	
	if (
		main_selection_from_column >= prefix_len
		and editor.get_line(main_selection_from_line).substr(
			main_selection_from_column - prefix_len,
			prefix_len
		) == prefix
		and main_selection_to_column <= main_selection_end_line.length() - suffix_len
		and main_selection_end_line.substr(
			main_selection_to_column,
			suffix_len
		) == suffix
	):
		editor.begin_complex_operation()
		editor.begin_multicaret_edit()
		
		for caret in editor.get_caret_count():
			if editor.multicaret_edit_ignore_caret(caret):
				continue
			
			var initial_text: String = editor.get_selected_text(caret)
			var initial_start_column: int = editor.get_selection_from_column(caret)
			var initial_end_column: int = editor.get_selection_to_column(caret)
			
			editor.select(
				editor.get_selection_from_line(caret),
				initial_start_column - prefix_len,
				editor.get_selection_to_line(caret),
				initial_end_column + suffix_len,
				caret
			)
			editor.insert_text_at_caret(initial_text, caret)
			editor.select(
				editor.get_selection_from_line(caret),
				initial_start_column - prefix_len,
				editor.get_selection_to_line(caret),
				initial_end_column - prefix_len,
				caret
			)
		
		editor.end_multicaret_edit()
		editor.end_complex_operation()
		return
	
	editor.begin_complex_operation()
	editor.begin_multicaret_edit()
	
	for caret in editor.get_caret_count():
		if editor.multicaret_edit_ignore_caret(caret):
			continue
		
		var initial_start_column: int = editor.get_selection_from_column(caret)
		var initial_end_column: int = editor.get_selection_to_column(caret)
		
		editor.insert_text_at_caret(prefix + editor.get_selected_text(caret) + suffix, caret)
		
		editor.select(
			editor.get_selection_from_line(caret),
			initial_start_column + prefix_len,
			editor.get_selection_to_line(caret),
			initial_end_column + prefix_len,
			caret
		)
	
	editor.end_multicaret_edit()
	editor.end_complex_operation()
