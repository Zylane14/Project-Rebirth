extends Area2D

@export var type: Pickups
@export var player_reference: CharacterBody2D:
	set(value):
		player_reference = value
		if type:
			type.player_reference = value

var direction: Vector2
var speed: float = 200
var can_follow: bool = false
var recoil_timer := 0.0
var recoil_duration := 0.25  # time before it starts following
var recoil_vector := Vector2.ZERO
var current_speed := 0.0
var max_speed := 600.0
var acceleration := 800.0


func _ready():
	var sprite = $AnimatedSprite2D

	if type:
		sprite.scale = type.scale

		if type.frames:
			sprite.frames = type.frames
			sprite.animation = type.animation_name
			sprite.play()
		else:
			print("Warning: No frames assigned to", type.title)

func _physics_process(delta):
	if recoil_timer > 0.0:
		# Apply recoil motion away from the player
		position += recoil_vector * delta
		recoil_timer -= delta
		return

	if player_reference and can_follow:
		direction = (player_reference.position - position).normalized()
		current_speed = min(current_speed + acceleration * delta, max_speed)
		position += direction * current_speed * delta


func follow(_target: CharacterBody2D, gem_flag := false):
	if type is Chest:
		return

	if recoil_timer > 0.0 or can_follow:
		# Already recoiling or following, don't trigger again
		return

	# Recoil setup: push away from player only once
	recoil_timer = recoil_duration
	recoil_vector = (position - _target.position).normalized() * 125.0


	can_follow = true



func _on_body_entered(_fbody):
	type.activate()
	queue_free()
