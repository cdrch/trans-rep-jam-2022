extends Node

var Starfield
var Ship
var Ship_Pos

func _ready():
	pass

func replace_node(target: Node2D, value: Node2D):
	var p = target.get_parent()
	var p_idx = target.get_position_in_parent()
	value.name = target.name
	p.remove_child(target)
	target.queue_free()
	p.add_child(value)
	p.move_child(value, p_idx)

