extends Node

var is_playing = {
	"Space Pilot Chill": false,
	"Foward Into Battle": false,
	"Warp Again": false,
	"Foreboding Feeling": false,
	"Monarch's Battle": false,
	"The Sword's Shield": false,
	"End Of Some Things": false,
}

var is_loaded = {
	"Space Pilot Chill": false,
	"Foward Into Battle": false,
	"Warp Again": false,
	"Foreboding Feeling": false,
	"Monarch's Battle": false,
	"The Sword's Shield": false,
	"End Of Some Things": false,
}

var first = true



# Called when the node enters the scene tree for the first time.
func _ready():
	yield(T.wait(1), D.o)
	MixingDeskMusic.init_song("Space Pilot Chill")
	print("init_song from _ready")
	is_loaded["Space Pilot Chill"] = true

func _is_anything_playing():
	if is_playing.values().find(true):
		return true
	return false


func request_song(song_name_as_string):
	if not is_loaded[song_name_as_string]:
		print("init_song on request")
		MixingDeskMusic.init_song(song_name_as_string)
	if is_playing[song_name_as_string]:
		print("already playing song from request")
		return
	if first:
		print("playing song on request")
		MixingDeskMusic.play(song_name_as_string)
		first = false
		return
	else:
		print("queueing song on request")
		MixingDeskMusic.queue_bar_transition(song_name_as_string)
		return
