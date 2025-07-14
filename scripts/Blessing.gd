extends Item
class_name Blessing

@export var zodiac: ZodiacGod
@export var is_spell: bool = false
@export var weapon_scene: PackedScene

func upgrade_item(player):
	level += 1
	if is_spell:
		var weapon = player.get_weapon_by_title(title)
		if weapon:
			weapon.upgrade_item()
