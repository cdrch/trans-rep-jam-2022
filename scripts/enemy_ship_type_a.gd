class_name WindsorShip
extends KinematicBody2D

signal dying()
signal dead()

export(float) var speed = 50
export(Vector2) var velocity = Vector2(-1, 0)
export(String, "None", "Vertical", "Horizontal") var shot_mode = "None"
export(NodePath) var bullets_node: NodePath

onready var dead_tex = preload("res://ships/enemies/enemy1/enemy-1-death.png")
onready var bullet_scn = preload("res://ships/projectiles/bullet.tscn")

var bullets_parent: Node
var hit_points = 30
var can_shoot = false
var dying = false

var target: Vector2

var direction = 1
var lerp_weight = 0.5

func mode_time():
	match shot_mode:
		"None": return -1
		"Vertical": return rand_range(1, 1.5)
		"Horizontal": return rand_range(2, 4)
		_: return -1

func _ready():
	$gun_timer.start(mode_time())
	add_bullets_node(bullets_node)

func wait(time: float):
	return get_tree().create_timer(time)
	
func _process(delta):
	var modulate_factor = 1 - (clamp(hit_points, 0, 30) / 30)
	var o = lerp(1, 0.5, modulate_factor)
	modulate = Color(1, o, o)

func _physics_process(delta):
	# zig_zag(delta)
	if target:
		var dir = (target - position) 
		if dir.length() > speed/10:
			var collision = move_and_collide(dir.normalized() * speed * delta, true)
			look_at(target)
			rotate(PI)
		else:
			look_at(position + Vector2(1, 0))
	else:
		var collision = move_and_collide(velocity * speed * delta, true)
	# TODO: handle collision
	
func fire(from: Vector2, velocity: Vector2, speed: float):
	Bullets.fire(bullet_scn, "bullet", "player", from, velocity, speed)

func fire_horizontal():
	fire($BulletSpawnPos.global_position, Vector2(-1, 0).rotated(deg2rad(rand_range(-5, 5))), 120)

func _on_gun_timer_timeout():
	if dying:
		return
	match shot_mode:
		"None": return
		"Horizontal": 
			fire($BulletSpawnPos.global_position, Vector2(-1, 0).rotated(deg2rad(rand_range(-5, 5))), 120)
			$gun_timer.start(mode_time())
		"Vertical": 
			$gun_timer.start(mode_time())
			fire($BulletSpawnPos.global_position, Vector2(-0.5, -1).normalized().rotated(deg2rad(rand_range(-15, 15))), 45)
			yield(wait(0.2), "timeout")
			fire($BulletSpawnPos.global_position, Vector2(-0.5, -0.25).normalized().rotated(deg2rad(rand_range(-15, 15))), 45)
			yield(wait(0.2), "timeout")
			fire($BulletSpawnPos.global_position, Vector2(-0.5, 0.25).normalized().rotated(deg2rad(rand_range(-15, 15))), 45)
			yield(wait(0.2), "timeout")
			fire($BulletSpawnPos.global_position, Vector2(-0.5, 1).normalized().rotated(deg2rad(rand_range(-15, 15))), 45)
		_: return -1
	
	
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
	emit_signal("dying")
	visible = false
	
	for seen in [false, true, false, true, false, true, false, true,]:
		yield(wait(0.05), "timeout")
		visible = seen
	yield(wait(0.25), "timeout")
	emit_signal("dead")
	queue_free()
	
func add_bullets_node(path: NodePath):
	bullets_parent = get_node(path)
	assert(bullets_parent, "Invalid path to bullets_parent:" + path.get_as_property_path())
