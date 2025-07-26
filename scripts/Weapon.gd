extends Item
class_name Weapon

@export var damage: float
@export var speed: float
@export var projectile_node: PackedScene = preload("res://scenes/projectile.tscn")
@export var upgrades: Array[Upgrade]
@export var item_needed: PassiveItem
@export var evolution: Weapon
@export var sound: AudioStream
@export var particle: ParticleProcessMaterial = null
@export var projectile_animation_name: String = ""
@export var manual_only: bool = false
@export var cooldown: float = 0.5:
	set(value):
		cooldown = max(value, 0.01)

var slot
var damage_dealt: float = 0
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
	return level <= upgrades.size() and upgrades.size() > 0

func max_level_reached() -> bool:
	return level > upgrades.size()

func upgrade_item():
	if max_level_reached() and evolution != null:
		# Perform evolution
		var evolved_weapon: Weapon = evolution.duplicate()
		evolved_weapon.level = 1
		evolved_weapon.owner = owner
		evolved_weapon.slot = slot
		slot.item = evolved_weapon

		if GlobalManager.has_method("register_evolution"):
			GlobalManager.register_evolution(self)

		# Help garbage collection
		owner = null
		slot = null
		return

	# Apply upgrade
	if not is_upgradeable():
		return

	var upgrade = upgrades[level - 1]
	damage += upgrade.damage
	cooldown += upgrade.cooldown
	cooldown = max(cooldown, 0.01)  # Clamp to prevent issues
	level += 1
