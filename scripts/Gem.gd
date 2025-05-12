extends Pickups
class_name Gem

@export var XP : float

#activating Gem will make the player gain XP
func activate():
	super.activate()
	print("+" + str(XP) + "XP")
	player_reference.gain_XP(XP)
