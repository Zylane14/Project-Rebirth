extends PanelContainer

@export var item : Weapon:#setter variable to store weapons
	set(value):
		if item != null and item.has_method("reset"): #before changing to new value, reset the previous item
			item.reset()
		
		item = value

		if value != null: # Prevent error when value is null
			$TextureRect.texture = value.icon
			$Cooldown.wait_time = value.cooldown
			item.slot = self
		else:
			$TextureRect.texture = null
			$Cooldown.wait_time = 0.1 # Default or safe fallback

func _physics_process(delta):
	if item != null and item.has_method("update"):
		item.update(delta) 

func _on_cooldown_timeout():
	if item:
		$Cooldown.wait_time = item.cooldown #any upgrade/level up will update the wait time of the timer(cooldown)
		item.activate(owner, owner.nearest_enemy, get_tree()) #with each timeout, call activate from weapon

func _on_mouse_entered() -> void:
	if item == null:
		return
		
	Popups.ItemPopup(Rect2i( Vector2i(global_position), Vector2i(size) ), item)


func _on_mouse_exited() -> void:
	Popups.HideItemPopup() #hide ItemPopup when mouse exits the slot
