extends CharacterBody2D

#variable to store player reference, direction, and speed
@export var player_reference : CharacterBody2D
@export var buff_interval := 30.0
@onready var health_bar = $HealthBar
@onready var health_bar_timer = Timer.new()

var damage_popup_node = preload("res://scenes/damage.tscn") #loads the damage popup to the enemy
var direction : Vector2
var speed : float
var damage : float
var max_health: float
var knockback : Vector2 #adds knockback
var seperation : float

var drop = preload("res://scenes/pickups.tscn") #preloads pickup scene

var attack_timer := 0.0
var is_attacking := false

var buff_timer : float = 0.0
var buff_stage: int = 0
var is_dead := false

var hybrid_mode := "ranged"  #or "melee"
var has_done_ranged_attack := false

var health : float:
	set(value):
		health = value
		if health_bar:
			health_bar.value = health
		if health <= 0:
			drop_item()

var elite : bool = false:
	set(value):
		elite = value
		if value:
			$Sprite2D.material = ShaderPool.outline #change elite outline
			scale = Vector2(1.5,1.5) #scales up elite

#variable to store enemy resource that updates Sprite2D
var type : Enemy:
	set(value):
		type = value
		$Sprite2D.texture = value.texture
		$Sprite2D.scale = value.scale
		damage = value.damage
		speed = value.speed
		health = value.health #updates health from resource

var duration : float = 0
var FPS : int = 10

func _hide_health_bar():
	if health_bar:
		health_bar.visible = false
		
func _ready():
	add_child(health_bar_timer)
	health_bar_timer.one_shot = true
	health_bar_timer.wait_time = 1.5
	health_bar_timer.timeout.connect(_hide_health_bar)
	
	if $AnimationPlayer:
		$AnimationPlayer.animation_finished.connect(_on_animation_finished)
	
	if type.enemy_class == Enemy.EnemyClass.HYBRID:
		var mode_switch_timer = Timer.new()
		mode_switch_timer.wait_time = 5.0
		mode_switch_timer.autostart = true
		#mode_switch_timer.timeout.connect(switch_hybrid_mode)
		add_child(mode_switch_timer)
	
#Enemy moves toward player position
func _physics_process(delta):
	if is_dead:
		return  # Stop all processing if dead
		
	animation(delta) #call the animation function to enemy script physics process
	check_seperation(delta)

	if not is_attacking:
		knockback_update(delta)
		play_walk_animation()  #start walk animation while not attacking
	
	if buff_stage < GlobalManager.global_buff_stage:
		buff_stage = GlobalManager.global_buff_stage
		apply_buff(buff_stage)

	attack_timer -= delta
	
	match type.enemy_class:
		Enemy.EnemyClass.MELEE:
			perform_melee_attack()
		Enemy.EnemyClass.RANGED:
			perform_ranged_attack()
		Enemy.EnemyClass.HYBRID:
			if hybrid_mode == "ranged":
				perform_ranged_attack()
			else:
				perform_melee_attack()
		
@warning_ignore("unused_parameter")
func animation(delta): #function animation that will flip sprite in the direction of player
	if (player_reference.position.x - position.x) < 0:
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false

func check_seperation(_delta):
	seperation = (player_reference.position - position).length() #calculate seperations and store in through a function
	if seperation >= 500 and not elite:
		queue_free()
		
	if seperation < player_reference.nearest_enemy_distance: #if any enemy is nearer, it will update the nearest_enemy from enemy to player
		player_reference.nearest_enemy = self

func knockback_update(delta):
	velocity = (player_reference.position - position).normalized() * speed
	knockback = knockback.move_toward(Vector2.ZERO, 1) #knockback decay over time
	velocity += knockback
	var collider = move_and_collide(velocity * delta)
	if collider: #apply knockback to bodies colliding with the enemy
		collider.get_collider().knockback = (collider.get_collider().global_position - global_position).normalized() * 50

#function to instantiate damage popup and add it to scene tree
func damage_popup(amount, modifier = 1.0):
	var popup = damage_popup_node.instantiate()
	popup.text = str(amount * modifier)
	popup.position = position + Vector2(-50,-25)
	if modifier > 1.0:
		#ParticleFX.add_effect("blood", position)
		popup.set("theme_override_colors/font_color", Color.DARK_RED) #change font color to red if modifier > 1.0
	get_tree().current_scene.add_child(popup)

func apply_buff(stage: int):
	var health_multiplier := pow(1.1, stage)   #Health increases by 10% each stage
	var damage_multiplier := pow(1.1, stage)   #Damage increases by 10% each stage
	var speed_multiplier := pow(1.02, stage)   #Speed increases by 2% each stage

	speed = type.speed * speed_multiplier
	damage = type.damage * damage_multiplier
	max_health = type.health * health_multiplier
	
	if elite:
		max_health *= 10.0 #5x more health for elites
		speed *= 1.1 #10% faster
		damage *= 2.5 #2.5x more damage
		
		health = max_health

