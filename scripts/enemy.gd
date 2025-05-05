extends CharacterBody2D

#variable to store player reference, direction, and speed
@export var player_reference : CharacterBody2D
var direction : Vector2
var speed : float = 75
var damage : float
var elite : bool = false:
	set(value):
		elite = value
		if value:
			$Sprite2D.material = load("res://shaders/red.tres") #change elite outline
			scale = Vector2(1.5,1.5) #scales up elite


#variable to store enemy resource that updates Sprite2D
var type : Enemy:
	set(value):
		type = value
		$Sprite2D.texture = value.texture
		damage = value.damage


#Enemy moves toward player position
func _physics_process(delta):
	velocity = (player_reference.position - position).normalized() * speed
	move_and_collide(velocity * delta)
