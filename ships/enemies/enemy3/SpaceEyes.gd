class_name SpaceEye
extends KinematicBody2D

signal attuned()
signal arrived()
signal rot_mode(mode)

var up_extent_dir
var down_extent_dir

var rot_speed_degs = 15
var speed = 50

var move_target: Vector2 setget set_move_target
var visual_target: Vector2 setget set_visual_target

var arrived: bool = false
var attuned: bool = false

func set_move_target(val):
	move_target = val
	arrived = false

func set_visual_target(val):
	visual_target = val
	attuned = false
	
func _ready():
	move_target = position
	visual_target = Vector2(-10, 0)
	$"%seek_beam".visible = false
	$"%seek_beam".beam_length = 0
	$"%seek_beam".connect("found_player", self, "_on_found_player")

func _on_found_player(p):
	print(p)
	emit_signal("rot_mode", "FOUND PLAYER")

var checking = false
func check_location():
	checking = true
	$seek_beam.show()
	$anim.play("eye_open", -1, 0.25)
	#$"%seek_beam".check_location(global_position + Vector2(1, 0).rotated(global_rotation) * 1000)
	yield($anim, "animation_finished")
	$anim.play("eye_close", -1, 0.25)
	yield($anim, "animation_finished")
	$"%seek_beam".beam_length = 0
	emit_signal("arrived")
	emit_signal("attuned")
	checking = false

func _process(delta):
	if attuned and arrived and not checking:
		check_location()

func _physics_process(delta):
	var dir = move_target - global_position
	var move = dir.normalized() * speed * delta
	if dir.length() > move.length():
		dir.normalized()
		move_and_collide(dir.normalized() * speed * delta)
	elif dir.length() < move.length():
		move_and_collide(dir)
		if not arrived:
			arrived = true
		
	var look = visual_target - global_position
	var rel_angle = look.angle() - global_rotation
	var turn = -sign(rel_angle) * deg2rad(rot_speed_degs) * delta
	if abs(rel_angle) > PI:
		turn *= -1
	if abs(rel_angle) > abs(turn):
		global_rotation -= turn
	elif abs(rel_angle) <= abs(turn):
		# emit_signal("rot_mode", "attuned: " + str(turn))
		global_rotation += rel_angle
		if not attuned:
			attuned = true
	else:
		emit_signal("rot_mode", "ERROR")
