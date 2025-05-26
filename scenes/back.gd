extends Button

func _ready():
	visible = false

func _process(_delta):
	if get_tree().paused == true and owner.health <= 0 and visible == false: #if the tree is paused and health <= 0, then show this button
		visible = true

func _on_pressed():
	get_tree().paused = false
	SaveData.gold += owner.gold
	SaveData.set_and_save() #save changes before switching scene
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
