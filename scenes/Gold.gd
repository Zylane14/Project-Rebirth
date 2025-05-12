extends Item
class_name Gold

var player_reference : CharacterBody2D #variable to store player reference and gold amount
@export var gold : int = 5

func upgrade_item():
	if is_instance_valid(player_reference): #upgrade will call gain_gold from player
		player_reference.gain_gold(gold)
