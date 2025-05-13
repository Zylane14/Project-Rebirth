extends Pickups
class_name Health

@export var amount : int = 20 #destructible health

func activate():
	super.activate()
	player_reference.health += amount #function to increase player health
	
	
