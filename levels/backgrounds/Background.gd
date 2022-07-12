tool
class_name Starfield
extends Node2D
# Script description goes here

# Signals

var colors: PoolColorArray
var points: PoolVector2Array
var enabled: PoolByteArray
var pool_size = 1000
var offset = Vector2(0, 0)

func point_in_screen():
	# TODO: Pluck these off 
	return Vector2(rand_range(-360, 360), rand_range(-200, 200))

func color_rand():
	return Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1))

func _ready():
	points = PoolVector2Array()
	points.resize(pool_size);
	colors = PoolColorArray()
	colors.resize(pool_size);
	enabled = PoolByteArray()
	enabled.resize(pool_size);
	
	for i in range(1, pool_size):
		points[i] = point_in_screen()
		colors[i] = color_rand()
		enabled[i] = 1

func _process(delta):
	offset += Vector2(-20 * delta, 0)
	for i in pool_size:
		if (offset.x + points[i].x) < -360:
			points[i].x += 360*2
			points[i].y = rand_range(-180, 180)
			colors[i] = color_rand()
	update()
	

func _draw():
	var rr = Rect2(points[0], Vector2(1,1))
	draw_rect(Rect2(-340, -180, 680, 360), Color.black, true)
	for i in pool_size:
		rr.position = points[i] + offset
		draw_rect(rr, colors[i], true)
		#draw_line(points[i] + offset, points[i] + offset + Vector2(1, 1) , colors[i], 1)
		#draw_circle(points[i] + offset, 1, colors[i])

# Member variables


# onready variables


# Constants


# Enums


# Core functions
#func _init():


#func _ready():


#func _input(event):


#func _unhandled_input(event):


#func _process(delta):


#func _physics_process(delta):


# Getters/Setters


# Public functions


# Private functions
