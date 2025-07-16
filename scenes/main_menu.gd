extends Control

func _ready() -> void:
	menu()

func _on_upgrades_pressed() -> void:
	skill_tree()


func _on_beastiary_pressed() -> void:
	beastiary()

func menu(): #func to show menu panel and hide others
	$Menu.show()
	$SkillTree.hide()
	$Beastiary.hide()
	$Gold.hide()
	$Back.hide()
	$CharacterSelection.hide()

func skill_tree(): #func to show skill tree
	$SkillTree.show()
	$Gold.show()
	$Menu.hide()
	$Back.show()
	$ConstellationMenu.hide()
	$ConstellationMenu2.show()
	tween_pop($SkillTree)

func beastiary(): #func to show beastiary
	$Beastiary.show()
	$Menu.hide()
	$Gold.hide()
	$Back.show()
	tween_pop($Beastiary)
	$ConstellationMenu.hide()
	$ConstellationMenu2.show()

func _on_back_pressed() -> void: #back button
	menu()
	$ConstellationMenu.show()
	$ConstellationMenu2.hide()
	tween_pop($Back)


@warning_ignore("unused_parameter")
func tween_pop(panel): #func to give pop effect
	SoundManager.play_sfx(load("res://music & sfx/Be Not Afraid UI/--Unholy/Souls/Unholy UI - Souls (2).wav"))
	#panel.scale = Vector2(1.0,1.0)
	#var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	#tween.tween_property(panel, "scale", Vector2(1,1), 0.5)
	
func _on_start_pressed() -> void: #Character Selection
	$CharacterSelection.show()
	$ConstellationMenuOld.show()
	$ConstellationMenu.hide()
	$Menu.hide()
	$Gold.hide()
	$Back.show()
	tween_pop($CharacterSelection)


func _on_exit_pressed() -> void:
	get_tree().quit()
