tool
class_name wave2
extends Node2D

signal wave_complete()

onready var enemy = preload("res://ships/enemies/enemy1/basic_enemy.tscn")

func _ready():
	if not Engine.editor_hint:
		$viewport_hint.queue_free()

func _process(delta):
	pass

var enemies = []

func shot_timer(onDie):
	while onDie.value > 0:
		yield(T.wait(rand_range(1, 3)), D.o)
		enemies = D.clear_freed(enemies)
		if enemies.size() > 0:
			var e = enemies[randi() % enemies.size()]
			e.get_ref().fire_horizontal()

func run_wave():
	run_basic_wave()

var sending_reiforcements = true
func run_basic_wave():
	yield(T.wait(0.5), D.o)
	var points = $GruntFormationPoints.get_children()
	var after_spawns = AsyncSemaphore.new(len(points))
	var after_deaths = AsyncSemaphore.new(len(points))
	shot_timer(after_deaths)
	sending_reiforcements = true
	for t in points:
		spawn_basic_after(t, after_spawns, after_deaths)
	for i in range(45, -1, -1):
		$Debug.text = "T-%02d" % i
		yield(T.wait(1), D.o)
	sending_reiforcements = false
	$Debug.text = "Mop them up!"
	yield(after_spawns, "done")
	print("SPAWNED")
	yield(after_deaths, "done")
	print("DEADS")
	emit_signal("wave_complete")

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
