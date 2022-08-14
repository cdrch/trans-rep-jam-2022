extends Node

var bullets_parent: Node2D

var fire_amt = 1
var level = 1
var weapon

func upgrade():
	fire_amt += 1

func level_up():
	level += 1

func fire(
		scene: PackedScene, 
		damage_type: String, 
		target: String, 
		from_global: Vector2, 
		direction: Vector2, 
		speed: float,
		stop = false):
	var b = scene.instance()
	if level > 1 and target == "enemy":
		b.get_node("tex").texture = preload("res://ships/projectiles/shot_2.png")
		b.damage = 20
	b.speed = speed
	b.target_group = target
	b.damage_type = damage_type
	b.velocity = direction.normalized()
	call_deferred("finish_bullet", b, from_global, direction)
	if level > 2 and target == "enemy" and not stop:
		fire(scene, damage_type, target, from_global, direction, speed, true)
	
func finish_bullet(b, from_global, direction):
	bullets_parent.add_child(b)
	b.global_position = from_global
	b.rotation = direction.angle()
