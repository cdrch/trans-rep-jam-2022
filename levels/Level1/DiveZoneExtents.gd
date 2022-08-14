tool
class_name RectZone
extends Node2D
# This is generally expected to be merged into scenes, since I don't know 
# how to expose the TopLeft/BottomRight as gizmos without doing that.

export(Vector2) onready var TopLeft = $TopLeft.position
export(Vector2) onready var BottomRight = $BottomRight.position

var diveZoneRect: Rect2

func _editor_process():
	var pos = $TopLeft.position
	var size = $BottomRight.position - pos
	var rect = Rect2(pos, size)
	if diveZoneRect == null:
		diveZoneRect = Rect2(pos, size)
		update()
	if not diveZoneRect.is_equal_approx(rect):
		diveZoneRect = rect
		update()

func _editor_draw():
	draw_rect(diveZoneRect, Color.aquamarine * Color(1, 1, 1, 0.3), true)
	
func _process(_delta):
	TopLeft = $TopLeft.position
	BottomRight = $BottomRight.position
	
	if Engine.editor_hint:
		_editor_process()

func point_in_zone():
	return global_position + Vector2(rand_range(TopLeft.x, BottomRight.x), rand_range(TopLeft.y, BottomRight.y))
		
func _draw():
	if Engine.editor_hint:
		_editor_draw()
