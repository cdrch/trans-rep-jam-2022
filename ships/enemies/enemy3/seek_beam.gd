tool class_name SeekBeam
extends Polygon2D

signal found_player(player)

export (float, 0, 1000) var beam_length 

var up_extent_dir = Vector2(40, -3).normalized()
var down_extent_dir = Vector2(40, 3).normalized()

func _ready():
	pass

func _process(delta):
	polygon[1] = up_extent_dir * beam_length
	polygon[2] = down_extent_dir * beam_length

func check_location(point):
	beam_length = (global_position - point).length()
	global_rotation = global_position.angle_to_point(point)

func _physics_process(delta):
	$"%detector".polygon = polygon
	
func _on_light_area_area_entered(area):
	var hit = $"%raycast".get_collider() as Area2D
	if hit and "player" in hit.get_groups():
		emit_signal("found_player", hit)

func _on_light_area_body_entered(body):
	var ray = $"%raycast"
	ray.global_rotation = 0
	ray.cast_to = (body.global_position - ray.global_position) * 2
	ray.force_raycast_update()
	var hit = ray.get_collider() as KinematicBody2D
	print("HIT: ", hit, "| GROUPS: ", hit.get_groups())
	if hit != null and hit.get_groups().has("player"):
		print("XXDD")
		emit_signal("found_player", hit)
