extends Pickups
class_name Gold

@export var gold : int

func activate():
	super.activate()
	player_reference.gain_gold(gold)
