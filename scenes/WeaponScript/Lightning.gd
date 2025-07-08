extends Weapon
class_name Lightning

@export var amount = 1
var projectiles = []

func activate(source, _target, scene_tree):
	if scene_tree.paused == true:
		return
	
	shoot(source, scene_tree) #activating it will call the shoot function


func shoot(source : CharacterBody2D, scene_tree : SceneTree):
	var enemies = source.get_tree().get_nodes_in_group("Enemy") #in shoot func, get all the enemies 
	
	if enemies.size() == 0: #if no enemy, then return
		return
	
	SoundManager.play_sfx(sound)
	for i in range(amount):
			var enemy = enemies.pick_random() #pick a randon enemy

			var projectile = projectile_node.instantiate() #instantiate the projectile node
			projectile.speed = 0
			projectile.damage = damage
			projectile.source = source
			projectile.position = enemy.position #set properties and target position
			projectile.z_index = 1
			projectile.weapon = self
		
			projectile.find_child("Sprite2D").texture = texture
			projectile.find_child("Particle").process_material = particle
			
			var sprite = projectile.find_child("Sprite2D")

			if randi() % 2 == 0:
				sprite.flip_h = true
			
			projectile.animation_to_play = projectile_animation_name
			
			projectiles.append(projectile) #texture and reference of the projectile
		
			scene_tree.current_scene.add_child(projectile) #add projectile to the scene tree
	
	await scene_tree.create_timer(0.5).timeout #it will stay on screen for 0.5 then free it
	for i in range(projectiles.size()):
		var temp = projectiles.pop_front()
		if is_instance_valid(temp):
			temp.queue_free()


func upgrade_item():
	if max_level_reached():
		slot.item = evolution
		return
	
	if not is_upgradeable():
		return
	
	var upgrade = upgrades[level - 1]
	
	amount += upgrade.amount #for lightning upgrades
	damage += upgrade.damage
	cooldown += upgrade.cooldown
	
	level += 1
