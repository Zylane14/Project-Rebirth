extends Area2D

@export var speed: float = 300.0
var direction := Vector2.ZERO
var damage: float = 0.0
var player_reference: CharacterBody2D

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body == player_reference:
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()

@warning_ignore("unused_parameter")
func _process(delta):
	if not get_viewport_rect().has_point(global_position):
		queue_free()
