extends CanvasLayer

@onready var anim = $AnimationPlayer

func _ready():
	anim.play("fade_in")
	
func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
