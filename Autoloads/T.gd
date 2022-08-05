extends Node

func wait(time :float):
	var t = get_tree().create_timer(time)
	yield(t, "timeout")

