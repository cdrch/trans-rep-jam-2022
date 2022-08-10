extends Node2D

export(PackedScene) var scene_on_start
export(PackedScene) var scene_on_options


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Grab focus to enable keyboard control
	$Menu/VBoxContainer/StartButton.grab_focus()
	$PlayerShip.gun_equipped = false

var shipArrived = Deferred.new()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $PlayerShip.global_position.x >= $"End position".global_position.x:
		shipArrived.done()


func _on_StartButton_pressed():
	Input.action_press("ui_right")
	yield(shipArrived, "done")
	Input.action_release("ui_right")
	Globals.Starfield = $Background
	remove_child($Background)
	get_tree().change_scene_to(scene_on_start)


func _on_OptionsButton_pressed():
	pass # Replace with an options menu, instanced as a child


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_Continue_pressed():
	pass # Replace with function body.


func _on_Credits_pressed():
	pass # Replace with function body.
