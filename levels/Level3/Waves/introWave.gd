tool
extends Node2D

signal wave_complete()

onready var floater_scn = preload("res://ships/enemies/enemy1/basic_floater.tscn")
onready var eye_scn = preload("res://ships/enemies/enemy3/SpaceEyes.tscn")

var SilverCord = AsyncSemaphore.new(0)
var token = CancellationToken.new()

func _ready():
	if not Engine.editor_hint:
		$viewport_hint.queue_free()

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		token.cancel()

func run_wave():
	run_basic_wave()

func eye_arrived(eye: SpaceEye):
	eye.move_target = $EyeZone.point_in_zone()

func eye_attuned(eye: SpaceEye):
	var t = $DiveZoneExtents.point_in_zone()
	print("new target: ", t)
	eye.visual_target = t

func _process(_delta):
	pass
	 
func run_basic_wave():
	print("3-0")
	yield(T.wait(3), D.o)
	var points = $GruntFormationPoints/B1.get_children()
	var after_spawns = AsyncSemaphore.new(0)
	var after_deaths = AsyncSemaphore.new(0)
	var eye = spawn_eye($GruntFormationPoints/B1/C)
	
	after_deaths.enter()
	shot_timer(after_deaths)
	run_circuit(after_deaths, 40, eye)
	after_deaths.done()
	yield(after_deaths, "done")
	eye.warp_out()
	yield(eye, "left")
	
	emit_signal("wave_complete")

func build_floater(sem):
	var e = floater_scn.instance()
	sem.enter()
	$EnemyDump.add_child(e)
	e.shot_mode = "None"
	e.hit_points = 10
	e.speed = 200
	e.connect("dead", sem, "done")
	return e

var floaters = []

func bezerk(at, sem, tok):
	for i in 10:
		var e = build_floater(sem)
		floaters.push_back(weakref(e))
		e.global_position = $GruntFormationPoints/B1/C14.global_position
		floater_circuit(e)
		yield(T.wait(0.1, tok), D.o)
	floaters = D.clear_freed(floaters)
	for f in floaters:
		var q = f.get_ref()
		q.fire(q.global_position, $DiveZoneExtents.point_in_zone(), 100)

func run_circuit(sem, n_open_burst, eye):
	var tok = CancellationToken.new()
	sem.connect("done", tok, "cancel")
	eye.connect("player_found", self, "bezerk", [sem, tok])
	for i in n_open_burst:
		var e = build_floater(sem)
		floaters.push_back(weakref(e))
		e.global_position = $GruntFormationPoints/B1/C14.global_position
		floater_circuit(e)
		yield(T.wait(0.1, tok), D.o)
	
	while sem.value > 0:
		yield(T.wait(rand_range(3, 5), tok), D.o)
		if sem.value > 0:
			var e = build_floater(sem)
			floaters.push_back(weakref(e))
			e.global_position = $GruntFormationPoints/B1/C14.global_position
			floater_circuit(e)

func floater_circuit(floater):
	var ref = weakref(floater)
	var tok = floater.token
	
	var path = $GruntFormationPoints/B1.get_children()
	if rand_range(0, 1) > 0.5:
		path.invert()
	while ref.get_ref():
		for p in path:
			if ref.get_ref():
				floater.target = p.global_position + Vector2(rand_range(-5, 5), rand_range(-5, 5))
				yield(tok.on(floater, "arrived"), "done")
		

var enemies = []

func gavel_arrived(g):
	if not g.dying and not g.diving:
		g.target = rand_child($GruntFormationPoints/B1).global_position


func spawn_eye(at):
	var e = eye_scn.instance()
	$EnemyDump.add_child(e)
	e.global_position = at.global_position
	eye_arrived(e)
	eye_attuned(e)
	e.connect("arrived", self, "eye_arrived", [e])
	e.connect("attuned", self, "eye_attuned", [e])
	return e

func shot_timer(onDie):
	while onDie.value > 0:
		yield(T.wait(rand_range(3, 5)), D.o)
		enemies = D.clear_freed(enemies)
		if enemies.size() > 0:
			var e = enemies[randi() % enemies.size()]
			if e.get_ref():
				e.get_ref().fire_horizontal()

func return_point(pointMap: Array, t):
	pointMap.push_back(t)

func rand_child(node: Node2D) -> Node2D: 
	var children = node.get_children()
	return children[randi() % children.size()]
