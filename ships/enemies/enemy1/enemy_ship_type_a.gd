class_name WindsorShip
extends KinematicBody2D

signal arrived()
signal dying()
signal dead()
signal tick()

export(float) var speed = 50.0
export(Vector2) var velocity = Vector2(-1, 0)
export(String, "None", "Vertical", "Horizontal") var shot_mode = "None"
export(Texture) var dead_tex

# onready var dead_tex = preload("res://ships/enemies/enemy1/enemy-1-death.png")
onready var bullet_scn = preload("res://ships/projectiles/bullet.tscn")
onready var pellet_scn = preload("res://ships/projectiles/pellet.tscn")

var hit_points = null setget set_hp
var can_shoot = false
var dying = false

var target

var direction = 1
var lerp_weight = 0.5

var SilverCord = AsyncSemaphore.new(0)
var token = CancellationToken.new()

func mode_time():
	match shot_mode:
		"None": return -1
		"Vertical": return rand_range(1, 1.5)
		"Horizontal": return rand_range(2, 4)
		_: return -1

var base_hp
func set_hp(value):
	hit_points = value
	if base_hp == null:
		base_hp = value
	var modulate_factor = 1 - (clamp(hit_points, 0, base_hp) / base_hp)
	var o = lerp(1, 0.5, modulate_factor)
	modulate = Color(1, o, o)
	

func _ready():
	$tex.modulate = Color(1,1,1,0)
	$warp_tex.visible = true
	$gun_timer.start(mode_time())
	warp_in()
	
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		token.cancel()

func warp_in():
	SilverCord.enter()
	$anim.play("warp_in")
	yield($anim, "animation_finished")
	$warp_tex.queue_free()
	SilverCord.done()
	
func wait(time: float):
	return T.wait(time)

var arrived = false
func _physics_process(delta):
	var target_pos
	if is_instance_valid(target) and target is Node2D:
		target_pos = target.global_position
	elif target is Vector2:
		target_pos = target
	# zig_zag(delta)
	if target_pos:
		var dir = (target_pos - position) 
		if dir.length() > speed/10:
			arrived = false
			var _collision = move_and_collide(dir.normalized() * speed * delta, true)
			look_at(target_pos)
			rotate(PI)
		else:
			emit_signal("arrived")
			look_after(position)
	else:
		var _collision = move_and_collide(velocity * speed * delta, true)
	emit_signal("tick")
	# TODO: handle collision
func look_after(at):
	yield(self, "tick")
	yield(self, "tick")
	if position == at:
		look_at(position + Vector2(1, 0))
	
func fire(from: Vector2, direction: Vector2, speed: float):
	$snd.play("shoot")
	Bullets.fire(bullet_scn, "bullet", "player", from, direction, speed)

func fire_pellet_horizontal(from: Vector2, direction: Vector2, speed: float):
	$snd.play("shoot")
	Bullets.fire(pellet_scn, "bullet", "player", from, direction, speed)

func fire_horizontal():
	$snd.play("shoot")
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
			yield(wait(0.2), D.o)
			fire($BulletSpawnPos.global_position, Vector2(-0.5, -0.25).normalized().rotated(deg2rad(rand_range(-15, 15))), 45)
			yield(wait(0.2), D.o)
			fire($BulletSpawnPos.global_position, Vector2(-0.5, 0.25).normalized().rotated(deg2rad(rand_range(-15, 15))), 45)
			yield(wait(0.2), D.o)
			fire($BulletSpawnPos.global_position, Vector2(-0.5, 1).normalized().rotated(deg2rad(rand_range(-15, 15))), 45)
		_: return -1
	
	
func hurt(_type, damage):
	if dying:
		return
	set_hp(hit_points - damage)
	if hit_points <= 0:
		die()

func die():
	set_hp(0)
	$tex.texture = dead_tex
	# Disable collision
	collision_layer = 0
	collision_mask = 0
	dying = true
	emit_signal("dying")
	visible = false
	
	for seen in [false, true, false, true, false, true, false, true,]:
		yield(wait(0.05), D.o)
		visible = seen
	yield(wait(0.25), D.o)
	emit_signal("dead")
	async_free()

func async_free():
	if SilverCord.value == 0:
		queue_free()
	yield(SilverCord, "done")
	queue_free()
