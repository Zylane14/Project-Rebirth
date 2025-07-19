extends Area2D

@export var type: Pickups
@export var player_reference: CharacterBody2D:
	set(value):
		player_reference = value
		if type:
			type.player_reference = value

var direction: Vector2
var speed: float = 175
var can_follow: bool = false

func _ready():
	var sprite = $AnimatedSprite2D

	if type.frames:
		sprite.frames = type.frames
		sprite.animation = type.animation_name
		sprite.play()
	else:
		print("Warning: No frames assigned to", type.title)

func _physics_process(delta):
	if player_reference and can_follow:
		direction = (player_reference.position - position).normalized()
		position += direction * speed * delta

func follow(_target: CharacterBody2D, gem_flag := false):
	if type is Chest:
		return

	if gem_flag and type is Gem:
		can_follow = true
		return

	can_follow = true

func _on_body_entered(_fbody):
	type.activate()
	queue_free()
