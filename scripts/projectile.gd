extends Area2D

#projectile direction, speed, and damage
var direction : Vector2 = Vector2.RIGHT
var speed : float = 200
var damage : float = 1

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"): #call take_damage function
		body.take_damage(damage)
		body.knockback += direction * 25 #knockback to body from projectiles


func _on_screen_exited():
	queue_free() #frees the projectile when it leaves the screen
 
