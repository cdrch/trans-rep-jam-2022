extends Node

var is_playing = {
	"Space Pilot Chill": false,
	"Forward Into Battle": false,
	"Warp Again": false,
	"Foreboding Feeling": false,
	"Monarch's Battle": false,
	"The Sword's Shield": false,
	"End Of Some Things": false,
}

var first = true



# Called when the node enters the scene tree for the first time.
func _ready():
	yield(T.wait(1), D.o) # only matters if something went wrong
	MixingDeskMusic.init_song("Space Pilot Chill")
	print("init_song from _ready")

func _is_anything_playing():
	for i in is_playing:
		if is_playing[i]:
			return true
	return false


func _reset_is_playing():
	for i in is_playing:
		is_playing[i] = false


func request_song(song_name_as_string):
	# print("init_song on request if needed")
	# MixingDeskMusic.init_song(song_name_as_string)
	
	if is_playing[song_name_as_string]:
		print("already playing song from request")
		return
	_reset_is_playing()
	
	if first:
		print("playing song on request")
		MixingDeskMusic.quickplay(song_name_as_string)
		first = false
	else:
		print("queueing song on request")
		MixingDeskMusic.queue_bar_transition(song_name_as_string)
	
	
	
	is_playing[song_name_as_string] = true
