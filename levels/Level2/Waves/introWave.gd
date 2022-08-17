tool
extends Node2D

signal wave_complete()

onready var floater_scn = preload("res://ships/enemies/enemy1/basic_floater.tscn")
onready var gavel_scn = preload("res://ships/enemies/enemy2/Gavel.tscn")

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
	print("2-0")
	yield(T.wait(3), D.o)
	var points = $GruntFormationPoints/B1.get_children()
	var after_spawns = AsyncSemaphore.new(0)
	var after_deaths = AsyncSemaphore.new(0)
	after_deaths.enter()
	shot_timer(after_deaths)
	run_circuit(after_deaths, 20)
	yield(T.wait(3, token), D.o)
	spawn_gavel($Spawners/C, after_deaths)
	yield(T.wait(3, token), D.o)
	spawn_gavel($Spawners/C, after_deaths)
	after_deaths.done()
	yield(after_deaths, "done")
	
	emit_signal("wave_complete")

func build_floater(sem):
	var e = floater_scn.instance()
	$EnemyDump.add_child(e)
	e.shot_mode = "None"
	e.hit_points = 10
	e.speed = 200
	sem.connect("done", e, "die")
	return e

func run_circuit(sem, n_open_burst):
	var tok = CancellationToken.new()
	sem.connect("done", tok, "cancel")
	for i in n_open_burst:
		var e = build_floater(sem)
		e.global_position = $track4.point_in_zone()
		floater_circuit(e)
		yield(T.wait(0.1, tok), D.o)
	
	while sem.value > 0:
		yield(T.wait(rand_range(0.1, 0.5), tok), D.o)
		var e = build_floater(sem)
		e.global_position = $track4.point_in_zone()
		floater_circuit(e)

func floater_circuit(floater):
	var ref = weakref(floater)
	var tok = floater.token
	while ref.get_ref():
		floater.target = $track1.point_in_zone()
		yield(tok.on(floater, "arrived"), "done")
		floater.target = $track2.point_in_zone()
		yield(tok.on(floater, "arrived"), "done")
		floater.target = $track3.point_in_zone()
		yield(tok.on(floater, "arrived"), "done")
		floater.target = $track4.point_in_zone()
		yield(tok.on(floater, "arrived"), "done")


var enemies = []

func gavel_arrived(g):
	if not g.dying and not g.diving:
		g.target = rand_child($GruntFormationPoints/B1).global_position

func gavel_dive(g):
	SilverCord.enter()
	var ref = weakref(g)
	yield(T.wait(rand_range(3, 5)), D.o)
	while ref.get_ref() and not g.dying:
		g.diving = true
		g.target = $DiveZoneExtents.point_in_zone()
		yield(g, "arrived")
		g.diving = false
		g.target = rand_child($GruntFormationPoints/B1).global_position
		yield(T.wait(rand_range(5,10)), D.o)
	SilverCord.done()

func gavel_shot(g: GavelShip):
	SilverCord.enter()
	var ref = weakref(g)
	yield(T.wait(rand_range(3, 5), g.token), D.o)
	while ref.get_ref() and not g.dying:
		var dir = g.global_position.direction_to(Globals.Ship.global_position)
		var off = dir.rotated(PI/2) * 6
		g.shoot()
		g.fire(g.global_position + off, dir, 200)
		g.fire(g.global_position - off, dir, 200)
		
		yield(T.wait(rand_range(3, 5), g.token), D.o)
		
	SilverCord.done()
	

func spawn_gavel(at, onDie):
	var g = gavel_scn.instance()
	onDie.enter()
	$EnemyDump.add_child(g)
	g.global_position = at.global_position
	g.target = rand_child($GruntFormationPoints/B1).global_position
	g.connect("arrived", self, "gavel_arrived", [g])
	g.connect("dead", onDie, "done")
	gavel_dive(g)
	gavel_shot(g)
	return g

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
