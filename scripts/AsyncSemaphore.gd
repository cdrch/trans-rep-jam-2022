class_name AsyncSemaphore

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
		return
	yield(self, "done")
