class_name AsyncSemaphore

var value: int = 0

func _init(done_times):
	value = done_times

signal done(value)
	
func enter():
	value += 1

func done(given=null):
	value -= 1
	if value <= 0:
		emit_signal("done", given)
