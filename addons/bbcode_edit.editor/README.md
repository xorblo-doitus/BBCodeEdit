# BBCodeEdit
A Godot addon that help editing BBCode in CodeEdit nodes, especially useful for documentation comments in the ScriptEditor.


# Showcase

There are shortcuts to toggle easily some formattings:

![Using keyboard to toggle bold, italic, underline, striketrough](/addons/bbcode_edit.editor/.assets_for_readme/shortcuts.gif)


Completion for formatting tags, with some special completions implemented for specific tags:

![Advanced completion for color tag](/addons/bbcode_edit.editor/.assets_for_readme/color_completion.gif)


Documentation reference are completed:

![Reference completion](/addons/bbcode_edit.editor/.assets_for_readme/reference_completion.gif)


Some useful snippets are included:

![A "Note" snippet, with the sae formating as the one used in the official documentation](/addons/bbcode_edit.editor/.assets_for_readme/snippet.gif)


# Features

*Checked items are the implemented ones, unchacked are the ones in development*

- [ ] Code completion for:
  - [x] Most used BBCode tags
  - [ ] All BBCode tags (See [Godot Reference](https://docs.godotengine.org/en/4.3/tutorials/ui/bbcode_in_richtextlabel.html#reference))
  - [x] Documentation comments:
    - [x] formating tags
    - [x] referencing tag
    - [x] `@` tags:
      - [x] deprecated
      - [x] experimental
      - [x] tutorial
    - [x] Snipets:
      - [x] **Note:**, **Warning:**...
- [ ] Classify tags accepted in documentation comments according to [Godot Reference](https://docs.godotengine.org/en/4.3/tutorials/scripting/gdscript/gdscript_documentation_comments.html#bbcode-and-class-reference)
- [ ] Advanced completions:
  - [x] Color:
    - [x] Named colors
    - [x] Hexadecimal color preview
    - [x] Color picker
  - [ ] URL of files? (Don't know if file url works)
  - [x] Documentation comments's references: (NB: [Inner Classes](https://docs.godotengine.org/en/4.3/tutorials/scripting/gdscript/gdscript_basics.html#inner-classes) wont be properly proposed in completions)
    - [x] Classes
    - [x] Parameters
    - [x] Members (aka. Properties)
    - [x] Methods (aka. Functions)
    - [x] Constants
    - [x] Signals
    - [x] Enums
    - [ ] Other references like annotations or operators are not implemented, because rarely used.
- [ ] ~~BBCode preview (trough [SyntaxHighlighter](https://docs.godotengine.org/en/4.3/classes/class_syntaxhighlighter.html)?)~~\
      ~~Edit: Won't work because GDSCriptSyntaxHighlighter can't be extended\
      BBCode spellcheck/semi-preview (trough `_draw()` ?)~~\
      Edit 2: Wont implement, because there is easier:
- [ ] Add a shortcut to open:
  - [x] Current file documentation (May have a problem if pressed before editor check unsaved status of the file)
  - [ ] Preview of the selected text (or autodetect start and end if no selection)
- [ ] Add shortcuts for:  
    *You can rebind them in `Project → Project settings → Input Map`. If you just enabled the addon, they may appear here only after a restart of the editor. You will have to restart the editor for any change to take effect.*
  - [x] **bold** (`alt + B`)
  - [x] *italic* (`alt + I`)
  - [x] ~~striketrough~~ (`alt + C`, but if you had unbind `alt + S` from `open shader editor`, it will be `alt + S`)
  - [x] <u>underline</u> (`alt + U`)
  - [ ] Wrap in any tag?
- [ ] Add an external code edit in the editor to write bbcode, because completion inside strings is a nightmare due to builtin behaviors


## Intallation

Download only `res://addons/bbcode_edit.editor`.


## Godot version

Godot 4.3 (May work with previous 4.x versions)


# Status

In development, will flood output with debug info.