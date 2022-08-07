extends Node

const o = "completed"

static func clear_freed(arr):
	var alive = []
	for e in arr:
		if e.get_ref() and not e.get_ref().dying:
			alive.push_back(e)
	return alive
