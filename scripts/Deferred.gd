class_name Deferred

signal done(value)

var blocked = false

func block():
	blocked = true

func unblock():
	blocked = false

func done(value=null):
	if not blocked:
		emit_signal("done", value)
