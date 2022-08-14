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
	if sigable is Deferred and not done:
		var res = Deferred.new()
		sigable.connect("done", res, "done")
		results[sigable] = ["done", res, "done"]
		cleanup(sigable)
		return res
	if sigable is AsyncSemaphore and not done:
		var res = Deferred.new()
		sigable.connect("done", res, "done")
		results[sigable] = ["done", res, "done"]
		cleanup(sigable, "done")
		return res
	if not done:
		var res = Deferred.new()
		sigable.connect(_signal, res, "done")
		cleanup(sigable, _signal)
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
			if is_instance_valid(k):
				k.disconnect(r[0], r[1], r[2])
		results.clear()
		emit_signal("cancelled")

func _protec(_value):
	pass
