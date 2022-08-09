extends Control

export(PackedScene) var scene_on_start
export(PackedScene) var scene_on_options


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Grab focus to enable keyboard control
	$VBoxContainer/StartButton.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StartButton_pressed():
	get_tree().change_scene_to(scene_on_start)


func _on_OptionsButton_pressed():
	pass # Replace with an options menu, instanced as a child


func _on_QuitButton_pressed():
	get_tree().quit()
