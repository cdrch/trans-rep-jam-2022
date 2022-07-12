extends Node2D

export(float) var speed = 50
export(Vector2) var velocity = Vector2(-1, 0)

func _physics_process(delta):
	position += velocity * speed * delta

