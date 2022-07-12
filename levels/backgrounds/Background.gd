tool
class_name Starfield
extends Node2D
# Script description goes here

export(float) var width = 640 setget set_width
export(float) var height = 320 setget set_height

func set_width(new_width: float):
	width = new_width
	_scatter_points()
	
func set_height(new_height: float):
	height = new_height
	_scatter_points()

var colors: PoolColorArray
var points: PoolVector2Array
var enabled: PoolByteArray
var pool_size = 500
var offset = Vector2(0, 0)


func point_in_screen():
	# TODO: Pluck these off 
	return Vector2(rand_range(-(width/2), (width/2)), rand_range(-(height/2), (height/2)))

func color_rand():
	return Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1))
	
func _scatter_points():
	for i in range(1, pool_size):
		points[i] = point_in_screen()
		colors[i] = color_rand()
		enabled[i] = 1

func _init():
	points = PoolVector2Array()
	points.resize(pool_size);
	colors = PoolColorArray()
	colors.resize(pool_size);
	enabled = PoolByteArray()
	enabled.resize(pool_size);
	_scatter_points()

func _process(delta):
	$Position2D.position = Vector2(width/2, -(height/2))
	
	offset += Vector2(-20 * delta, 0)
	for i in pool_size:
		if (offset.x + points[i].x) < -(width/2):
			points[i].x += width
			points[i].y = rand_range(-(height/2), (height/2))
			colors[i] = color_rand()
	update()
	

func _draw():
	var rr = Rect2(points[0], Vector2(1,1))
	draw_rect(Rect2(-(width/2), -(height/2), width, height), Color.black, true)
	for i in pool_size:
		rr.position = points[i] + offset
		draw_rect(rr, colors[i], true)
