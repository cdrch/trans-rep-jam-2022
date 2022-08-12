tool
extends Node2D

signal wave_complete()

onready var enemy = preload("res://ships/enemies/enemy1/basic_enemy.tscn")
onready var floater = preload("res://ships/enemies/enemy1/basic_floater.tscn")

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	if not Engine.editor_hint:
		$viewport_hint.queue_free()

func run_wave():
	run_basic_wave()

func eye_arrived(eye: SpaceEye):
	eye.move_target = $EyeZone.point_in_zone()

func eye_attuned(eye: SpaceEye):
	var t = $DiveZoneExtents.point_in_zone()
	print("new target: ", t)
	eye.visual_target = t

func _process(delta):
	pass

func reinforce(t, e: WindsorShip, after_spawns, after_deaths: AsyncSemaphore):
	after_deaths.enter()
	yield(e, "dead")
	yield(T.wait(rand_range(0.1, 0.5)), D.o)
	
	var ts = [
		Vector2(0, 5),
		Vector2(0, 5).rotated(2*PI/3),
		Vector2(0, 5).rotated(-2*PI/3)
	]
	
	for off in ts:
		var re = floater.instance()
		re.speed = 100
		re.hit_points = 10
		spawn_basic(re, t.global_position + off, after_spawns, after_deaths)
	after_deaths.done()

func run_basic_wave():
	yield(T.wait(3), D.o)
	var points = $GruntFormationPoints.get_children()
	var after_spawns = AsyncSemaphore.new(0)
	var after_deaths = AsyncSemaphore.new(0)

	for t in points:
		var e = enemy.instance()
		spawn_basic(e, t.global_position, after_spawns, after_deaths)
		reinforce(t, e, after_spawns, after_deaths)

	shot_timer(after_deaths)
	
	yield(after_spawns, "done")
	yield(after_deaths, "done")
	emit_signal("wave_complete")

var enemies = []

func shot_timer(onDie):
	while onDie.value > 0:
		yield(T.wait(rand_range(3, 5)), D.o)
		enemies = D.clear_freed(enemies)
		if enemies.size() > 0:
			var e = enemies[randi() % enemies.size()]
			if e.get_ref():
				e.get_ref().fire_horizontal()
 

func spawn_basic(e, target: Vector2, onSpawn: AsyncSemaphore, onDie: AsyncSemaphore):
	onSpawn.enter()
	onDie.enter()
	yield(T.wait(rand_range(0, 5)), D.o)
	enemies.push_back(weakref(e))
	$EnemyDump.add_child(e)
	e.shot_mode = "None"
	var start = rand_child($Spawners)
	e.global_position = start.global_position
	e.target = target
	e.connect("dying", onDie, "done")
	onSpawn.done()


func rand_child(node: Node2D) -> Node2D: 
	var children = node.get_children()
	return children[randi() % children.size()]
