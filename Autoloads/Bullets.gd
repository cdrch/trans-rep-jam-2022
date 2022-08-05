extends Node

var bullets_parent: Node2D

func fire(scene: PackedScene, damage_type: String, target: String, from_global: Vector2, direction: Vector2, speed: float):
	var b = scene.instance()
	b.speed = speed
	b.target_group = target
	b.damage_type = damage_type
	b.velocity = direction.normalized()
	bullets_parent.add_child(b)
	b.global_position = from_global
	b.rotation = direction.angle()
