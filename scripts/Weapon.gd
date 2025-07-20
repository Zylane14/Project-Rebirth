extends Item
class_name Weapon

#properties for projectilesw
@export var damage : float
@export var speed : float
@export var projectile_node : PackedScene = preload("res://scenes/projectile.tscn") #preload projectile node
@export var upgrades : Array[Upgrade] #property to store array of upgrade
@export var item_needed : PassiveItem
@export var evolution : Weapon
@export var sound : AudioStream #property for storing audio
@export var particle : ParticleProcessMaterial = null #new property to store particles
@export var projectile_animation_name: String = "" #animation to play on projectile
@export var manual_only: bool = false  #requires pressing button
@export var cooldown: float = 0.5:
	set(value):
		cooldown = max(value, 0.01) # never allow 0 or less
		
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
	if not can_attack():
		return

	cooldown_timer = cooldown 
	
func is_upgradeable() -> bool:
	if level <= upgrades.size(): #function to check if item is upgradeable or not
		return true
	return false

func upgrade_item():
	# If at max level, evolve instead
	if max_level_reached() and evolution != null:
		var evolved_weapon = evolution.duplicate()
		evolved_weapon.level = 1
		evolved_weapon.owner = owner
		evolved_weapon.slot = slot

		slot.item = evolved_weapon

		if GlobalManager.has_method("register_evolution"):
			GlobalManager.register_evolution(self)

		slot.item = evolved_weapon
	# Clear strong references to help GC clean up
		owner = null
		slot = null

		return

	# If not upgradeable, do nothing
	if not is_upgradeable():
		return

	var upgrade = upgrades[level - 1]
	damage += upgrade.damage
	cooldown += upgrade.cooldown
	cooldown = max(cooldown, 0.01)  # Safety clamp

	level += 1

func max_level_reached() -> bool:
	return level >= upgrades.size() + 1 and upgrades.size() != 0
