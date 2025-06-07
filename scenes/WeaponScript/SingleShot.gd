extends Weapon
class_name SingleShotd

#declares a function shoot
func shoot(source, target, scene_tree):
	if target == null or scene_tree.paused == true: #it will only shoow when it's not paused
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
	
	scene_tree.current_scene.add_child(projectile) #add to the scene tree
	
#overried the activate function and call shoot
func activate(source, target, scene_tree):
	shoot(source, target, scene_tree)
	
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
