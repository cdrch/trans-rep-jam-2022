extends "res://addons/easy_velocity_vector_display/vectordisplay2D.gd"


func _ready() -> void:
	target_node = get_parent()
	if not target_property or target_property == "":
		target_property = "velocity"
	if not vector_scale or vector_scale == 1.0:
		vector_scale = 0.25

