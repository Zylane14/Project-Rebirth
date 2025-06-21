extends Area2D

@export var damage: float = 50.0
@export var knockback_strength: float = 400.0  # adjust per attack type

@onready var parent = get_parent()  # assumes enemy is the parent

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)

	if body.has_method("apply_knockback"):
		var dir = (body.global_position - global_position).normalized()
		body.apply_knockback(dir * knockback_strength)
