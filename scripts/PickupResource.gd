extends Resource
class_name Pickups

@export var title : String
@export var icon : Texture2D
@export var frame_count: int = 1 # total frames in the sprite sheet
@export var frame_duration: float = 0.1 # duration of each frame
@export_multiline var description : String
@export var sound : AudioStream #property to store audio
@export var weight : float

var player_reference : CharacterBody2D


func activate():
	SoundManager.play_sfx(sound) #play sfx in activate
	print(title + " Picked up.")
