extends Node

var subtitles_state : bool = false

func _ready():
	SignalBus.on_subtitles_toggled.connect(on_subtitles_toggled)
	
func on_subtitles_toggled(value : bool) -> void:
	subtitles_state = value
	print(subtitles_state)


func get_subtitles_state() -> bool:
	return subtitles_state
