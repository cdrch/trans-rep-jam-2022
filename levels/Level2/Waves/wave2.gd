tool
class_name Level2Wave2
extends Node2D

signal wave_complete()

onready var floater = preload("res://ships/enemies/enemy1/basic_floater.tscn")
onready var carrier = preload("res://ships/enemies/enemy2/Carrier.tscn")
onready var shield_layout = preload("res://ships/enemies/enemy2/layout.tscn")

var tok = CancellationToken.new()

func _ready():
	if not Engine.editor_hint:
		$viewport_hint.queue_free()
		connect("wave_complete", tok, "cancel")

var enemies = []

func shot_timer(onDie):
	if onDie.value > 0:
		enemies = D.clear_freed(enemies)
		if enemies.size() > 0:
			var e = enemies[randi() % enemies.size()]
			e.get_ref().fire_horizontal()
		$shot_timer.start(rand_range(1, 3))

var boss_list = []
func _process(delta):
	$Debug.text = ""
	for b in boss_list:
		if b.get_ref():
			$Debug.text += "HP: %d" % max(b.get_ref().hit_points, 0)
		
func run_wave():
	run_officer_wave($GruntFormationPoints/C, boss_list)
	
func run_officer_wave(from, officer_list):
	print("2-2")
	var spawns = from.get_children()
	
	yield(T.wait(0.5), D.o)
	var officer: GavelShip = spawn_carrier(from, from)
	officer.hit_points = 250
	var shield = shield_layout.instance()
	officer.add_child(shield)
	officer_list.push_back(weakref(officer))
	for i in 5:
		for s in spawns:
			yield(T.wait(0.2, officer.token), D.o)
			var path = shield.get_children()
			path.shuffle()
			spawn_minion(s, from, officer, path)
	yield(officer, "dead")
	emit_signal("wave_complete")

func spawn_carrier(target: Node2D, start) -> GavelShip:
	var e = carrier.instance()
	$EnemyDump.add_child(e)
	e.shot_mode = "None"
	e.global_position = start.global_position
	e.target = target.global_position
	move_carrier(e)
	carrier_shoot(e)
	return e

func carrier_shoot(g: GavelShip):
	var ref = weakref(g)
	yield(T.wait(rand_range(1, 2)), D.o)
	var cnt = 0
	while ref.get_ref() and not g.dying:
		var dir = g.global_position.direction_to(Globals.Ship.global_position)
		var off = dir.rotated(PI/2) * 6
		g.fire(g.global_position + off, dir.rotated(deg2rad(3)), 200)
		g.fire(g.global_position - off, dir.rotated(deg2rad(-3)), 200)
		g.fire(g.global_position + off + dir*12, dir, 200)
		g.fire(g.global_position - off + dir*12, dir, 200)
		
		yield(T.wait(rand_range(0.5, 1)), D.o)
		cnt += 1
		if cnt >= 3:
			cnt = 0
			yield(T.wait(3, tok), D.o)
			
		

func move_carrier(carrier):
	var ref = weakref(carrier)
	
	while ref.get_ref():
		if ref.get_ref():
			carrier.target = $Zones/TopZone.point_in_zone()
			yield(tok.on(carrier, "arrived"), "done")
			if ref.get_ref() and carrier.hit_points < 100:
				carrier.speed = 100
		if ref.get_ref():
			carrier.target = $Zones/BottomZone.point_in_zone()
			yield(tok.on(carrier, "arrived"), "done")
			if ref.get_ref() and carrier.hit_points < 100:
				carrier.speed = 100

func hit_officer(officer: WeakRef):
	var o = officer.get_ref()
	if o and not o.dying:
		o.hurt("bullet", 0.5)

func reinforce(target, start, officer: WeakRef, pathing):
	var o = officer.get_ref()
	if o and not o.dying:
		spawn_minion(target, start, o, pathing)

func spawn_minion(target: Node2D, start, boss: GavelShip, pathing):
	var e = floater.instance()
	$EnemyDump.add_child(e)
	e.hit_points = 10
	e.speed = 160
	e.shot_mode = "None"
	e.global_position = start.global_position
	e.target = target.global_position
	boss.connect("dying", e, "die")
	e.connect("dying", self, "hit_officer", [weakref(boss)])
	e.connect("dead", self, "reinforce", [target, boss, weakref(boss), pathing])
	enemies.push_back(weakref(e))
	
	move_minion(e, boss, pathing)

func move_minion(e: WindsorShip, boss: GavelShip, pathing: Array):
	var tok = CancellationToken.new()
	e.connect("dead", tok, "cancel")
	var backwards = pathing.duplicate()
	backwards.invert()
	backwards.pop_front()
	while not tok.done:
		for p in pathing:
			if is_instance_valid(p):
				e.speed = boss.speed + 110
				e.target = p
				yield(tok.on(e, "arrived"), "done")
		for p in backwards:
			if is_instance_valid(p):
				e.speed = boss.speed + 110
				e.target = p
				yield(tok.on(e, "arrived"), "done")
	

var sending_reiforcements = true

func rand_child(node: Node2D) -> Node2D: 
	var children = node.get_children()
	return children[randi() % children.size()]
