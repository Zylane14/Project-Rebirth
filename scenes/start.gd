extends TextureButton



func _on_pressed() -> void:
	SoundManager.play_sfx(load("res://music & sfx/Be Not Afraid UI/--Unholy/Souls/Unholy UI - Souls (10).wav"))
	get_tree().change_scene_to_file("res://scenes/test_scene.tscn")
