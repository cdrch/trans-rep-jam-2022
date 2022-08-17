extends Node2D


func _ready():
	pass


func _on_LinkButton_pressed():
	OS.shell_open("https://godotengine.org/license")


func _on_menuBtn_pressed():
	get_tree().change_scene("res://levels/main_menu.tscn")

var velocity = 0
var accelleration = 10
var friction = 20

func _process(delta):
	var dir = 0
	if Input.is_action_pressed("ui_down"):
		velocity -= accelleration * delta
		dir = -1
	elif Input.is_action_pressed("ui_up"):
		velocity += accelleration * delta
		dir = 1
	else:
		var new_velocity = clamp(velocity + (-sign(velocity)* friction * delta), -300, 300)
		if sign(new_velocity) != sign(velocity):
			velocity = 0
		else:
			velocity = new_velocity
	
	$credits.rect_position.y = clamp($credits.rect_position.y + velocity, -1780, 100)
	if $credits.rect_position.y == 100 or $credits.rect_position.y == -1780:
		velocity = 0
