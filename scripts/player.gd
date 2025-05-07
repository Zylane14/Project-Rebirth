extends CharacterBody2D


var speed : float = 150
var health : float = 100: #makes health a setter variable to updates progress bar
	set(value):
		health = value
		%Health.value = value

var nearest_enemy : CharacterBody2D
var nearest_enemy_distance : float = INF

func _physics_process(delta):
	if is_instance_valid(nearest_enemy):
		nearest_enemy_distance = nearest_enemy.seperation #if nearest enemy is not null, sotre its seperation
		print(nearest_enemy.name)
	else:
		nearest_enemy_distance = INF #else set default value to infinite
	
	velocity = Input.get_vector("left","right","up","down") * speed
	move_and_collide(velocity * delta)


#function to reduce health
func take_damage(amount):
	health -= amount
	print(amount)


func _on_self_damage_body_entered(body):
	take_damage(body.damage) #reduce health with enemy damage


func _on_timer_timeout(): #disable and enable with each timeout
	%Collision.set_deferred("disabled", true)
	%Collision.set_deferred("disabled", false)
