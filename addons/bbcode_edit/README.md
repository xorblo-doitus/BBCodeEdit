# BBCodeEdit
A Godot addon that help editing BBCode in CodeEdit nodes, especially useful for documentation comments in the ScriptEditor.


# Features

*Checked items are the implemented ones, unchacked are the ones in development*

- [ ] Code completion for:
  - [x] Most used BBCode tags
  - [ ] All BBCode tags (See [Godot Reference](https://docs.godotengine.org/en/4.3/tutorials/ui/bbcode_in_richtextlabel.html#reference))
  - [ ] Documentation comments:
    - [x] formating tags
    - [x] referencing tag
    - [ ] `@` tags
    - [ ] Snipets:
      - [ ] **Note:**, **Warning:**...
- [ ] Classify tags accepted in documentation comments according to [Godot Reference](https://docs.godotengine.org/en/4.3/tutorials/scripting/gdscript/gdscript_documentation_comments.html#bbcode-and-class-reference)
- [ ] Advanced completions:
  - [x] Color:
    - [x] Named colors
    - [x] Hexadecimal color preview
    - [x] Color picker
  - [ ] URL of files? (Don't know if file url works)
  - [ ] Documentation comments's references (Don't know feasibility):
    - [x] Classes
- [ ] ~~BBCode preview (trough [SyntaxHighlighter](https://docs.godotengine.org/en/4.3/classes/class_syntaxhighlighter.html)?)~~\
      ~~Edit: Won't work because GDSCriptSyntaxHighlighter can't be extended\
      BBCode spellcheck/semi-preview (trough `_draw()` ?)~~\
      Edit 2: Wont implement, because there is easier:
- [ ] Add a shortcut to open:
  - [x] Current file documentation (May have a problem if pressed before editor check unsaved status of the file)
  - [ ] Preview of the selected text (or autodetect start and end if no selection)
- [ ] Add shortcuts for:
  - [ ] **bold**
  - [ ] *italic*
  - [ ] ~~striketrough~~
  - [ ] <u>underline</u>
  - [ ] etc.
- [ ] Add an external code edit in the editor to write bbcode, because completion inside strings is a nightmare due to builtin behaviors


## Intallation

Download only `res://addons/bbcode_edit`.


## Godot version

Godot 4.3 (May work with previous 4.x versions)


# Status

In development, will flood output with debug info.