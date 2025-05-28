extends Resource
class_name Pickups

@export var title : String
@export var icon : Texture2D
@export_multiline var description : String
@export var sound : AudioStream #property to store audio
@export var weight : float

var player_reference : CharacterBody2D


func activate():
	SoundManager.play_sfx(sound) #play sfx in activate
	print(title + " Picked up.")
