extends Control

func ItemPopup(slot : Rect2i, item : Item):
	if item != null:
		set_value(item)
		%ItemPopup.size = Vector2i.ZERO
	
	var mouse_pos = get_viewport().get_mouse_position() #get mouse position relative to viewport and store it in mouse_pos
	var correction
	var padding = 5
	
	if mouse_pos.x <= get_viewport_rect().size.x/2: #if mouse is at left half of the screen, set correction to +slot.size.x
		correction = Vector2i(slot.size.x + padding, 0)
	else:
		correction = -Vector2i(%ItemPopup.size.x + padding, 0) #if its on the right half, set correction to -Popup.size.x
		
	%ItemPopup.popup(Rect2i(slot.position + correction, %ItemPopup.size )) #function to call in-built popup() function

func HideItemPopup():
	%ItemPopup.hide()

func set_value(item: Item):
	%Title.text = item.title
	%Level.text = "Level: " + str(item.level)
	%Rarity.text = set_text_effect(Item.Rarity.keys()[item.rarity])

	
	# Set description and toggle visibility
	if item.description.strip_edges() != "":
		%Description.visible = true
		%Description.text = item.description
	else:
		%Description.visible = false


	if item is Weapon:
		var weapon = item as Weapon

		%WeaponStats.visible = true
		%Damage.text = "Damage: " + str(weapon.damage)
		%Cooldown.text = "Cooldown: " + str("%.2f" % weapon.cooldown) + "s"
		%Speed.text = "Speed: " + str(weapon.speed)

		if weapon.max_level_reached():
			%Level.text += " (MAX)"
	else:
		%WeaponStats.visible = false


func set_text_effect(rarity : String):
	var text : String = rarity #store rarity in a local variable
	
	match rarity:
		"COMMON":
			text = "[color=white]" + text + "[/color]"
		"RARE":
			text = "[pulse freq=5.0 color=#ffffff40 ease=-2.0][color=blue]" + text + "[/color][/pulse]"
		"EPIC":
			text = "[wave amp=15 freq=8][color=purple]" + text + "[/color][/wave]"
		"SPECIAL":
			text = "[shake rate=40 level=5][color=orange]" + text + "[/color][/shake]"
		"LEGENDARY":
			text = "[tornado radius=2 freq=4][color=yellow]" + text + "[/color][/tornado]"
	
	return text
