extends Area2D

export(float) var speed: float = 400
export(String, "player", "enemy") var target_group: String
export(String, "bullet", "laser", "explosion") var damage_type = "bullet"
export(float) var damage: float = 10
export(Vector2) var velocity = Vector2(1, 0)
var spent: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	position += velocity * delta * speed

func on_collide(other: CollisionObject2D):
	if spent:
		return
		
	var groups = other.get_groups()
	if groups.has("sweep") or groups.has("shield"):
		queue_free()
		spent = true
	if groups.has(target_group):
		other.call_deferred("hurt", damage_type, damage)
		spent = true
		queue_free()

func _on_Area2D_area_entered(area):
	on_collide(area)

func _on_Area2D_body_entered(body):
	on_collide(body)
	


func _on_Timer_timeout():
	spent = true
	queue_free()
