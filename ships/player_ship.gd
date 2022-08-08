class_name PlayerShip

extends KinematicBody2D
# Controller for the player ship.

# Signals
signal velocity_changed(velocity)

# Member variables
export(NodePath) var bullets_node: NodePath

onready var ded_tex = preload("res://ships/ded.png")

var alive = true
var speed: float = 180
var velocity: Vector2

var particles_amount 

func _ready() -> void:
	# Slightly awkard on account of wanting to be editor-friendly
	$Gunpoint.bullets_node = $Gunpoint.get_path_to(get_node(bullets_node))
	particles_amount = $particles.amount

func _process(delta: float) -> void:
	velocity = Vector2()
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
	
	velocity = velocity.normalized() * speed
	
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
	

func hurt(type, amount):
	if not alive:
		return
	alive = false
	collision_mask = 0
	collision_layer = 0
	$Gunpoint.equipped = false
	$particles.emitting = false
	$particles2.emitting = false
	$particles3.emitting = false
	$Sprite.texture = ded_tex
	position = Vector2(0, 0)

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		if not collision.collider is Node:
			velocity = velocity.slide(collision.normal)
			return
		else:
			var collision_node: Node = collision.collider
			var groups = collision_node.get_groups()
			if groups.has("solid"):
				velocity = velocity.slide(collision.normal)
				return
