extends Area2D

#projectile direction, speed, and damage
var direction : Vector2 = Vector2.RIGHT
var speed : float = 200
var damage : float = 1
var knockback : float = 90
var source #variable source in the projectile scene
var weapon : Weapon #property to store weapon resource in projectile

func _physics_process(delta):
	position += direction * speed * delta
	rotation = direction.angle()

func _on_body_entered(body):
	if body.has_method("take_damage"): #call take_damage function
		if "might" in source:
			body.take_damage(damage * source.might) #if source has property might, multiply the damage
			if weapon:
				weapon.damage_dealt += damage * source.might #damage will get added & stored in their weapon resource
		else:
			body.take_damage(damage)
			if weapon:
				weapon.damage_dealt += damage
		
		body.knockback += direction * knockback #knockback to body from projectiles


func _on_screen_exited():
	queue_free() #frees the projectile when it leaves the screen
 


func _on_area_entered(area: Area2D) -> void: #call the take_damage function
	if area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(damage)
