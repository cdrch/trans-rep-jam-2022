extends Node2D

signal unpaused()

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS


func _on_MainMenuButton_pressed():
	get_tree().paused = false
	emit_signal("unpaused")
	get_tree().change_scene("res://levels/main_menu.tscn")


func _on_ResumeButton_pressed():
	get_tree().paused = false
	emit_signal("unpaused")
	queue_free()

func _on_QuitButton_pressed():
	get_tree().quit()
