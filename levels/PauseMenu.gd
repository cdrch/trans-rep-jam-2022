extends Node2D

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _on_BtnMainMenu_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://levels/main_menu.tscn")


func _on_BtnResume_pressed():
	get_tree().paused = false
	queue_free()
