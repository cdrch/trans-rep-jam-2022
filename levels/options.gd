extends Node2D


func _ready():
	pass

func _process(delta):
	pass
	
func play_sfx_test(changed: bool):
	if changed:
		$sfxTest.play()

onready var _sfx_bus = AudioServer.get_bus_index("SFX")
onready var _music_bus = AudioServer.get_bus_index("Music")

func _on_back_to_menu_pressed():
	var conf = ConfigFile.new()
	var err = conf.load("user://settings.cfg")
	if err != OK:
		# Create a new config file here, any other settings edits should 
		# adopt a 
		conf = ConfigFile.new()
	
	conf.set_value("Sound", "SfxVolume", db2linear(AudioServer.get_bus_volume_db(_sfx_bus)))
	conf.set_value("Sound", "MusicVolume", db2linear(AudioServer.get_bus_volume_db(_music_bus)))
	conf.save("user://settings.cfg")
	
	get_tree().change_scene("res://levels/main_menu.tscn")
