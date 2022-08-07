tool
class_name wave1
extends Node2D

signal wave_complete()

onready var enemy = preload("res://ships/enemies/enemy1/basic_enemy.tscn")

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

func run_basic_wave():
	yield(T.wait(3), D.o)
	var points = $GruntFormationPoints.get_children()
	var after_spawns = AsyncSemaphore.new(len(points))
	var after_deaths = AsyncSemaphore.new(len(points))
	shot_timer(after_deaths)
	for t in points:
		spawn_basic(t, after_spawns, after_deaths)
	yield(after_spawns, "done")
	print("SPAWNED")
	yield(after_deaths, "done")
	print("DEADS")
	emit_signal("wave_complete")

func spawn_basic(target: Node2D, onSpawn: AsyncSemaphore, onDie: AsyncSemaphore):
	yield(T.wait(rand_range(0, 5)), D.o)
	var e = enemy.instance()
	enemies.push_back(weakref(e))
	$EnemyDump.add_child(e)
	e.shot_mode = "None"
	var start = rand_child($Spawners)
	e.global_position = start.global_position
	e.target = target.position
	e.connect("dead", onDie, "done")
	onSpawn.done()

func rand_child(node: Node2D) -> Node2D: 
	var children = node.get_children()
	return children[randi() % children.size()]
