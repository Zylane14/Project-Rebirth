extends Weapon
class_name Circular

@export var angular_speed = 20 #for circular motions (3)
@export var radius = 20
@export var amount = 1

var projectile_reference : Array[Area2D] #array to store every rotating projectile reference
var angle : float #angle of rotation

func activate(source, _target, _scene_tree):
	reset() #free up previous projectile before adding new ones
	
	for i in range(amount):
		add_to_player(source) #activating this weapon will add projectile to player (source)


func add_to_player(source):
	var projectile = projectile_node.instantiate()
	
	projectile.speed = 0
	projectile.damage = damage #properties of the projectile
	projectile.source = source
	projectile.find_child("Sprite2D").texture = texture #set texture to sprite2d for bullets
	projectile.hide()
	projectile.find_child("Particle").process_material = particle
	projectile_reference.append(projectile)
	source.call_deferred("add_child",projectile) #stores reference and add to player (source)


func update(delta):
	angle += angular_speed * delta
	
	for i in range(projectile_reference.size()): #loop over projectile reference
		var offset = i * (360.0/amount)
		
		projectile_reference[i].position = radius * Vector2(cos(deg_to_rad(angle + offset)), sin(deg_to_rad(angle + offset)))

		projectile_reference[i].show()


func reset():
	for i in range(projectile_reference.size()):
		projectile_reference.pop_front().queue_free() #reset func will free all projectiles


func upgrade_item():
	if max_level_reached():
		slot.item = evolution
		return
	
	if not is_upgradeable():
		return
	
	var upgrade = upgrades[level - 1]
	
	angular_speed += upgrade.angular_speed #upgrade function will increase it's properties
	amount += upgrade.amount 
	damage += upgrade.damage
	
	level += 1
