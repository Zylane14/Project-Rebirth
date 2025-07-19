extends Area2D

@export var damage : float = 20.0
@export var lifetime : float = 1.0 # How long the projectile stays
var player_reference : CharacterBody2D

var direction: Vector2 = Vector2.ZERO 

func _ready():
	# Play animation if it exists
	if $AnimatedSprite2D.sprite_frames.has_animation("poison"):
		$AnimatedSprite2D.play("poison")

	# Auto-remove after `lifetime`
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _on_body_entered(body):
	if body != player_reference and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
