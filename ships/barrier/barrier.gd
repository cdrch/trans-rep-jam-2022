class_name Barrier
extends Area2D
#
signal grabbed()

export(bool) var held = false

const held_layers = [0,0,0,0]
const held_mask = [1,1,1,1]
const free_layers = [0,0,0,1]
const free_mask = [1,1,1,1]


func grab():
	emit_signal("grabbed")
	var barrier = $Barrier
	for i in 4:
		barrier.set_collision_layer_bit(i, held_layers[i] == 1)
		barrier.set_collision_mask_bit(i, held_mask[i] == 1)
		
func drop():
	var barrier = $Barrier
	for i in 4:
		barrier.set_collision_layer_bit(i, free_layers[i] == 1)
		barrier.set_collision_mask_bit(i, free_mask[i] == 1)
	
