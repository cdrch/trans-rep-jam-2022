extends Node2D

func _ready():
	randomize()
	Bullets.bullets_parent = $BulletDump
	Bullets.weapon = $PlayerShip/Gunpoint
	$Waves/introWave.show()
	$Waves/introWave.connect("wave_complete", self, "waveIntro_done")
	$Waves/introWave.run_wave()
	$Barrier.hide()
	$Barrier.global_position = Vector2(-5000, -5000)

func waveIntro_done():
	Bullets.upgrade()
	$Waves/introWave.queue_free()
	$Waves/wave1.show()
	$Waves/wave1.connect("wave_complete", self, "wave1_done")
	$Waves/wave1.run_wave()
	
func wave1_done():
	Bullets.upgrade()
	$Waves/wave1.queue_free()
	$Waves/wave2.show()
	$Waves/wave2.connect("wave_complete", self, "wave2_done")
	$Waves/wave2.run_wave()
	
func wave2_done():
	get_tree().quit(0)
