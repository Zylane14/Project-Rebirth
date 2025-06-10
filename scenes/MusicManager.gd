extends Node

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	music_player.bus = "Music"
	add_child(music_player)

func play_music(music: AudioStream):
	if music:
		if music_player.playing:
			music_player.stop()
		music_player.stream = music
		music_player.play()
