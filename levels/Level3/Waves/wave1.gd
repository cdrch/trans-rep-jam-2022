tool
extends Node2D

signal wave_complete()

onready var enemy_scn = preload("res://ships/enemies/enemy1/basic_enemy.tscn")
onready var gavel_scn = preload("res://ships/enemies/enemy2/Gavel.tscn")
onready var eye_scn = preload("res://ships/enemies/enemy3/SpaceEyes.tscn")

var SilverCord = AsyncSemaphore.new(0)

func _ready():
	if not Engine.editor_hint:
		$viewport_hint.queue_free()

func run_wave():
	run_basic_wave()




func bezerk(at, onDie):
	enemies = D.clear_freed(enemies)
	for f in enemies:
		var q = f.get_ref()
		if q is GavelShip:
			print("YO")
			for i in 3:
				var pt = $Zones/DiveZone.point_in_zone()
				var dir = q.global_position.direction_to(pt)
				var off = dir.rotated(PI/2) * 6
				q.fire(q.global_position + off, dir, 200)
				q.fire(q.global_position - off, dir, 200)
				
				q.fire(q.global_position + off + dir*12, dir, 200)
				q.fire(q.global_position - off + dir*12, dir, 200)
		else:
			q.fire(q.global_position, $Zones/DiveZone.point_in_zone(), 100)

func run_basic_wave():
	print("3-1")
	yield(T.wait(3), D.o)
	var points = $GruntFormationPoints/B1.get_children()
	var after_spawns = AsyncSemaphore.new(0)
	var after_deaths = AsyncSemaphore.new(0)
	
	for p in points:
		spawn_basic(p, after_spawns, after_deaths, points)
	var e = spawn_eye($GruntFormationPoints/C)
	e.connect("player_found", self, "bezerk", [after_deaths])
	var e2 = spawn_eye($GruntFormationPoints/C)
	e2.connect("player_found", self, "bezerk", [after_deaths])
	yield(T.wait(4), D.o)
	spawn_gavel(rand_child($GruntFormationPoints/C), after_deaths)
	spawn_gavel(rand_child($GruntFormationPoints/C), after_deaths)
	
	yield(after_deaths, "done")
	e.warp_out()
	e2.warp_out()
	yield(e, "left")
	
	emit_signal("wave_complete")

func spawn_eye(at):
	var e = eye_scn.instance()
	$EnemyDump.add_child(e)
	e.global_position = at.global_position
	eye_arrived(e)
	eye_attuned(e)
	e.connect("arrived", self, "eye_arrived", [e])
	e.connect("attuned", self, "eye_attuned", [e])
	return e

func eye_arrived(eye: SpaceEye):
	eye.move_target = $Zones/EyeZone.point_in_zone()

func eye_attuned(eye: SpaceEye):
	var t = $Zones/DiveZone.point_in_zone()
	print("new target: ", t)
	eye.visual_target = t

func spawn_background(bosses: AsyncSemaphore, points: Array):
	var after_spawns = AsyncSemaphore.new(0)
	var after_deaths = AsyncSemaphore.new(0)
	while bosses.value > 0:
		yield(T.wait(rand_range(1, 3)), D.o)
		if points.size() > 0:
			var pt = points.pop_at(randi() % points.size())
			spawn_basic(pt, after_spawns, after_deaths, points)
	
	yield(after_deaths, "done")

var enemies = []

func gavel_arrived(g):
	if not g.dying and not g.diving:
		g.target = rand_child($GruntFormationPoints/B1).global_position

func gavel_dive(g):
	SilverCord.enter()
	var tok = CancellationToken.new()
	var ref = weakref(g)
	yield(T.wait(rand_range(3, 5)), D.o)
	while ref.get_ref() and not g.dying:
		g.target = $Zones/TopZone.point_in_zone()
		yield(tok.on(g, "arrived"), "done")
		g.target = $Zones/BottomZone.point_in_zone()
		yield(tok.on(g, "arrived"), "done")
	SilverCord.done()

func gavel_shot(g: GavelShip):
	SilverCord.enter()
	var ref = weakref(g)
	yield(T.wait(rand_range(1, 2)), D.o)
	while ref.get_ref() and not g.dying:
		var dir = g.global_position.direction_to(Globals.Ship.global_position)
		var off = dir.rotated(PI/2) * 6
		g.fire(g.global_position + off, dir, 200)
		g.fire(g.global_position - off, dir, 200)
		g.shoot()
		g.fire(g.global_position + off + dir*12, dir, 200)
		g.fire(g.global_position - off + dir*12, dir, 200)
		
		yield(T.wait(rand_range(1, 2)), D.o)
		
	SilverCord.done()
	

func spawn_gavel(at, onDie):
	var g = gavel_scn.instance()
	onDie.enter()
	enemies.push_back(weakref(g))
	$EnemyDump.add_child(g)
	g.global_position = at.global_position
	g.target = rand_child($GruntFormationPoints/B1).global_position
	g.connect("arrived", self, "gavel_arrived", [g])
	g.connect("dead", onDie, "done")
	gavel_dive(g)
	gavel_shot(g)

func shot_timer(onDie):
	while onDie.value > 0:
		yield(T.wait(rand_range(3, 5)), D.o)
		enemies = D.clear_freed(enemies)
		if enemies.size() > 0:
			var e = enemies[randi() % enemies.size()]
			if e.get_ref():
				e.get_ref().fire_horizontal()

func spawn_basic(
	target: Node2D, 
	onSpawn: AsyncSemaphore, 
	onDie: AsyncSemaphore,
	pointMap: Array
	):
	onDie.enter()
	onSpawn.enter()
	yield(T.wait(rand_range(0, 5)), D.o)
	var e = enemy_scn.instance()
	e.hit_points = 30
	enemies.push_back(weakref(e))
	$EnemyDump.add_child(e)
	e.shot_mode = "None"
	var start = rand_child($Spawners)
	e.global_position = start.global_position
	e.target = target.global_position
	e.connect("dead", onDie, "done")
	e.connect("dying", self, "return_point", [pointMap, target])
	onSpawn.done()

func return_point(pointMap: Array, t):
	pointMap.push_back(t)

func rand_child(node: Node2D) -> Node2D: 
	var children = node.get_children()
	return children[randi() % children.size()]
