extends Item
class_name Weapon

#properties for projectilesw
@export var damage : float
@export var cooldown : float
@export var speed : float
@export var projectile_node : PackedScene = preload("res://scenes/projectile.tscn") #preload projectile node
@export var upgrades : Array[Upgrade] #property to store array of upgrade
@export var item_needed : PassiveItem
@export var evolution : Weapon
@export var sound : AudioStream #property for storing audio
@export var particle : ParticleProcessMaterial = null #new property to store particles
@export var projectile_animation_name: String = "" #animation to play on projectile
@export var manual_only := false

var slot
var damage_dealt : float = 0
var cooldown_timer := 0.0
var owner: CharacterBody2D

func can_attack() -> bool:
	return cooldown_timer <= 0

func update(delta):
	if cooldown_timer > 0:
		cooldown_timer -= delta
	elif not manual_only and is_instance_valid(owner):
		activate(owner, owner.nearest_enemy, owner.get_tree())

func activate(_source, _target, _scene_tree):
	pass

func is_upgradeable() -> bool:
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

func max_level_reached(): #function to check if an item reached max level or not
	if upgrades.size() +1 == level and upgrades.size() != 0:
		return true
	return false
	
func reset():
	damage_dealt = 0
	slot = null
	level = 1
