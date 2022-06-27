#class_name 
extends KinematicBody2D
# Controller for the player ship.

# Signals


# Member variables
export(float) var speed: float
var velocity: Vector2


# onready variables


# Constants


# Enums


# Core functions
#func _init() -> void:


#func _ready() -> void:


#func _input(event) -> void:


#func _unhandled_input(event) -> void:


func _process(delta: float) -> void:
	velocity = Vector2()
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
	if Input.is_action_pressed('ui_down'):
		velocity.y += 1
	if Input.is_action_pressed('ui_up'):
		velocity.y -= 1
	velocity = velocity.normalized() * speed


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
			elif groups.has("bullet") and not groups.has("player"):
				# TODO: Add bullet collision to player ship
				return


# Getters/Setters


# Public functions


# Private functions
