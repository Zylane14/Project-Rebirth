extends CharacterBody2D


var speed : float = 150
var health : float = 100: #makes health a setter variable to updates progress bar
	set(value):
		health = value
		%Health.value = value

var nearest_enemy : CharacterBody2D
var nearest_enemy_distance : float = INF

#variable to store XP and total XP
var XP : int = 0:
	set(value): #make XP a setter var to update XP value
		XP = value
		%XP.value = value
var total_XP : int = 0
var level : int = 1: #variable to store player level
	set(value):
		level = value
		%Level.text = "Lv " + str(value)
		
		if level >= 3:
			%XP.max_value = 20 #available to change max value when needed after certain level
		elif level >= 7:
			%XP.max_value = 40


func _physics_process(delta):
	if is_instance_valid(nearest_enemy):
		nearest_enemy_distance = nearest_enemy.seperation #if nearest enemy is not null, sotre its seperation
		print(nearest_enemy.name)
	else:
		nearest_enemy_distance = INF #else set default value to infinite
	
	velocity = Input.get_vector("left","right","up","down") * speed
	move_and_collide(velocity * delta)
	check_XP()


#function to reduce health
func take_damage(amount):
	health -= amount
	print(amount)


func _on_self_damage_body_entered(body):
	take_damage(body.damage) #reduce health with enemy damage


func _on_timer_timeout(): #disable and enable with each timeout
	%Collision.set_deferred("disabled", true)
	%Collision.set_deferred("disabled", false)

func gain_XP(amount): #function to gain XP
	XP += amount
	total_XP += amount

func check_XP(): #function to check XP and increase level
	if XP > %XP.max_value:
		XP -= %XP.max_value
		level += 1


func _on_magnet_area_entered(area: Area2D) -> void:
	if area.has_method("follow"): #call the follow function from pickup
		area.follow(self)
