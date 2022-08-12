class_name AsyncSemaphore
extends Node
var value: int = 0

func _init(done_times):
	value = done_times

signal done()
	
func enter():
	value += 1

func done():
	value -= 1
	if value <= 0:
		emit_signal("done")

func await():
	if value <= 0:
		yield(get_tree(), "idle_frame")
	else:
		yield(self, "done")
