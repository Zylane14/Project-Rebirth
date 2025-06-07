extends Weapon
class_name DamagingArea

@export var angular_speed : float = 10
@export var area : float = 0.5

var angle : float
var projectile_reference

func activate(source, _target, _scene_tree): #activating will reset collision and pulsate the projectile
	SoundManager.play_sfx(sound)
	reset_collision()
	pulsate(_scene_tree)
	
	if not projectile_reference:
		add_to_player(source)

func update(delta): #increase angle and rotate projectile
	angle += angular_speed * delta
	if is_instance_valid(projectile_reference):
		projectile_reference.rotation_degrees = angle
		projectile_reference.damage = damage

func reset():
	if is_instance_valid(projectile_reference): #reset function that will free the projectile node
		projectile_reference.queue_free()

func add_to_player(source): #function to add projectile to the player
	var projectile = projectile_node.instantiate()
	projectile.speed = 0
	projectile.damage = damage
	projectile.source = source
	projectile.scale = Vector2(area,area)
	projectile.z_index = 0
	projectile.weapon = self
	
	projectile.find_child("Sprite2D").texture = texture #properties
	projectile.find_child("CollisionShape2D").shape.radius = 90
	projectile.find_child("Particle").process_material = particle
	projectile.knockback = -40
	projectile_reference = projectile
	
	source.call_deferred("add_child", projectile) #adds projectile to player
	
func reset_collision(): #function to reset collision
	if is_instance_valid(projectile_reference):
		projectile_reference.find_child("CollisionShape2D").disabled = true
		projectile_reference.find_child("CollisionShape2D").disabled = false

func pulsate(tree): #function to pulsate the projectile
	if is_instance_valid(projectile_reference):
		var tween = tree.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(projectile_reference, "scale", Vector2(area + 0.1, area + 0.1), 0.25)
		tween.chain().tween_property(projectile_reference, "scale", Vector2(area,area), 0.25)
		tween.bind_node(projectile_reference)

func upgrade_item():
	if max_level_reached(): #overleveling will make it evolve
		slot.item = evolution
		return
	
	if not is_upgradeable():
		return
	
	var upgrade = upgrades[level - 1]
	
	area += upgrade.area
	cooldown += upgrade.cooldown
	damage += upgrade.damage
	
	level += 1
