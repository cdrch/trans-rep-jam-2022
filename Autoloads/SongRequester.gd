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


var songs = {
	"Space Pilot Chill": preload("res://audio/music/Space Pilot Chill.ogg"),
	"Forward Into Battle": preload("res://audio/music/Forward Into Battle.ogg"),
	"Warp Again": preload("res://audio/music/Warp Again.ogg"),
	"Foreboding Feeling": preload("res://audio/music/Foreboding Feeling.ogg"),
	"Monarch's Battle": preload("res://audio/music/Monarchs Battle.ogg"),
	"The Sword's Shield": preload("res://audio/music/The Swords Shield.ogg"),
	"End Of Some Things": preload("res://audio/music/End Of Some Things.ogg"),
}

var players = {}

var first = true
var current_song

func prep_players():
	for s in songs.keys():
		var stream = songs[s]
		var player = AudioStreamPlayer.new()
		player.stream = stream
		player.name = s
		player.bus = "Music"
		player.connect("finished", self, "replay_if_current", [player])
		add_child(player)
		players[s] = player

func replay_if_current(player: AudioStreamPlayer):
	if player.name == current_song:
		player.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(T.wait(1), D.o) # only matters if something went wrong
	#MixingDeskMusic.init_song("Space Pilot Chill")
	print("init_song from _ready")

func _is_anything_playing():
	for i in is_playing:
		if is_playing[i]:
			return true
	return false


func _reset_is_playing():
	for i in is_playing:
		is_playing[i] = false

func volume_lerp(val: float, player: AudioStreamPlayer):
	player.volume_db = linear2db(val)

func crossfade(from: AudioStreamPlayer, to: AudioStreamPlayer):
	var t = create_tween()
	to.play()
	t.tween_method(self, "volume_lerp", 1.0, 0.0, 1, [from])
	t.parallel().tween_method(self, "volume_lerp", 0.0, 1.0, 1, [to])
	yield(t, "finished")
	from.stop()
	
func fade_in(player: AudioStreamPlayer):
	var t = create_tween()
	player.volume_db = linear2db(0)
	player.play()
	t.tween_method(self, "volume_lerp", 0.0, 1.0, 0.5, [player])
	

func request_song(song_name_as_string):
	if players.size() == 0:
		prep_players()
		
	if is_playing[song_name_as_string]:
		print("already playing song from request")
		return
	_reset_is_playing()
	
	if first:
		print("playing song on request")
		current_song = song_name_as_string
		fade_in(players[song_name_as_string])
		first = false
	else:
		print("queueing song on request")
		crossfade(players[current_song], players[song_name_as_string])
		current_song = song_name_as_string
	
	is_playing[song_name_as_string] = true
