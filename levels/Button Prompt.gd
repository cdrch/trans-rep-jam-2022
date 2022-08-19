extends Control

export(String) var desired_input

signal responded_to_prompt

func _process(delta):
	
	if desired_input != "" and Input.is_action_pressed(desired_input):
		emit_signal("responded_to_prompt")
		queue_free()
