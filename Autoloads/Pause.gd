extends Node2D

var enabled = false

func _ready():
	pass

func _process(_delta):
	if Input.is_action_just_pressed("pause") and enabled:
		var pmenu = preload("res://levels/PauseMenu.tscn").instance()
		Bullets.bullets_parent.add_child(pmenu)
		pmenu.global_position = Bullets.bullets_parent.global_position
		get_tree().paused = true
