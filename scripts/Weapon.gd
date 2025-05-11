extends Resource
class_name Weapon

@export var title : String
@export var texture : Texture2D

#properties for projectiles
@export var damage : float
@export var cooldown : float
@export var speed : float

#preload projectile node
@export var projectile_node : PackedScene = preload("res://scenes/projectile.tscn")

#property to store array of upgrade
@export var upgrades : Array[Upgrade]
var level = 1

func activate(_source, _target, _scene_tree):
	pass

func	 is_upgradeable() -> bool:
	if level <= upgrades.size(): #function to check if item is upgradeable or not
		return true
	return false

func upgrade_item(): #function to upgrade item
	if not is_upgradeable():
		return
		
	var upgrade = upgrades[level - 1]
	
	damage += upgrade.damage #base Resource upgrades common stats (for now)
	cooldown += upgrade.cooldown
	
	level += 1
