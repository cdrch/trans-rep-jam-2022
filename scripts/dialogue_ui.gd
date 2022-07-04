#class_name 
extends Control
# Script description goes here

# Signals


# Member variables
var enemy_dialogue_box_anim: AnimationPlayer
var player_dialogue_box_anim: AnimationPlayer

# onready variables


# Constants


# Enums


# Core functions
#func _init() -> void:


func _ready() -> void:
	enemy_dialogue_box_anim = $EnemyDialogueBox/AnimationPlayer
	player_dialogue_box_anim = $PlayerDialogueBox/AnimationPlayer
	
	# TODO: Be sure to remove dialogue debug tests
	#test_dialogue_toggles()

#func _input(event) -> void:


#func _unhandled_input(event) -> void:


#func _process(delta: float) -> void:


#func _physics_process(delta: float) -> void:


# Getters/Setters


# Public functions
# TODO: Improve animations and add non-linear motion curves
func toggle_on_enemy_dialogue_box():
	enemy_dialogue_box_anim.play("move_dialogue_up")
	pass


func toggle_off_enemy_dialogue_box():
	enemy_dialogue_box_anim.play_backwards("move_dialogue_up")
	pass


func toggle_on_player_dialogue_box():
	player_dialogue_box_anim.play("move_dialogue_up")
	pass


func toggle_off_player_dialogue_box():
	player_dialogue_box_anim.play_backwards("move_dialogue_up")
	pass

func wait(time: float):
	return get_tree().create_timer(time)

# Private functions
func test_dialogue_toggles():
	yield(wait(5.0), "timeout")
	toggle_on_enemy_dialogue_box()
	yield(wait(1.0), "timeout")
	toggle_on_player_dialogue_box()
	yield(wait(2.0), "timeout")
	toggle_off_enemy_dialogue_box()
	yield(wait(1.0), "timeout")
	toggle_off_player_dialogue_box()
