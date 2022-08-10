class_name GavelShip
extends KinematicBody2D

signal arrived()
signal dead()
signal dying()

export(float) var speed = 50
export(Vector2) var velocity = Vector2(-1, 0)
export(String, "None", "Vertical", "Horizontal") var shot_mode = "None"
export(bool) var warped = false

onready var dead_tex = preload("res://ships/enemies/enemy2/sprite7.png")
onready var pellet_scn = preload("res://ships/projectiles/pellet.tscn")

var diving = false
var hit_points = 180.0
var can_shoot = false
var dying = false

var target: Vector2
var SilverCord = AsyncSemaphore.new(0)

func mode_time():
	match shot_mode:
		"None": return -1
		"Vertical": return rand_range(1, 1.5)
		"Horizontal": return rand_range(2, 4)
		_: return -1

func _ready():
	warp_in()

func wait(time: float):
	return get_tree().create_timer(time)
	
func _process(delta):
	var modulate_factor = 1 - (clamp(hit_points, 0, 30) / 30)
	var o = lerp(1, 0.5, modulate_factor)
	modulate = Color(1, o, o)

var arrived = false

func warp_in():
	SilverCord.enter()
	$anim.play("warp_in")
	yield($anim, "animation_finished")
	$warp_tex.queue_free()
	SilverCord.done()

func _physics_process(delta):
	var nu_speed = speed
	if diving:
		nu_speed *= 4
	
	if target:
		var dir = (target - position)
		if dir.length() > nu_speed/10:
			arrived = false
			var collision = move_and_collide(dir.normalized() * nu_speed * delta, true)
			if warped:
				if not diving:
					$anim.play("moving")
				else:
					$anim.play("Dive")
			look_at(target)
			rotate(PI)
		else:
			if not arrived:
				arrived = true
				emit_signal("arrived")
			look_at(position + Vector2(1, 0))
			$anim.play("RESET")
	else:
		var collision = move_and_collide(velocity * speed * delta, true)
	# TODO: handle collision
	
func fire(from: Vector2, velocity: Vector2, speed: float):
	Bullets.fire(pellet_scn, "bullet", "player", from, velocity, speed)

func _on_gun_timer_timeout():
	if dying:
		return
	
func hurt(type, damage):
	if dying:
		return
	if diving:
		damage = damage / 10.0
	hit_points -= damage
	if hit_points <= 0:
		die()
		
func async_free():
	if SilverCord.value == 0:
		queue_free()
	yield(SilverCord, "done")
	queue_free()

func die():
	emit_signal("dying")
	$tex.texture = dead_tex
	# Disable collision
	collision_layer = 0
	collision_mask = 0
	dying = true
	visible = false
	
	for seen in [false, true, false, true, false, true, false, true,]:
		yield(T.wait(0.05), D.o)
		visible = seen
	yield(T.wait(0.25), D.o)
	emit_signal("dead")
	async_free()


