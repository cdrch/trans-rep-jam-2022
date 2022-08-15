extends Node2D

signal unpaused()

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _on_BtnMainMenu_pressed():
	get_tree().paused = false
	emit_signal("unpaused")
	get_tree().change_scene("res://levels/main_menu.tscn")

func _on_BtnResume_pressed():
	get_tree().paused = false
	emit_signal("unpaused")
	queue_free()
