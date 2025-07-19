extends Pickups
class_name Gem

@export var XP : float

#activating Gem will make the player gain XP
func activate():
	super.activate()
	if player_reference and player_reference.has_method("gain_XP"):
		print("+" + str(XP) + "XP")
		player_reference.gain_XP(XP)
	else:
		print("No valid player reference found!")
