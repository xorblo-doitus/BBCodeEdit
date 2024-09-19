# BBCodeEdit (for script editor[^editor_only])

![alt text](/icon.svg)

A Godot addon that brings BBCode completion and QOL tools to the script editor
in order to help format documentation comments.
(May be extended to any CodeEdit in the future.[^editor_only])


# Showcase

There are **shortcuts** to easily toggle some formattings:

![Using the keyboard to toggle bold, italic, underline, striketrough](/addons/bbcode_edit.editor/.assets_for_readme/shortcuts.gif)


**Completion** for formatting tags, with some special completions implemented for specific tags:

![Advanced completion for color tag](/addons/bbcode_edit.editor/.assets_for_readme/color_completion.gif)


**Documentation references** are completed:

![Reference completion](/addons/bbcode_edit.editor/.assets_for_readme/reference_completion.gif)


Some useful **snippets** are included:

![A "Note" snippet, with the same formatting as the one used in the official documentation](/addons/bbcode_edit.editor/.assets_for_readme/snippet.gif)


# Features / Roadmap

*Checked items are the implemented ones, unchecked are the ones in development.[^editor_only]*

- [ ] Code completion for:
  - [x] Most used BBCode tags
  - [ ] All BBCode tags[^editor_only] (See [Godot Reference](https://docs.godotengine.org/en/4.3/tutorials/ui/bbcode_in_richtextlabel.html#reference))
  - [x] Documentation comments:
    - [x] formatting tags
    - [x] referencing tag
    - [x] `@` tags:
      - [x] deprecated
      - [x] experimental
      - [x] tutorial
    - [x] Snippets:
      - [x] **Note:**, **Warning:**...
- [ ] Classify tags accepted in documentation comments according to [Godot Reference](https://docs.godotengine.org/en/4.3/tutorials/scripting/gdscript/gdscript_documentation_comments.html#bbcode-and-class-reference)
- [ ] Advanced completions:
  - [x] Color:
    - [x] Named colors
    - [x] Hexadecimal color preview (**Note: ** If it starts with a digit, `0x` will be prefixed temporarily because Godot cancels int completion)
    - [x] Color picker
  - [ ] URL of files? (I don't know if file URLs work)
  - [x] Documentation comments' references: (NB: [Inner classes](https://docs.godotengine.org/en/4.3/tutorials/scripting/gdscript/gdscript_basics.html#inner-classes) won't be properly proposed in completions)
    - [x] Classes
    - [x] Parameters
    - [x] Members (aka. Properties)
    - [x] Methods (aka. Functions)
    - [x] Constants
    - [x] Signals
    - [x] Enums
    - [ ] Other references, like annotations or operators, are not implemented because they are rarely used.
- [ ] ~~BBCode preview (through [SyntaxHighlighter](https://docs.godotengine.org/en/4.3/classes/class_syntaxhighlighter.html)?)~~\
      ~~Edit: Won't work because GDSCriptSyntaxHighlighter can't be extended\
      BBCode spellcheck/semi-preview (through `_draw()` ?)~~\
      Edit 2: Won't implement, because there is easier:
- [ ] Add a shortcut to open:
  - [x] Current file documentation (May have a problem if pressed before the editor checks unsaved status of the file)
  - [ ] Preview of the selected text (or autodetect start and end if no selection)
- [ ] Add shortcuts for:  
    *You can rebind them in `Project → Project settings → Input Map`. If you just enabled the addon, they may appear here only after a restart of the editor. You will have to restart the editor for any change to take effect.*
  - [x] **bold** (`alt + B`)
  - [x] *italic* (`alt + I`)
  - [x] ~~striketrough~~ (`alt + C`, but if you had unbound `alt + S` from `open shader editor`, it will be `alt + S`)
  - [x] <u>underline</u> (`alt + U`)
  - [ ] Wrap in any tag?
- [ ] Add an external CodeEdit in the editor to write bbcode, because completion inside strings is a nightmare due to builtin behaviors.[^editor_only]


## Intallation

You can download the addon:
- On GitHub: `Code` → `Download ZIP`.
- Through the editor: `AssetLib` → Search for "BBCodeEdit"

*By default, this readme is included, along with it's illustrations. If you don't want them,
do not download `addons/bbcode_edit.editor/README.md` nor `addons/bbcode_edit.editor/.assets_for_readme/*`*

To edit shortcuts, first restart the editor, then modify them,
and restart the editor so that Godot updates the input map.

You can also exclude `*.editor/*` or `bbcode_edit.editor/` from your export presets,
because this addon is (for now[^editor_only]) script-editor-only.


## Godot version

Godot 4.3 (May work with previous 4.x versions)


# Development Status

Development halted. But the addon is really handy as-is.

[^editor_only]: **Note:** All non-script-editor-related features are on hold for now
  because I don't have the time nor the need to implement them.
  This would also require refactoring `bbcode_edit.gd` into two separate classes.
  One with all [RichTextLabel's tags](https://docs.godotengine.org/en/4.3/tutorials/ui/bbcode_in_richtextlabel.html#reference)
  and one with [documentation comments' tags](https://docs.godotengine.org/en/4.3/tutorials/scripting/gdscript/gdscript_documentation_comments.html#bbcode-and-class-reference).
  If you really need BBCode completion in a CodeEdit (eg. for an inspector plugin, or for any code edit within an exported project),
  I *may* give it a try, or you could contribute this refactor (this repo is under the MIT Licence).