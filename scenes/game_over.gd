extends CanvasLayer

@onready var anim = $AnimationPlayer

func _ready():
	anim.play("fade_in")

func _on_menu_pressed():
	get_tree().paused = false
	Persistence.character = null
	var player = get_node("/root/TestScene/Player") # Adjust path based on your scene structure
	if player:
		SaveData.gold += player.gold
	SaveData.set_and_save() #save changes before switching scene
	AudioController.bg_music.stop()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
