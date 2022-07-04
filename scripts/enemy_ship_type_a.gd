class_name EnemyShip
extends KinematicBody2D

export(float) var speed = 50
export(Vector2) var velocity = Vector2(-1, 0)
onready var dead_tex = preload("res://enemies/enemy-1-death.png")
var hit_points = 30
var dying = false

func _ready():
	pass

func wait(time: float):
	return get_tree().create_timer(time)
	
func _process(delta):
	var modulate_factor = 1 - (clamp(hit_points, 0, 30) / 30)
	var o = lerp(1, 0.5, modulate_factor)
	modulate = Color(1, o, o)

func _physics_process(delta):
	var collision = move_and_collide(velocity * speed * delta, true)
	# TODO: handle collision

func hurt(type, damage):
	if dying:
		return
	hit_points -= damage
	if hit_points <= 0:
		die()

func die():
	$tex.texture = dead_tex
	# Disable collision
	collision_layer = 0
	collision_mask = 0
	dying = true
	visible = false
	
	for seen in [false, true, false, true, false, true, false, true,]:
		yield(wait(0.05), "timeout")
		visible = seen
	yield(wait(0.25), "timeout")
	queue_free()
