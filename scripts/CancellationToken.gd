extends Object

var done = false setget _protec

signal cancelled()

func cancel():
	if not done:
		done = true
		emit_signal("cancelled")

func _protec(value):
	pass
