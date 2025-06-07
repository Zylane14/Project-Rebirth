extends Button


func _on_pressed():
	get_tree().paused = false
	Persistence.character = null
	SaveData.gold += owner.gold
	SaveData.set_and_save() #save changes before switching scene
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
