extends Area2D

var held: bool = false
var held_layer = null
var held_mask = null
var shieldNode: Barrier = null

func _physics_process(delta):
	if shieldNode and Input.is_action_just_pressed("interaction"):
		shieldNode.grab()
		
	if shieldNode and Input.is_action_just_released("interaction"):
		shieldNode.drop()
		
	if shieldNode and Input.is_action_pressed("interaction"):
		shieldNode.global_position = global_position
	
func _on_ShieldGrabPoint_area_entered(area: Area2D):
	if area.get_groups().has("shield_grab_handle") and shieldNode == null:
		shieldNode = area
		
func _on_ShieldGrabPoint_area_exited(area: Area2D):
	if shieldNode != null and area == shieldNode:
		held_layer = shieldNode.collision_layer 
		held_mask = shieldNode.collision_mask
		
		shieldNode = null
