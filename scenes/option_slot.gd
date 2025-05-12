extends TextureButton


@export var item : Item: #setter variable to store weapon resource to update texture
	set(value):
		item = value
		texture_normal = value.texture
		$Label.text = "Lvl " + str(item.level + 1)
		$Description.text = value.upgrades[value.level - 1].description #description from Upgrades to OptionSlots


func _on_gui_input(event: InputEvent):
	if event.is_action_pressed("click") and item: #clicking the slot will close the option
		print(item.title)
		item.upgrade_item() #pressing the gui will upgrade the weapon
		get_parent().close_option()
 
