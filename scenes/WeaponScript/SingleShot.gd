extends Weapon
class_name SingleShot

#declares a function shoot
func shoot(source, target, scene_tree):
	if target == null or scene_tree.paused == true: #it will only shoot when it's not paused
		return
	
	SoundManager.play_sfx(sound) #call the sound effect
	var projectile = projectile_node.instantiate() #instantiate the projectile node
	
	projectile.position = source.position #set properties of the projectile with resource data
	projectile.damage = damage
	projectile.speed = speed
	projectile.source = source
	projectile.weapon = self
	projectile.direction = (target.position - source.position).normalized()
	projectile.find_child("Sprite2D").texture = texture
	projectile.find_child("Particle").process_material = particle
	
	projectile.animation_to_play = projectile_animation_name
	
	scene_tree.current_scene.add_child(projectile) #add to the scene tree
	
#overried the activate function and call shoot
func activate(source, target, scene_tree):
	if not can_attack():
		return

	shoot(source, target, scene_tree)
	cooldown_timer = cooldown 
	
func upgrade_item():
	if max_level_reached(): #if the item gets upgraded even if it reaches max lvl, then evolve the item
		slot.item = evolution
		return
	
	if not is_upgradeable():
		return
	
	var upgrade = upgrades[level - 1]
	
	damage += upgrade.damage
	cooldown += upgrade.cooldown
	speed += upgrade.speed
	
	level += 1
