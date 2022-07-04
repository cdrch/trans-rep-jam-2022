extends Node2D

export(String, "player", "enemy") var target_group: String
export(float) var reload_time: float = 0.4
export(NodePath) var bullets_node: NodePath setget add_bullets_node

onready var time = $Timer
onready var bullet = preload("res://ships/projectiles/bullet.tscn")
var bullets_parent: Node
var chambered = true

func _process(delta: float):
	if Input.is_action_pressed("fire") and chambered and bullets_parent:
		chambered = false
		time.start(reload_time)
		var b = bullet.instance()
		b.target_group = "enemy"
		b.damage_type = "bullet"
		b.velocity = Vector2(1, 0)
		bullets_parent.add_child(b)
		b.global_position = global_position

func add_bullets_node(path: NodePath):
	bullets_parent = get_node(path)
	assert(bullets_parent, "Invalid path to bullets_parent:" + path.get_as_property_path())

func _on_chambered():
	chambered = true
