extends Node2D

export(String, "player", "enemy") var target_group: String
export(float) var reload_time: float = 0.8

var equipped = true

onready var time = $Timer
onready var bullet = preload("res://ships/projectiles/bullet.tscn")
var bullets_parent: Node
var chambered = true

func wait(time: float):
	return get_tree().create_timer(time)

func fire(from):
	if not equipped:
		return
	for i in Bullets.fire_amt:
		var dir = Vector2(1, 0).rotated(deg2rad(rand_range(-i, i)))
		Bullets.fire(bullet, "bullet", "enemy", from, dir, 400)
		yield(wait(0.15 / Bullets.fire_amt), "timeout")

func _process(delta: float):
	if Input.is_action_pressed("fire") and chambered:
		chambered = false
		time.start(reload_time)
		fire(global_position)
		
func add_bullets_node(path: NodePath):
	bullets_parent = get_node(path)
	assert(bullets_parent, "Invalid path to bullets_parent:" + path.get_as_property_path())

func _on_chambered():
	chambered = true
