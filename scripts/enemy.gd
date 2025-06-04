extends CharacterBody2D

#variable to store player reference, direction, and speed
@export var player_reference : CharacterBody2D
var damage_popup_node = preload("res://scenes/damage.tscn") #loads the damage popup to the enemy
var direction : Vector2
var speed : float
var damage : float
var knockback : Vector2 #adds knockback
var seperation : float

var drop = preload("res://scenes/pickups.tscn") #preloads pickup scene

var health : float:
	set(value):
		health = value
		if health <= 0: #when health reaches 0, free the enemy from memory
			drop_item() #enemy will drop item when hp reaches 0

var elite : bool = false:
	set(value):
		elite = value
		if value:
			$Sprite2D.material = ShaderPool.outline #change elite outline
			scale = Vector2(1.5,1.5) #scales up elite


#variable to store enemy resource that updates Sprite2D
var type : Enemy:
	set(value):
		type = value
		$Sprite2D.texture = value.texture
		$Sprite2D.hframes = value.frames
		damage = value.damage
		speed = value.speed
		health = value.health #updates health from resource

var duration : float = 0
var FPS : int = 10


#Enemy moves toward player position
func _physics_process(delta):
	animation(delta) #call the animation function to enemy script physics process
	check_seperation(delta)
	knockback_update(delta)

func animation(delta): #function animation that will flip sprite in the direction of player
	if (player_reference.position.x - position.x) < 0:
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false
	
	if type.frames <= 1: #return function if frames are still 1
		return
	
	duration += delta
	if type.frames > 1 and duration >= 1.0/FPS: #else increase frame with resepect to FPS
		$Sprite2D.frame = ($Sprite2D.frame + 1) % type.frames
		duration = 0

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
func damage_popup(amount, modifier = 1.0):
	var popup = damage_popup_node.instantiate()
	popup.text = str(amount * modifier)
	popup.position = position + Vector2(-50,-25)
	if modifier > 1.0:
		ParticleFX.add_effect("blood", position)
		popup.set("theme_override_colors/font_color", Color.DARK_RED) #change font color to red if modifier > 1.0
	get_tree().current_scene.add_child(popup)


#function for enemy to take damage
func take_damage(amount):
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate", Color(3, 0.25, 0.25), 0.2)
	tween.chain().tween_property($Sprite2D, "modulate", Color(1, 1, 1), 0.2) #tween modulation for color of the sprite
	tween.bind_node(self) #bind the tween to the enemy itself
	
	var chance = randf()
	var modifier : float = 2.0 if (chance <(1.0 - (1.0/player_reference.luck))) else 1.0 #crit chance of 2x damage depending on luck
	
	damage_popup(amount, modifier)
	health -= amount * modifier #health will get reduced from take damage function

func drop_item():
	if type.drops.size() == 0:
		return 
	
	var item = type.drops.pick_random() #function to drop item, first pick a random pickups from the array
	if elite:
		item = load("res://resources/Pickups/Chest.tres") #item drop will be a chest if it's an elite enemy
	
	
	var item_to_drop = drop.instantiate() #instantiate pickup node, set resource and reference
	
	item_to_drop.type = item
	item_to_drop.position = position
	item_to_drop.player_reference = player_reference
	
	get_tree().current_scene.call_deferred("add_child", item_to_drop) #add to scene tree
	
	disable()
	await set_shader()
	queue_free() 

func set_shader_value(value: float):
	$Sprite2D.material.set_shader_parameter("dissolve_value", value)

func set_shader():
	$Sprite2D.material = ShaderPool.burn.duplicate() #load the shader
	$Sprite2D.material.set_shader_parameter("dissolve_texture", type.texture)
	
	var tween = get_tree().create_tween()
	tween.tween_method(set_shader_value, 1.0, 0.0, 0.4) #tween the dissolve value
	await tween.finished

func disable(): #disable functionality of the enemy
	speed = 0
	$CollisionShape2D.set_deferred("disabled", true)
