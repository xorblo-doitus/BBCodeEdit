@icon("res://addons/bbcode_edit/bbcode_completion_icon.svg")
class_name Named
extends Node


## Short desc.
##
## Long desc.
## [enum NamedEnum]
## [enum Named.NamedEnum.D]
## [enum CodeEdit.CodeCompletionKind]
## [constant OH]
## [constant D]
## [enum ]
## [constant ]
## [enum NamedEnum]


enum NamedEnum {
	A,
	B,
	## Artificial long desc: [br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br][br]
	C,
	D,
}
enum OtherNamedEnum {D}
enum {OH, NO}


## [constant ]
const CONTANT_STRING = "ah"
const CONTANT_INT = 5
## [constant BbcodeEdit]
const BbcodeEdit = preload("res://addons/bbcode_edit/bbcode_edit.gd")

## Press [color=   red   
## ]Ctrl + C oh no[/color].
## [b
## 
##]
##space
## space[member ]
##
## [
## color=red]
##  space
##   space[/color]
## [member ]
var truc: bool

@export_category("cat")
@export_group("grouuuup")
## [member ]
var dyamic = 987
var varying: Variant = "987"
@warning_ignore("unused_private_class_variable")
var _str: String = "987"
var machin: int = 123
## [member ]
var obj: Node = Node.new()
#var sérieux: null = null

## [member auto_translate_mode] [method add_child]
## Testazeiln,azlekj,azUPDATE3[color=aqua]azejnzaekj[/color]
## aaa[img width=32 height=10 color=red region=0,0,10,10 tootip=hello]res://addons/bbcode_edit/bbcode_completion_icon.svg[/img]bbb
func doc_test()-> void:
	pass


class SubClass:
	var sub_class_member: int = 52
