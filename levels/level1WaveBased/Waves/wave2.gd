tool
class_name wave2
extends Node2D

signal wave_complete()

onready var enemy = preload("res://ships/enemies/enemy1/basic_enemy.tscn")
onready var officer = preload("res://ships/enemies/enemy1/basic_officer.tscn")

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
			$Debug.text += "HP: %d" % b.get_ref().hit_points
		
func run_wave():
	run_officer_wave($GruntFormationPoints/C, boss_list)
	
func run_officer_wave(from, officer_list):
	var up = from.get_node("UpperZone")
	var down = from.get_node("LowerZone")
	var spawns = from.get_node("rally").get_children()
	
	yield(T.wait(0.5), D.o)
	var officer: WindsorOfficerShip = spawn_officer(from, from)
	
	officer_list.push_back(weakref(officer))
	
	toggle_moves(officer, from)
	
	yield(T.wait(1.15), D.o)
	for s in spawns:
		spawn_minion(s, from, officer)
	
	yield(officer, "dead")
	emit_signal("wave_complete")

func toggle_moves(officer, from):
	var r = weakref(officer)
	
	while r.get_ref():
		officer.target = from.get_node("UpperZone").point_in_zone()
		yield(officer, "arrived")
		if r.get_ref() and not officer.dying:
			officer.target = from.get_node("LowerZone").point_in_zone()
			yield(officer, "arrived")
		

func spawn_officer(target: Node2D, start) -> WindsorOfficerShip:
	var e = officer.instance()
	e.bullets_node = $BulletsDump.get_path()
	$EnemyDump.add_child(e)
	e.shot_mode = "None"
	e.global_position = start.global_position
	e.target = target.global_position
	return e

func hit_officer(officer: WeakRef):
	var o = officer.get_ref()
	if o and not o.dying:
		o.hurt("bullet", 1)
	

func reinforce(target, start, officer: WeakRef):
	yield(tok.on(T.wait(rand_range(0.75, 3))), "done")
	var o = officer.get_ref()
	if o and not o.dying and o.hit_points > 20:
		spawn_minion(target, start, o)

func spawn_minion(target: Node2D, start, boss: WindsorOfficerShip):
	var e = enemy.instance()
	$EnemyDump.add_child(e)
	e.shot_mode = "None"
	e.global_position = start.global_position
	e.target = target.global_position
	boss.connect("dying", e, "die")
	e.connect("dying", self, "hit_officer", [weakref(boss)])
	e.connect("dead", self, "reinforce", [target, start, weakref(boss)])
	enemies.push_back(weakref(e))
	

var sending_reiforcements = true

func spawn_basic_after(target: Node2D, onSpawn: AsyncSemaphore, onDie: AsyncSemaphore):
	yield(T.wait(rand_range(0, 5)), D.o)
	spawn_basic(target, onSpawn, onDie)

func spawn_reinforce(target: Node2D, onSpawn: AsyncSemaphore, onDie: AsyncSemaphore):
	if sending_reiforcements:
		onSpawn.enter()
		onDie.enter()
		spawn_basic(target, onSpawn, onDie)

func spawn_basic(target: Node2D, onSpawn: AsyncSemaphore, onDie: AsyncSemaphore, start=null):
	var e = enemy.instance()
	enemies.push_back(weakref(e))
	e.bullets_node = $BulletsDump.get_path()
	$EnemyDump.add_child(e)
	e.shot_mode = "None"
	start = start if start else rand_child($Spawners)
	e.global_position = start.global_position
	e.target = target.position
	e.connect("dying", onDie, "done")
	e.connect("dying", self, "spawn_reinforce", [target, onSpawn, onDie])
	onSpawn.done()

func rand_child(node: Node2D) -> Node2D: 
	var children = node.get_children()
	return children[randi() % children.size()]
