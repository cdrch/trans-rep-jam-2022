extends Node2D


var targetScene = "res://levels/main_menu.tscn"

func _ready():
	pass

func _on_btnMenu_pressed():
	get_tree().change_scene(targetScene)
