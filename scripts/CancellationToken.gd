class_name CancellationToken 
extends Object

var done = false setget _protec

signal cancelled()

var results = Dictionary()

func on(sigable, _signal="completed"):
	if sigable is GDScriptFunctionState and not done:
		var res = Deferred.new()
		sigable.connect("completed", res, "done")
		results[sigable] = ["completed", res, "done"]
		cleanup(sigable)
		return res
	if not done:
		var res = Deferred.new()
		sigable.connect(_signal, res, "done")
		cleanup(sigable)
		results[sigable] = [_signal, res, "done"]
		return res

func cleanup(sigable, _signal="completed"):
	yield(sigable, _signal)
	results.erase(sigable)
		

func cancel():
	if not done:
		done = true
		for k in results.keys():
			var r = results[k]
			k.disconnect(r[0], r[1], r[2])
		results.clear()
		emit_signal("cancelled")

func _protec(value):
	pass