#function for enemy to take damage
func take_damage(amount):
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate", Color(3, 0.25, 0.25), 0.2)
	tween.chain().tween_property($Sprite2D, "modulate", Color(1, 1, 1), 0.2) #tween modulation for color of the sprite
	tween.bind_node(self) #bind the tween to the enemy itself
	
	var chance = randf()
	var modifier : float = 2.0 if (chance <(1.0 - (1.0/player_reference.luck))) else 1.0 #crit chance of 2x damage depending on luck
	
	damage_popup(amount, modifier)
	health -= amount * modifier #health will get reduced from take damage function
	
# Show and update health bar
	if health_bar:
		if not health_bar.visible:
			health_bar.visible = true
		health_bar.max_value = max_health
		health_bar.value = health
	
	if health_bar_timer.is_stopped():
		health_bar_timer.start()
	else:
		health_bar_timer.stop()
		health_bar_timer.start()

func drop_item():
	if is_dead:
		return  # Prevent duplicate callsx

	is_dead = true  #mark as dead
	
	# Drop a random item if defined
	if type.drops.size() > 0:
		var item = type.drops.pick_random()
		if elite:
			item = load("res://resources/Pickups/Chest.tres")  # Drop chest if elite

		var item_to_drop = drop.instantiate()
		item_to_drop.type = item
		item_to_drop.position = position
		item_to_drop.player_reference = player_reference
		get_tree().current_scene.call_deferred("add_child", item_to_drop)

	#Gold drop chance
	var gold_drop_chance := 0.3  # 50% chance to drop gold
	if randf() < gold_drop_chance:
		var gold_resource = load("res://resources/Pickups/Gold.tres")  # Make sure this exists
		var gold_pickup = drop.instantiate()
		gold_pickup.type = gold_resource
		gold_pickup.position = position + Vector2(randf_range(-16, 16), randf_range(-16, 16))
		gold_pickup.player_reference = player_reference
		get_tree().current_scene.call_deferred("add_child", gold_pickup)

	#End-of-life effects
	disable()

	if has_node("AnimationPlayer"):
		var anim_name = "death_" + type.animation_name
		if $AnimationPlayer.has_animation(anim_name):
			$AnimationPlayer.play(anim_name)
			await $AnimationPlayer.animation_finished

	await set_shader()
	queue_free()

func set_shader_value(value: float):
	$Sprite2D.material.set_shader_parameter("dissolve_value", value)

func set_shader():
	$Sprite2D.material = ShaderPool.burn.duplicate() #load the shader
	$Sprite2D.material.set_shader_parameter("dissolve_texture", type.texture)
	
	var tween = get_tree().create_tween()
	tween.tween_method(set_shader_value, 1.0, 0.0, 0.4) #tween the dissolve value
	await tween.finished

func disable(): #disable functionality of the enemy
	speed = 0
	$CollisionShape2D.set_deferred("disabled", true)
	knockback = Vector2.ZERO

#Enemy Attack Function
func perform_melee_attack():
	if attack_timer > 0 or is_attacking:
		return

	if position.distance_to(player_reference.position) <= type.attack_range:
		if has_node("AnimationPlayer"):
			var anim_name = "melee_attack_" + type.animation_name
			if $AnimationPlayer.has_animation(anim_name):
				is_attacking = true
				$AnimationPlayer.play(anim_name)
				attack_timer = type.attack_cooldown

#Ranged
func perform_ranged_attack():
	if attack_timer > 0 or is_attacking or has_done_ranged_attack or not is_instance_valid(player_reference):
		return

	var attack_range = type.ranged_attack_range if type.enemy_class == Enemy.EnemyClass.HYBRID else 300.0

	if position.distance_to(player_reference.position) <= attack_range:
		if has_node("AnimationPlayer"):
			var anim_name = "range_attack_" + type.animation_name
			if $AnimationPlayer.has_animation(anim_name):
				is_attacking = true
				$AnimationPlayer.play(anim_name) 
				attack_timer = type.attack_cooldown
				has_done_ranged_attack = true  # Lock out further ranged attacks
				hybrid_mode = "melee"  # Switch to melee after attack

func _on_animation_finished(anim_name: String): #To Reset the Attack State
	if anim_name.begins_with("melee_attack_") or anim_name.begins_with("range_attack_"):
		is_attacking = false
		

#Hybrid
func switch_hybrid_mode():
	hybrid_mode = "melee" if hybrid_mode == "ranged" else "ranged"
	
func do_melee_hit():
	if player_reference and position.distance_to(player_reference.position) <= type.attack_range:
		if player_reference.has_method("take_damage"):
			player_reference.take_damage(type.damage)

func spawn_projectile():
	if type.projectile_scene and is_instance_valid(player_reference):
		var projectile = type.projectile_scene.instantiate()

		if type.projectile_spawns_at_player:
			# Poison vial: spawns directly at the player's position
			projectile.global_position = player_reference.global_position
		else:
			# Fireball or other ranged projectile: launch from enemy toward player
			projectile.global_position = global_position
			projectile.direction = (player_reference.global_position - global_position).normalized()

		projectile.player_reference = player_reference
		get_tree().current_scene.add_child(projectile)
		
		#projectile.global_position = player_reference.global_position  # Spawns at player
		
func play_walk_animation():
	if not $AnimationPlayer:
		return

	var walk_anim = "walk_" + type.animation_name
	if $AnimationPlayer.has_animation(walk_anim):
		$AnimationPlayer.play(walk_anim)
