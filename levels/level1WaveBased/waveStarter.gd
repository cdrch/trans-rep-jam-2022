tool
class_name waveStarter
extends Node2D
# Script description goes here

onready var enemy = preload("res://ships/enemies/enemy1/basic_enemy.tscn")

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	if not Engine.editor_hint:
		$viewport_hint.queue_free()
		run_basic_wave()

func _process(delta):
	pass
	
func run_basic_wave():
	yield(T.wait(3), D.o)
	for t in $GruntFormationPoints.get_children():
		spawn_basic(t)
	
func spawn_basic(target: Node2D):
	yield(T.wait(rand_range(0, 5)), D.o)
	var e = enemy.instance()
	e.bullets_node = $BulletsDump.get_path()
	$EnemyDump.add_child(e)
	e.shot_mode = "Horizontal"
	var start = rand_child($Spawners)
	e.global_position = start.global_position
	
	e.target = target.position

func rand_child(node: Node2D) -> Node2D: 
	var children = node.get_children()
	return children[randi() % children.size()]
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