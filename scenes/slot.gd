extends PanelContainer

@export var item : Weapon:#setter variable to store weapons
	set(value):
		item = value
		$TextureRect.texture = value.texture
		$Cooldown.wait_time = value.cooldown
		item.slot = self


func _on_cooldown_timeout():
	if item:
		$Cooldown.wait_time = item.cooldown #any upgrade/level up will update the wait time of the timer(cooldown)
		item.activate(owner, owner.nearest_enemy, get_tree()) #with each timeout, call activate from weapon
