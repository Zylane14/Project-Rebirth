extends CharacterBody2D

@export var character : Character #variable to store character
@export var ghost_node : PackedScene
@onready var ghost_timer: Timer = $GhostTimer

@export var dash_distance := 180.0
@export var dash_duration := 0.4
@export var dash_cooldown := 0.3

var can_dash := true
var last_move_dir := Vector2.RIGHT  # Default to RIGHT or any direction you prefer

var health : float = 100: #makes health a setter variable to updates progress bar
	set(value):
		health = max(value, 0) #minimum value of health should be 0
		%Health.value = value
		if health <= 0:
			die() #pause the game when health reaches 0
			show_game_over_screen()

var movement_speed : float = 120:
	set(value):
		movement_speed = value
		%MovementSpeed.text = "Movement Speed : " + str(value)
	
var max_health : float = 100:
	set(value):
		var delta = value - max_health
		max_health = value
		%Health.max_value = value
		%HealthMax.text = "Max Health : " + str(value)
		
		if delta > 0:
			# Optionally heal proportionally to new max
			health += delta
			health = min(health, max_health)
	
var recovery : float = 0:
	set(value):
		recovery = value
		%Recovery.text = "Recovery : " + str(value)
var armor : float = 0: #armor property
	set(value):
		armor = value
		%Armor.text = "Armor : " + str(value)
var amplify : float = 5.0: #amplify attack
	set(value):
		amplify = value
		%Amplify.text = "Amplify : " + str(value)
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
		growth = value
		%Growth.text = "Growth : " + str(value)
var luck : float = 2.5:
	set(value):
		luck = value
		%Luck.text = "Luck : " + str(value)
var dodge : float = 10.0:
	set(value):
		dodge = value
		%Dodge.text = "Dodge : " + str(value)

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

var is_dashing: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
var knockback_duration: float = 0.2

func _ready() -> void:
	Persistence.gain_bonus_stats(self) #call the gain bonus statsbas from persistence when the player node is ready
	character = Persistence.character #set character, base stats, add starting weapon on ready
	
	if character:
		scale = character.scale
		
	set_base_stats(character.base_stats)
	%XP.max_value = get_xp_needed(level)
	
	%Options.check_item(character.starting_weapon) #adds weapon if not available
	update_xp_ui()

func _physics_process(delta):
	if is_dashing:
		return #skip movement during dash
	
	# Knockback overrides normal movement
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity = knockback_velocity
	else:
		velocity = Input.get_vector("left", "right", "up", "down") * movement_speed

	if velocity != Vector2.ZERO:
		last_move_dir = velocity.normalized()

	if is_instance_valid(nearest_enemy):
		nearest_enemy_distance = nearest_enemy.seperation  #if nearest enemy is not null, sotre its seperation
	else:
		nearest_enemy_distance = 150 + area#update nearest distance in physics process
		nearest_enemy = null  #for resetting reference

	move_and_collide(velocity * delta)

	check_XP()
	animation(delta)
	health += recovery * delta

func add_ghost():
	var ghost = ghost_node.instantiate()
	ghost.set_property(position, $Sprite2D.scale)
	get_tree().current_scene.add_child(ghost)

func show_dodge_feedback():
	print("DODGED!")  #replace this with a UI popup or sound
	SoundManager.play_sfx(preload("res://music & sfx/Minifantasy_Dungeon_SFX/18_orc_charge.wav"))


#function to reduce health
func take_damage(amount):
	if randf() * 100 < dodge:
		show_dodge_feedback()
		return  # damage is dodged, exit early

	# Basic armor calculation — reducing damage with diminishing returns
	var reduced_damage = max(amount * (amount / (amount + armor)), 1)
	health -= reduced_damage
	

func apply_knockback(force: Vector2):
	if is_dashing:
		return  # Don't get knocked back while dashing
	knockback_velocity = force
	knockback_timer = knockback_duration
	
func _on_self_damage_body_entered(body):
	take_damage(body.damage) #reduce health with enemy damage
		
func die():
	$AnimationPlayer.play("death_" + character.animation_name)
	AudioController.bg_music.play()
	$Sprite2D.visible = true # ensure sprite is visible
	get_tree().paused = true
	await $AnimationPlayer.animation_finished
	
func show_game_over_screen():
	await $AnimationPlayer.animation_finished
	var game_over = preload("res://scenes/GameOver.tscn").instantiate()
	add_child(game_over)
	get_tree().paused = true  #pause the game
	

func _on_timer_timeout(): #disable and enable with each timeout
	%Collision.set_deferred("disabled", true)
	%Collision.set_deferred("disabled", false)

func update_xp_ui():
	%XP.max_value = get_xp_needed(level)
	%XP.value = XP
	%XPLabel.text = "XP: %d / %d" % [XP, get_xp_needed(level)]
	
func gain_XP(amount): #function to gain XP
	XP += amount * growth
	total_XP += amount * growth
	update_xp_ui()

func check_XP():
	while XP >= get_xp_needed(level):
		XP -= get_xp_needed(level)
		level += 1
	update_xp_ui()

const XP_BASE := 20
const XP_SCALE := 10.0
const XP_EXP := 1.5

func get_xp_needed(lvl: int) -> int:
	return int(XP_BASE + pow(lvl, XP_EXP) * XP_SCALE)
	

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
	amplify += base_stats.amplify
	area += base_stats.area
	magnet += base_stats.magnet
	growth += base_stats.growth
	luck += base_stats.luck
	dodge += base_stats.dodge

func _on_back_pressed() -> void:
	pass # Replace with function body.


func _on_ghost_timer_timeout() -> void:
	add_ghost()

func dash():
	if is_dashing or not can_dash:
		return
	
	is_dashing = true
	can_dash = false
	ghost_timer.start()
	%Collision.set_deferred("disabled", true)
	$AnimationPlayer.play("dash_" + character.animation_name)
	SoundManager.play_sfx(load("res://music & sfx/RPG_Essentials_Free/8_Atk_Magic_SFX/Wind_02.wav"))

	# Normalize direction to avoid scaling issues
	var dash_dir = velocity.normalized()
	if dash_dir == Vector2.ZERO:
		dash_dir = last_move_dir  # fallback if player isn't moving

	var dash_vector = dash_dir * dash_distance
	var target_position = position + dash_vector
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_position, dash_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	%Collision.set_deferred("disabled", false)
	ghost_timer.stop()
	is_dashing = false

	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

func _input(event):
	if event.is_action_pressed("dash"):
		dash()
