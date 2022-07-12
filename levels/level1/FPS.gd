#class_name 
extends Label
# Script description goes here

# Signals

func _process(delta):
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	text = "%.2f" % fps 


# Member variables


# onready variables


# Constants


# Enums


# Core functions
#func _init():


#func _ready():


#func _input(event):


#func _unhandled_input(event):


#func _process(delta):


#func _physics_process(delta):


# Getters/Setters


# Public functions


# Private functions
