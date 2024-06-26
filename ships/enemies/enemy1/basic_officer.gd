class_name WindsorOfficerShip
extends KinematicBody2D

signal dying()
signal dead()
signal arrived()
signal on_hit(msg)

export(float) var speed = 70
export(Vector2) var velocity = Vector2(-1, 0)
export(String, "None", "Vertical", "Horizontal") var shot_mode = "None"
export(NodePath) var bullets_node: NodePath


onready var dead_tex = preload("res://ships/enemies/enemy1/enemy-1-death.png")
onready var bullet_scn = preload("res://ships/projectiles/bullet.tscn")

var hit_points = 90
var can_shoot = false
var dying = false

var target: Vector2

var direction = 1
var lerp_weight = 0.5

var SilverCord = AsyncSemaphore.new(0)

func mode_time():
	match shot_mode:
		"None": return -1
		"Vertical": return rand_range(1, 1.5)
		"Horizontal": return rand_range(2, 4)
		_: return -1

var base_modulate: Color

func _ready():
	base_modulate = $tex.modulate
	$warp_tex.visible = true
	$gun_timer.start(mode_time())
	warp_in()
	

func warp_in():
	SilverCord.enter()
	$anim.play("warp_in")
	yield($anim, "animation_finished")
	$warp_tex.queue_free()
	SilverCord.done()
	$gun_timer.start(5)
	
func wait(time: float):
	return get_tree().create_timer(time)
	
func _process(delta):
	var modulate_factor = 1 - (clamp(hit_points, 0, 90) / 90)
	var o = lerp(1, 0.5, modulate_factor)
	modulate = Color(base_modulate.r, base_modulate.g * o, base_modulate.b * o)

var arrived = false

func _physics_process(delta):
	# zig_zag(delta)
	if target:
		var dir = (target - position) 
		if dir.length() > speed/10:
			arrived = false
			var collision = move_and_collide(dir.normalized() * speed * delta, true)
			look_at(target)
			rotate(PI)
		else:
			look_at(position + Vector2(1, 0))
			if not arrived:
				arrived = true
				emit_signal("arrived")
	else:
		var collision = move_and_collide(velocity * speed * delta, true)
	# TODO: handle collision
	
func fire(from: Vector2, velocity: Vector2, speed: float):
	$snd.play("shoot")
	Bullets.fire(bullet_scn, "bullet", "player", from, velocity, speed)

func fire_horizontal():
	$snd.play("shoot")
	fire($BulletSpawnPos.global_position, Vector2(-1, 0).rotated(deg2rad(rand_range(-5, 5))), 120)
	
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
	async_free()

func async_free():
	if SilverCord.value == 0:
		queue_free()
	yield(SilverCord, "done")
	queue_free()

func _on_gun_timer_timeout():
	fire_horizontal()
	fire_horizontal()
	fire_horizontal()
	$gun_timer.start(rand_range(1, 4))
