extends Node2D

onready var next_level = load("res://levels/Level2/level2WaveBased.tscn")
onready var story: StoryData = preload("res://story.tres")
func _ready():
	randomize()
	$Camera2D.current = true
	if Globals.Starfield != null:
		var b_pos = $Background.global_position
		Globals.replace_node($Background, Globals.Starfield)
		$Background.global_position = b_pos
		
	if Globals.Ship != null:
		Globals.replace_node($PlayerShip, Globals.Ship)
		$PlayerShip.global_position = Globals.Ship_Pos
	Bullets.bullets_parent = $BulletDump
	Bullets.weapon = $PlayerShip/Gunpoint
	$Barrier.hide()
	$Barrier.global_position = Vector2(-5000, -5000)
	$PlayerShip.connect("velocity_changed", self, "_on_player_velocity_changed")
	call_deferred("start_waves")

var player_velocity = "static"
onready var reset_pos = $tickerTape.rect_global_position
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
	
func start_warp():
	warping = true
	var sig = Deferred.new()
	$PlayerShip.gun_equipped = false
	var t = get_tree().create_tween()
	t.tween_property($Background, "warp", 20, 3).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	t.tween_property($Background, "warp", 20, 3)
	t.tween_callback(sig, "done")
	
	var q = get_tree().create_tween()
	q.tween_property($Background, "scroll_speed", -240, 3).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	q.tween_property($Background, "scroll_speed", -240, 3)
	return sig

func end_warp():
	var sig = Deferred.new()
	var t = get_tree().create_tween()
	var q = get_tree().create_tween()
	t.tween_property($Background, "warp", 1, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	q.tween_property($Background, "scroll_speed", -20, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	q.tween_callback(sig, "done")
	$PlayerShip.gun_equipped = true
	return sig

var ticker_tween
var ticker_sig
func scroll_text(txt: String):
	$tickerTape.rect_global_position = reset_pos
	$tickerTape.text = txt
	var w = $tickerTape.get_minimum_size().x
	$tickerTape.rect_size.x = w
	var q = get_tree().create_tween()
	var dist = $tickerTape.rect_global_position.x - w - 640
	q.tween_property($tickerTape, "rect_global_position:x", dist, (w+640) / 200)
	ticker_sig = Deferred.new()
	q.tween_callback(ticker_sig, "done")
	ticker_tween = q
	return ticker_sig

var skipping = false
func skip_text():
	skipping = true
	ticker_tween.kill()
	var q = get_tree().create_tween()
	var w = $tickerTape.get_minimum_size().x
	var dist = $tickerTape.rect_global_position.x - w - 640
	q.tween_property($tickerTape, "rect_global_position:x", dist, 2)
	var sig = Deferred.new()
	q.tween_callback(ticker_sig, "done")
	$"Button Prompt".hide()
	yield(ticker_sig, "done")
	ticker_tween = null
	skipping = false

func _process(_delta):
	if ticker_tween and warping and Input.is_action_just_pressed("fire") and $"Button Prompt".visible:
		skip_text()
	if not skipping and ticker_tween and warping and Input.is_action_just_pressed("fire"):
		$"Button Prompt".show()

func _on_player_velocity_changed(to):
	if to != player_velocity:
		player_velocity = to
		match to:
			"forward": tween_background_to(-60, 1)
			"backwards": tween_background_to(-10, 0.25)
			"static": tween_background_to(-20, 0.5)
			_: pass


func start_waves():
	# yield(MixingDeskMusic, "bar")
	#MixingDeskMusic.queue_bar_transition("Warp Again")
	SongRequester.request_song("Warp Again")
	yield(start_warp(), "done")
	yield(scroll_text(story.ticker_tape1_0), "done")
	yield(end_warp(), "done")
	# yield(MixingDeskMusic, "bar")
	SongRequester.request_song("Forward Into Battle")
	# yield(MixingDeskMusic, "bar")
	warping = false
	$Waves/introWave.show()
	$Waves/introWave.connect("wave_complete", self, "waveIntro_done")
	$Waves/introWave.run_wave()

func waveIntro_done():
	SongRequester.request_song("Warp Again")
	yield(start_warp(), "done")
	yield(scroll_text(story.ticker_tape1_1), "done")
	yield(end_warp(), "done")
	SongRequester.request_song("Forward Into Battle")
	warping = false
	Bullets.upgrade()
	$Waves/introWave.queue_free()
	$Waves/wave1.show()
	$Waves/wave1.connect("wave_complete", self, "wave1_done")
	$Waves/wave1.run_wave()
	
func wave1_done():
	SongRequester.request_song("Warp Again")
	yield(start_warp(), "done")
	yield(scroll_text(story.ticker_tape1_2), "done")
	yield(end_warp(), "done")

	SongRequester.request_song("Forward Into Battle")
	warping = false
	Bullets.upgrade()
	$Waves/wave1.hide()
	$Waves/wave2.show()
	$Waves/wave2.connect("wave_complete", self, "wave2_done")
	$Waves/wave2.run_wave()
	
func wave2_done():
	# MixingDeskMusic.stop("Warp Again")
	# yield(MixingDeskMusic, "bar")
	SongRequester.request_song("Foreboding Feeling")
	yield(start_warp(), "done")
	# MixingDeskMusic.play("Foreboding Feeling")
	yield(scroll_text(story.ticker_tape1_3), "done")
	yield(end_warp(), "done")
	# yield(MixingDeskMusic, "bar")
	SongRequester.request_song("Forward Into Battle")
	# yield(MixingDeskMusic, "bar")
	warping = false
	Bullets.upgrade()
	$Waves/wave2.hide()
	$Waves/wave3.show()
	$Waves/wave3.connect("wave_complete", self, "wave3_done")
	$Waves/wave3.run_wave()
	
func wave3_done():
	Globals.Ship_Pos = $PlayerShip.global_position
	Globals.stash()
	get_tree().change_scene_to(next_level)
