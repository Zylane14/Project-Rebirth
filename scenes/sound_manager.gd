extends Node2D

@onready var sfx_player : AudioStreamPlayer #var to store AudioStreamPlayer

func play_sfx(sfx: AudioStream):
	if sfx:
		sfx_player = AudioStreamPlayer.new() #create AudioStreamPlayer and add as child
		add_child(sfx_player)
		
		sfx_player.stream = sfx
		sfx_player.bus = "SFX" #set properties and play sounds
		sfx_player.play()
		
		sfx_player.finished.connect(sfx_player.queue_free) #free it when audio finishes
