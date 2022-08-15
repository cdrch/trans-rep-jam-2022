extends Node

func wait(time :float, token: CancellationToken = null):
	var t = get_tree().create_timer(time, false)
	if token != null:
		yield(token.on(t, "timeout"), "done")
	else:
		yield(t, "timeout")
	

