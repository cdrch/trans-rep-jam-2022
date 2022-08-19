class_name PlayerShip

extends KinematicBody2D
# Controller for the player ship.

# Signals
signal velocity_changed(velocity)
signal physics_tick()

onready var ded_tex = preload("res://ships/ded.png")

var alive = true
var speed: float = 180
var velocity_override = null
var velocity: Vector2
var gun_equipped: bool = false setget set_gun_equipped

var BlockQuit = AsyncSemaphore.new(0)

func set_gun_equipped(value):
	print("Gun Equipped: ", value)
	$Gunpoint.equipped = value

var particles_amount 

func _ready() -> void:
	$Button.hide()
	# Slightly awkard on account of wanting to be editor-friendly
	particles_amount = $particles.amount

func _process(delta: float) -> void:
	velocity = Vector2()
	if not alive and Input.is_action_just_pressed("fire"):
		get_tree().change_scene("res://levels/main_menu.tscn")
		return 
	if not alive:
		return
	
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
	if Input.is_action_pressed('ui_down'):
		velocity.y += 1
	if Input.is_action_pressed('ui_up'):
		velocity.y -= 1
	
	if velocity_override == null:
		velocity = velocity.normalized() * speed
	else:
		velocity = velocity_override.normalized() * speed
	
	if velocity.x > 0:
		$particles3.emitting = false
		$particles2.emitting = true
		emit_signal("velocity_changed", "forward")
	elif velocity.x < 0:
		$particles3.emitting = false
		$particles2.emitting = false
		$particles.emitting = false
		emit_signal("velocity_changed", "backward")
	else:
		$particles3.emitting = false
		$particles2.emitting = false
		$particles.emitting = true
		emit_signal("velocity_changed", "static")
	
var hurt = false
var invuln = false

func do_invuln(sem: AsyncSemaphore):
	BlockQuit.enter()
	invuln = true
	modulate = Color(0.6, 0.6, 0.6, 0.5)
	yield(T.wait(0.5), D.o)
	invuln = false
	sem.done()
	BlockQuit.done()

var hurt_tween

func do_hurt(afterInvuln: AsyncSemaphore):
	BlockQuit.enter()
	hurt = true
	yield(afterInvuln, "done")
	modulate = Color(1, 0.3, 0.3, 1)
	hurt_tween = get_tree().create_tween()
	hurt_tween.tween_property(self, "modulate", Color(1,0.7,0.7), 9.5)
	yield(T.wait(9.5), D.o)
	modulate = Color(1,1,1)
	hurt = false
	BlockQuit.done()

func hurt(type, amount):
	if not alive or invuln:
		return
	if hurt:
		die()
	else:
		var sem = AsyncSemaphore.new(0)
		sem.enter()
		do_hurt(sem)
		do_invuln(sem)

func die():
	if hurt_tween != null:
		hurt_tween.stop()
	$Button.show()
	alive = false
	collision_mask = 0
	collision_layer = 0
	modulate = Color(1,1,1)
	$Gunpoint.equipped = false
	$particles.emitting = false
	$particles2.emitting = false
	$particles3.emitting = false
	$Sprite.texture = ded_tex
	position = Vector2(0, 0)

func async_free():
	yield(BlockQuit.await(), D.o)
	queue_free()

func _physics_process(delta: float) -> void:
	var collision = move_and_slide(velocity, Vector2(0,0))
	#if collision:
	#	if not collision.collider is Node:
#			velocity = velocity.slide(collision.normal)
	#		return
	#	else:
#			var collision_node: Node = collision.collider
	#		var groups = collision_node.get_groups()
	#		if groups.has("solid"):
	#			velocity = velocity.slide(collision.normal)
	#			return


func _on_Button_pressed():
	if not alive:
		get_tree().change_scene("res://levels/main_menu.tscn")
