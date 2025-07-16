extends Node

# Declare your global signals
signal player_died
signal score_changed(new_score)
signal level_completed(level_number)

signal on_subtitles_toggled(value : bool)

func emit_on_subtitles_toggled(value : bool) -> void:
	on_subtitles_toggled.emit(value)
