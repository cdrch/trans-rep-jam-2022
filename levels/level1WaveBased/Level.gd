extends Node2D

func _ready():
	randomize()
	Bullets.bullets_parent = $BulletDump
	Bullets.weapon = $PlayerShip/Gunpoint
	$Barrier.hide()
	$Barrier.global_position = Vector2(-5000, -5000)
	$PlayerShip.connect("velocity_changed", self, "_on_player_velocity_changed")
	start_waves()

var player_velocity = "static"

var background_tween: SceneTreeTween
var warping = false
func tween_background_to(vel, dur):
	if warping:
		return
	if background_tween != null:
		background_tween.stop()
	var t = get_tree().create_tween()
	t.tween_property($Background, "scroll_speed", vel, dur).set_trans(Tween.TRANS_LINEAR)
	background_tween = t
	
func warp():
	warping = true
	var sig = Deferred.new()
	var t = get_tree().create_tween()
	t.tween_property($Background, "warp", 20, 3).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	t.tween_property($Background, "warp", 20, 3)
	t.tween_property($Background, "warp", 1, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.tween_callback(sig, "done")
	var q = get_tree().create_tween()
	q.tween_property($Background, "scroll_speed", -240, 3).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	q.tween_property($Background, "scroll_speed", -240, 3)
	q.tween_property($Background, "scroll_speed", -20, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	print("START_WARP")
	return sig

func _on_player_velocity_changed(to):
	if to != player_velocity:
		player_velocity = to
		match to:
			"forward": tween_background_to(-60, 1)
			"backwards": tween_background_to(-10, 0.25)
			"static": tween_background_to(-20, 0.5)
			_: pass

func start_waves():
	yield(warp(), "done")
	warping = false
	$Waves/introWave.show()
	$Waves/introWave.connect("wave_complete", self, "waveIntro_done")
	$Waves/introWave.run_wave()

func waveIntro_done():
	yield(warp(), "done")
	warping = false
	Bullets.upgrade()
	$Waves/introWave.queue_free()
	$Waves/wave1.show()
	$Waves/wave1.connect("wave_complete", self, "wave1_done")
	$Waves/wave1.run_wave()
	
func wave1_done():
	yield(warp(), "done")
	warping = false
	Bullets.upgrade()
	$Waves/wave1.hide()
	$Waves/wave2.show()
	$Waves/wave2.connect("wave_complete", self, "wave2_done")
	$Waves/wave2.run_wave()
	
func wave2_done():
	yield(warp(), "done")
	warping = false
	Bullets.upgrade()
	$Waves/wave2.hide()
	$Waves/wave3.show()
	$Waves/wave3.connect("wave_complete", self, "wave3_done")
	$Waves/wave3.run_wave()
	
func wave3_done():
	yield(warp(), "done")
	get_tree().quit(0)
