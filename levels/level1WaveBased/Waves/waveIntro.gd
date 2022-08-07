tool
extends Node2D

signal wave_complete()

onready var enemy = preload("res://ships/enemies/enemy1/basic_enemy.tscn")

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
	
func run_basic_wave():
	yield(T.wait(3), D.o)
	var points = $GruntFormationPoints.get_children()
	var after_spawns = AsyncSemaphore.new(len(points))
	var after_deaths = AsyncSemaphore.new(len(points))
	shot_timer(after_deaths)
	for t in points:
		spawn_basic(t, after_spawns, after_deaths)
	yield(after_spawns, "done")
	yield(after_deaths, "done")
	emit_signal("wave_complete")

var enemies = []

func shot_timer(onDie):
	while onDie.value > 0:
		yield(T.wait(rand_range(3, 5)), D.o)
		if enemies.size() > 0:
			enemies = D.clear_freed(enemies)
			var e = enemies[randi() % enemies.size()]
			if e.get_ref():
				e.get_ref().fire_horizontal()

func spawn_basic(target: Node2D, onSpawn: AsyncSemaphore, onDie: AsyncSemaphore):
	yield(T.wait(rand_range(0, 5)), D.o)
	var e = enemy.instance()
	enemies.push_back(weakref(e))
	e.bullets_node = $BulletsDump.get_path()
	$EnemyDump.add_child(e)
	e.shot_mode = "None"
	var start = rand_child($Spawners)
	e.global_position = start.global_position
	e.target = target.position
	e.connect("dying", onDie, "done")
	onSpawn.done()

func rand_child(node: Node2D) -> Node2D: 
	var children = node.get_children()
	return children[randi() % children.size()]
