extends CanvasLayer

@onready var anim = $AnimationPlayer

func _ready():
	anim.play("fade_in")
	
func _on_restart_pressed():
	get_tree().paused = false
	AudioController.bg_music.stop()
	get_tree().reload_current_scene()


func _on_menu_pressed():
	get_tree().paused = false
	AudioController.bg_music.stop()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
