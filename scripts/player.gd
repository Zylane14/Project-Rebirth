extends CharacterBody2D

@export var character : Character #variable to store character

var health : float = 100: #makes health a setter variable to updates progress bar
	set(value):
		health = max(value, 0) #minimum value of health should be 0
		%Health.value = value
		if health <= 0:
			die() #pause the game when health reaches 0

var movement_speed : float = 150
var max_health : float = 100: #property for max_health
	set(value):
		max_health = value
		%Health.max_value = value #setter variable to change max value of the progress bar
var recovery : float = 0:
	set(value):
		recovery = value
		%Recovery.text = "Recovery : " + str(value)
var armor : float = 0: #armor property
	set(value):
		armor = value
		%Armor.text = "Armor : " + str(value)
var might : float = 1.0: #amplify attack
	set(value):
		might = value
		%Might.text = "Might : " + str(value)
var area : float = 0: #attack range
	set(value):
		area = value
		%Area.text = "Area : " + str(value)
var magnet : float = 0: #pickup range
	set(value):
		magnet = value
		%Magnet.shape.radius = 50 + value
		%MagnetL.text = "Magnet : " + str(value)
var growth : float = 1: #growth property
	set(value):
		area = value
		%AmplifyAttack.text = "Amplify Attack : " + str(value)
var luck : float = 2.5:
	set(value):
		luck = value
		%Luck.text = "Luck : " + str(value)


var nearest_enemy
var nearest_enemy_distance : float = 150 + area #default distance, minimum + area

var gold : int = 0:
	set(value):
		gold = value
		%Gold.text = "Gold : " + str(value) #setter variable gold that updates the label

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
		%Options.show_option() #during level up, show option
		
		if level >= 3:
			%XP.max_value = 20 #available to change max value when needed after certain level
		elif level >= 7:
			%XP.max_value = 40


func _ready() -> void:
	
	Persistence.gain_bonus_stats(self) #call the gain bonus stats from persistence when the player node is ready
	character = Persistence.character #set character, base stats, add starting weapon on ready
	set_base_stats(character.base_stats)
	%Options.check_item(character.starting_weapon) #adds weapon if not available

func _physics_process(delta):
	if is_instance_valid(nearest_enemy):
		nearest_enemy_distance = nearest_enemy.seperation #if nearest enemy is not null, sotre its seperation
		print(nearest_enemy.name)
	else:
		nearest_enemy_distance = 150 + area #update nearest distance in physics process
		nearest_enemy = null #for resetting reference
	
	velocity = Input.get_vector("left","right","up","down") * movement_speed
	move_and_collide(velocity * delta)
	
	check_XP()
	animation(delta)
	health += recovery * delta #increase health with recovery * delta


#function to reduce health
func take_damage(amount):
	health -= max(amount * (amount/(amount + armor)), 1) #making defense additive


func _on_self_damage_body_entered(body):
	take_damage(body.damage) #reduce health with enemy damage

func die():
	$AnimationPlayer.play("death_" + character.animation_name)
	set_process(false) # disables _process
	set_physics_process(false) # disables _physics_process
	$Sprite2D.visible = true # ensure sprite is visible
	await $AnimationPlayer.animation_finished
	

func _on_timer_timeout(): #disable and enable with each timeout
	%Collision.set_deferred("disabled", true)
	%Collision.set_deferred("disabled", false)

func gain_XP(amount): #function to gain XP
	XP += amount * growth
	total_XP += amount * growth

func check_XP(): #function to check XP and increase level
	if XP > %XP.max_value:
		XP -= %XP.max_value
		level += 1


func _on_magnet_area_entered(pickup_area):
	if pickup_area.has_method("follow"): #call the follow function from pickup
		pickup_area.follow(self)

func gain_gold(amount): #function to gain gold
	gold += amount

func open_chest(): #function to call open from player
	$UI/Chest.open()

func animation(_delta): #plays the character animation
	if velocity == Vector2.ZERO:
		$AnimationPlayer.play("idle_" + character.animation_name)
	else:
		$AnimationPlayer.play("walk_" + character.animation_name)
	
	if velocity.x < 0: #flipping sprites according to movement direction
		$Sprite2D.flip_h = true
	elif velocity.x > 0:
		$Sprite2D.flip_h = false

func set_base_stats(base_stats : Stats): #function to gain base stats from the character
	max_health += base_stats.max_health
	recovery += base_stats.recovery
	armor += base_stats.armor
	movement_speed += base_stats.movement_speed
	might += base_stats.might
	area += base_stats.area
	magnet += base_stats.magnet
	growth += base_stats.growth
	luck += base_stats.luck
	
func _on_back_pressed() -> void:
	pass # Replace with function body.
