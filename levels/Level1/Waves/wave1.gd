tool
class_name wave1
extends Node2D

signal wave_complete()

onready var enemy = preload("res://ships/enemies/enemy1/basic_enemy.tscn")
onready var floater = preload("res://ships/enemies/enemy1/basic_floater.tscn")
func _ready():
	if not Engine.editor_hint:
		$viewport_hint.queue_free()
	
	# var eye = $EnemyDump/SpaceEye
	# eye.move_target = $EyeZone.point_in_zone()
	# eye.visual_target = $DiveZoneExtents.point_in_zone()
	# eye.connect("arrived", self, "eye_arrived", [eye])
	# eye.connect("attuned", self, "eye_attuned", [eye])
	# eye.connect("rot_mode", $Debug, "set_text")

#func eye_arrived(eye: SpaceEye):
#	eye.move_target = $EyeZone.point_in_zone()

#func eye_attuned(eye: SpaceEye):
#	var t = $DiveZoneExtents.point_in_zone()
#	print("new target: ", t)
#	eye.visual_target = t

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

func spawn_floater(onDie: AsyncSemaphore):
	yield(T.wait(rand_range(1, 4)), D.o)
	onDie.enter()
	var e = floater.instance()
	$EnemyDump.add_child(e)
	e.shot_mode = "None"
	e.speed = 100
	e.hit_points = 10
	e.global_position = $SpawnZone.point_in_zone()
	e.target = $DiveZoneExtents.point_in_zone()
	e.connect("dead", onDie, "done")
	var e_ref = weakref(e)
	while e_ref.get_ref():
		yield(e, "arrived")
		if e_ref.get_ref():
			e.target = $DiveZoneExtents.point_in_zone()
	
func run_basic_wave():
	print("1-1")
	yield(T.wait(3), D.o)
	var points = $GruntFormationPoints.get_children()
	var after_spawns = AsyncSemaphore.new(0)
	var after_deaths = AsyncSemaphore.new(0)
	var floater_deaths = AsyncSemaphore.new(0)
	for i in 12:
		spawn_floater(floater_deaths)
	for t in points:
		spawn_basic(t.global_position, after_spawns, after_deaths)
	shot_timer(after_deaths)
	var t = get_tree().create_tween()
	t.set_loops()
	t.tween_interval(2)
	t.tween_callback(self, "spawn_floater", [floater_deaths])
	yield(after_spawns, "done")
	print("SPAWNED")
	yield(after_deaths, "done")
	t.kill()
	yield(floater_deaths.await(), D.o)
	print("DEADS")
	emit_signal("wave_complete")

func spawn_basic(target: Vector2, onSpawn: AsyncSemaphore, onDie: AsyncSemaphore):
	onSpawn.enter()
	onDie.enter()
	yield(T.wait(rand_range(0, 5)), D.o)
	var e = enemy.instance()
	e.hit_points = 30
	enemies.push_back(weakref(e))
	$EnemyDump.add_child(e)
	e.shot_mode = "None"
	e.global_position = $SpawnZone.point_in_zone()
	e.target = target
	e.connect("dead", onDie, "done")
	onSpawn.done()

func rand_child(node: Node2D) -> Node2D: 
	var children = node.get_children()
	return children[randi() % children.size()]
