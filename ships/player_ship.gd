class_name PlayerShip

extends KinematicBody2D
# Controller for the player ship.

# Signals


# Member variables
export(NodePath) var bullets_node: NodePath

var speed: float = 180
var velocity: Vector2

# onready variables


# Constants


# Enums


# Core functions
#func _init() -> void:


func _ready() -> void:
	# Slighly awkard on account of wanting to be editor-friendly
	$Gunpoint.bullets_node = $Gunpoint.get_path_to(get_node(bullets_node))

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


# Getters/Setters


# Public functions


# Private functions
