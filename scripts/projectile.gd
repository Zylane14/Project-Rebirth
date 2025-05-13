extends Area2D

#projectile direction, speed, and damage
var direction : Vector2 = Vector2.RIGHT
var speed : float = 200
var damage : float = 1
var source #variable source in the projectile scene

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.has_method("take_damage"): #call take_damage function
		if "might" in source:
			body.take_damage(damage * source.might) #if source has property might, multiply the damage
		else	:
			body.take_damage(damage)
		
		body.knockback += direction * 25 #knockback to body from projectiles


func _on_screen_exited():
	queue_free() #frees the projectile when it leaves the screen
 


func _on_area_entered(area: Area2D) -> void: #call the take_damage function
	if area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(damage)
