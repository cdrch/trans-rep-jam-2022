extends Node2D

var enabled = false

var paused = false

signal unpaused()

func _ready():
	pass

func _process(_delta):
	if Input.is_action_just_pressed("pause") and enabled:
		var pmenu = preload("res://levels/PauseMenu.tscn").instance()
		Bullets.bullets_parent.add_child(pmenu)
		pmenu.global_position = Bullets.bullets_parent.global_position
		pmenu.connect("unpaused", self, "unpause")
		paused = true
		get_tree().paused = true
		
		
func unpause():
	paused = false
	emit_signal("unpaused")
