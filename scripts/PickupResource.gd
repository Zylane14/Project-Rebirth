extends Resource
class_name Pickups

@export var title: String
@export var icon: Texture2D
@export var frames: SpriteFrames # replaces icon + frame count + frame duration
@export var animation_name: String = "default" # which animation to play
@export_multiline var description: String
@export var sound: AudioStream
@export var weight: float

var player_reference: CharacterBody2D

func activate():
	SoundManager.play_sfx(sound)
	print(title + " picked up.")
