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
	tween_pop($Menu)

func skill_tree(): #func to show skill tree
	$SkillTree.show()
	$Gold.show()
	$Menu.hide()
	$Back.show()
	tween_pop($SkillTree)

func beastiary(): #func to show beastiary
	$Beastiary.show()
	$Menu.hide()
	$Gold.hide()
	$Back.show()
	tween_pop($Beastiary)


func _on_back_pressed() -> void: #back button
	menu()


func tween_pop(panel): #func to give pop effect
	SoundManager.play_sfx(load("res://music & sfx/RPG_Essentials_Free/10_UI_Menu_SFX/070_Equip_10.wav"))
	panel.scale = Vector2(0.85,0.85)
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "scale", Vector2(1,1), 0.5)
