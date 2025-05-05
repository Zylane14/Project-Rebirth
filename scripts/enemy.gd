extends CharacterBody2D

#variable to store player reference, direction, and speed
@export var player_reference : CharacterBody2D
var direction : Vector2
var speed : float = 75
var damage : float
var knockback : Vector2 #adds knockback
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


#Enemy moves toward player position
func _physics_process(delta):
	var seperation = (player_reference.position - position).length() #check seperation from player in physics process
	if seperation >= 500 and not elite: #if seperation is more than 500, free them from memory (excluding elite)
		queue_free()
	
	velocity = (player_reference.position - position).normalized() * speed
	knockback = knockback.move_toward(Vector2.ZERO, 1) #knockback decay over time
	velocity += knockback
	
	var collider = move_and_collide(velocity * delta)
	if collider: #apply knockback to bodies colliding with the enemy
		collider.get_collider().knockback = (collider.get_collider().global_position -
		global_position).normalized() * 50
