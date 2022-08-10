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
	$PlayerShip.velocity_override = Vector2(1, 0)
	yield(shipArrived, "done")
	$PlayerShip.velocity_override = null
	$PlayerShip.gun_equipped = true
	Globals.Starfield = $Background
	remove_child($Background)
	Globals.Ship_Pos = $PlayerShip.global_position
	Globals.Ship = $PlayerShip
	remove_child($PlayerShip)
	get_tree().change_scene_to(scene_on_start)


func _on_OptionsButton_pressed():
	pass # Replace with an options menu, instanced as a child


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_Continue_pressed():
	pass # Replace with function body.


func _on_Credits_pressed():
	pass # Replace with function body.


const PRIDE_RED = Color(228, 3, 3)
const PRIDE_ORANGE = Color(255, 140, 0)
const PRIDE_YELLOW = Color(255, 237, 0)
const PRIDE_GREEN = Color(0, 128, 38)
const PRIDE_INDIGO = Color(36, 64, 142)
const PRIDE_VIOLET = Color(115, 41, 130)
var rainbow_colors = [PRIDE_RED, PRIDE_ORANGE, PRIDE_YELLOW, PRIDE_GREEN, PRIDE_INDIGO, PRIDE_VIOLET]
var current_rainbow_color_index = 5 # Starts at 5 so first call ends up at 0


func get_current_rainbow_color() -> Color:
	current_rainbow_color_index += 1
	current_rainbow_color_index %= 6
	return current_rainbow_color_index
