extends TextureButton


@export var weapon : Weapon: #setter variable to store weapon resource to update texture
	set(value):
		weapon = value
		texture_normal = value.texture
		$Label.text = "Lvl " + str(weapon.level + 1)
		$Description.text = value.upgrades[value.level - 1].description #description from Upgrades to OptionSlots


func _on_gui_input(event: InputEvent):
	if event.is_action_pressed("click") and weapon: #clicking the slot will close the option
		print(weapon.title)
		weapon.upgrade_item() #pressing the gui will upgrade the weapon
		get_parent().close_option()
 
