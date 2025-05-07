extends CharacterBody2D

#variable to store player reference, direction, and speed
@export var player_reference : CharacterBody2D
var damage_popup_node = preload("res://scenes/damage.tscn") #loads the damage popup to the enemy
var direction : Vector2
var speed : float = 75
var damage : float
var knockback : Vector2 #adds knockback
var seperation : float

var drop = preload("res://scenes/pickups.tscn") #preloads pickup scene

var health : float:
	set(value):
		health = value
		if health <= 0: #when health reaches 0, free the enemy from memory
			drop_item() #enemy will drop item when hp reaches 0
			queue_free()

var elite : bool = false:
	set(value):
		elite = value
		if value:
			$Sprite2D.material = load("res://shaders/Red.tres") #change elite outline
			scale = Vector2(1.5,1.5) #scales up elite


#variable to store enemy resource that updates Sprite2D
var type : Enemy:
	set(value):
		type = value
		$Sprite2D.texture = value.texture
		damage = value.damage
		health = value.health #updates health from resource


#Enemy moves toward player position
func _physics_process(delta):
	check_seperation(delta)
	knockback_update(delta)


func check_seperation(_delta):
	seperation = (player_reference.position - position).length() #calculate seperations and store in through a function
	if seperation >= 500 and not elite:
		queue_free()
		
	if seperation < player_reference.nearest_enemy_distance: #if any enemy is nearer, it will update the nearest_enemy from enemy to player
		player_reference.nearest_enemy = self



func knockback_update(delta):
	velocity = (player_reference.position - position).normalized() * speed
	knockback = knockback.move_toward(Vector2.ZERO, 1) #knockback decay over time
	velocity += knockback
	var collider = move_and_collide(velocity * delta)
	if collider: #apply knockback to bodies colliding with the enemy
		collider.get_collider().knockback = (collider.get_collider().global_position -
		global_position).normalized() * 50


#function to instantiate damage popup and add it to scene tree
func damage_popup(amount):
	var popup = damage_popup_node.instantiate()
	popup.text = str(amount)
	popup.position = position + Vector2(-50,-25)
	get_tree().current_scene.add_child(popup)


#function for enemy to take damage
func take_damage(amount):
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate", Color(3, 0.25, 0.25), 0.2)
	tween.chain().tween_property($Sprite2D, "modulate", Color(1, 1, 1), 0.2) #tween modulation for color of the sprite
	tween.bind_node(self) #bind the tween to the enemy itself
	
	damage_popup(amount)
	health -= amount #health will get reduced from take damage function

func drop_item():
	if type.drops.size() == 0:
		return 
	
	var item = type.drops.pick_random() #function to drop item, first pick a random pickups from the array
	
	var item_to_drop = drop.instantiate() #instantiate pickup node, set resource and reference
	
	item_to_drop.type = item
	item_to_drop.position = position
	item_to_drop.player_reference = player_reference
	
	get_tree().current_scene.call_deferred("add_child", item_to_drop) #add to scene tree
  
