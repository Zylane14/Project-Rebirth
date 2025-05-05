extends CharacterBody2D

#variable to store player reference, direction, and speed
@export var player_reference : CharacterBody2D
var direction : Vector2
var speed : float = 75


#Enemy moves toward player position
func _physics_process(delta):
	velocity = (player_reference.position - position).normalized() * speed
	move_and_collide(velocity * delta)
