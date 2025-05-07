extends Area2D

var direction : Vector2
var speed : float = 175

@export var type : Pickups
@export var player_reference : CharacterBody2D:
	set(value):
		player_reference = value
		type.player_reference = value


var can_follow : bool = false

func _ready() -> void:
	$Sprite2D.texture = type.icon #update the texture for the Sprite2D when the node is ready

func _physics_process(delta: float) -> void:
	if player_reference and can_follow:
		direction = (player_reference.position - position).normalized()
		position += direction * speed * delta #when in range, Pickups will be moving towards the player

func follow(_target : CharacterBody2D): #function follow will set the flag to true
	can_follow = true


func _on_body_entered(body: Node2D) -> void: #after interacting with the player, activate pickupResource and free it from memory
	type.activate()
	queue_free()
