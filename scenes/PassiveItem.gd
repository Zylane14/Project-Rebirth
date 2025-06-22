extends Item
class_name PassiveItem

@export var upgrades : Array[Stats] #array variable to store stats
var player_reference #the upgrades will be applied to the player

func is_upgradeable() -> bool:
	if level <= upgrades.size(): #function to check if item can be upgraded or not
		return true
	return false

func upgrade_item(): #this will first check for upgrades and player reference
	if not is_upgradeable():
		return
	
	if player_reference == null:
		return
	
	var upgrade = upgrades[level - 1] #get upgrade relative to the item level

	#upgrades stats and level up
	player_reference.max_health += upgrade.max_health
	player_reference.recovery += upgrade.recovery
	player_reference.armor += upgrade.armor
	player_reference.movement_speed += upgrade.movement_speed
	player_reference.damage += upgrade.damage
	player_reference.amplify += upgrade.amplify
	player_reference.area += upgrade.area
	player_reference.magnet += upgrade.magnet
	player_reference.growth += upgrade.growth
	player_reference.luck += upgrade.luck
	player_reference.dodge += upgrade.dodge

	level += 1
