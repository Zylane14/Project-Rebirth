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
var knockback : Vector2 = Vector2.ZERO #adds knockback
var seperation : float

var drop = preload("res://scenes/pickups.tscn") #preloads pickup scene

var attack_timer := 0.0
var is_attacking := false
var has_dealt_hit: bool = false

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
		update_sprite_visuals()

var type : Enemy:
	set(value):
		type = value
		damage = value.damage
		speed = value.speed
		health = value.health
		update_sprite_visuals()

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

		add_child(mode_switch_timer)

func _physics_process(delta):
	if is_dead:
		return  # Stop all processing if dead
		
	animation(delta)
	check_seperation(delta)

	if not is_attacking:
		knockback_update(delta)
		play_walk_animation()
	else:
		self.velocity = Vector2.ZERO  # Stop movement while attacking
	
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
	
	move_and_slide()

func animation(_delta):
	if (player_reference.position.x - position.x) < 0:
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false

func check_seperation(_delta):
	seperation = (player_reference.position - position).length()
	if seperation >= 500 and not elite:
		queue_free()
	
	if seperation < player_reference.nearest_enemy_distance:
		player_reference.nearest_enemy = self

func knockback_update(delta):
	var move_dir = (player_reference.position - position).normalized() * speed
	
	#decay knockback over time
	knockback = knockback.move_toward(Vector2.ZERO, 15 * delta)
	
	#clamp knockback strength
	var max_knockback_strength := 30.0
	if knockback.length() > max_knockback_strength:
		knockback = knockback.normalized() * max_knockback_strength
	
	self.velocity = move_dir + knockback

func damage_popup(amount: float, modifier: float = 1.0, is_crit: bool = false):
	var popup = damage_popup_node.instantiate()
	var final_damage = int(amount * modifier)
	popup.text = str(final_damage)
	popup.position = position + Vector2(-50, -25)

	if is_crit:
		popup.add_theme_color_override("font_color", Color.DARK_RED)
	else:
		popup.add_theme_color_override("font_color", Color.WHITE)

	get_tree().current_scene.add_child(popup)


func apply_buff(stage: int):
	var health_multiplier := pow(1.1, stage)
	var damage_multiplier := pow(1.1, stage)
	var speed_multiplier := pow(1.02, stage)

	speed = type.speed * speed_multiplier
	damage = type.damage * damage_multiplier
	max_health = type.health * health_multiplier
	
	if elite:
		max_health *= 3.5
		speed *= 1.1
		damage *= 2.0
		health = max_health

func take_damage(amount):
	# Flash red
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate", Color(3, 0.25, 0.25), 0.2)
	tween.chain().tween_property($Sprite2D, "modulate", Color(1, 1, 1), 0.2)
	tween.bind_node(self)

	# Determine critical hit
	var crit_chance: float = player_reference.crit / 100.0
	var is_crit: bool = randf() < crit_chance

	var final_damage: float = amount
	if is_crit:
		final_damage *= (1.0 + player_reference.crit_damage / 100.0)

	var knockback_strength = 100.0  # tweakable
	var dir = (position - player_reference.position).normalized()
	knockback += dir * knockback_strength
	
	damage_popup(final_damage, 1.0, is_crit)
	health = clamp(health - final_damage, 0, max_health)



	# Update health bar
	if health_bar:
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
		return

	is_dead = true
	GlobalManager.enemy_kill_count += 1
	
	var item_variant: Variant = null

	if elite:
		var base_chance: float = 0.1
		var luck_multiplier: float = clamp(player_reference.luck / 100.0, 0.0, 1.0)
		var final_chance: float = base_chance + (0.7 * luck_multiplier)  # max 80%

		if randf() < final_chance:
			item_variant = load("res://resources/Pickups/Chest.tres")
		else:
			@warning_ignore("static_called_on_instance")
			item_variant = Drops.pick_weighted_drop(type.drops, player_reference.luck)
	else:
		@warning_ignore("static_called_on_instance")
		item_variant = Drops.pick_weighted_drop(type.drops, player_reference.luck)

	if item_variant:
		var item := item_variant as Pickups
		if item:
			var item_to_drop = drop.instantiate()
			item_to_drop.type = item
			item_to_drop.position = position
			item_to_drop.player_reference = player_reference
			get_tree().current_scene.call_deferred("add_child", item_to_drop)

	# gold drop
	var gold_drop_chance := 0.3
	if randf() < gold_drop_chance:
		var gold_resource = load("res://resources/Pickups/Gold.tres") as Pickups
		var gold_pickup = drop.instantiate()
		gold_pickup.type = gold_resource
		gold_pickup.position = position + Vector2(randf_range(-16, 16), randf_range(-16, 16))
		gold_pickup.player_reference = player_reference
		get_tree().current_scene.call_deferred("add_child", gold_pickup)

	disable()

	if has_node("AnimationPlayer"):
		var anim_name = "death_" + type.animation_name
		if $AnimationPlayer.has_animation(anim_name):
			$AnimationPlayer.play(anim_name)
			await $AnimationPlayer.animation_finished
			
	await set_shader()
	queue_free()

func update_sprite_visuals():
	if type:
		var scale_multiplier = 1.5 if elite else 1.0
		$Sprite2D.texture = type.texture
		$Sprite2D.scale = type.scale * scale_multiplier
		if elite:
			$Sprite2D.material = ShaderPool.outline
			
func set_shader_value(value: float):
	$Sprite2D.material.set_shader_parameter("dissolve_value", value)

func set_shader():
	$Sprite2D.material = ShaderPool.burn.duplicate()
	$Sprite2D.material.set_shader_parameter("dissolve_texture", type.texture)
	
	var tween = get_tree().create_tween()
	tween.tween_method(set_shader_value, 1.0, 0.0, 0.4)
	await tween.finished

func disable():
	speed = 0
	$CollisionShape2D.set_deferred("disabled", true)
	knockback = Vector2.ZERO

func perform_melee_attack():
	if attack_timer > 0 or is_attacking:
		return

	if position.distance_to(player_reference.position) <= type.attack_range and has_node("AnimationPlayer"):
		var anim_name = "melee_attack_" + type.animation_name
		if $AnimationPlayer.has_animation(anim_name):
			is_attacking = true
			has_dealt_hit = false               
			$AnimationPlayer.play(anim_name)
			attack_timer = type.attack_cooldown


func perform_ranged_attack():
	if attack_timer > 0 or is_attacking or has_done_ranged_attack or not is_instance_valid(player_reference):
		return

	var attack_range = type.ranged_attack_range if type.enemy_class == Enemy.EnemyClass.HYBRID else 300.0
	
	if position.distance_to(player_reference.position) <= attack_range and has_node("AnimationPlayer"):
		var anim_name = "range_attack_" + type.animation_name
		if $AnimationPlayer.has_animation(anim_name):
			is_attacking = true
			has_dealt_hit = false             
			$AnimationPlayer.play(anim_name)
			attack_timer = type.attack_cooldown
			has_done_ranged_attack = true
			hybrid_mode = "melee"


func _on_animation_finished(anim_name: String):
	if anim_name.begins_with("melee_attack_") or anim_name.begins_with("range_attack_"):
		is_attacking = false
		has_dealt_hit = false
		if anim_name.begins_with("range_attack_"):
			has_done_ranged_attack = false


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
			projectile.global_position = player_reference.global_position
		else:
			projectile.global_position = global_position
			projectile.direction = (player_reference.global_position - global_position).normalized()

		projectile.player_reference = player_reference
		get_tree().current_scene.add_child(projectile)

func play_walk_animation():
	if not $AnimationPlayer:
		return

	var walk_anim = "walk_" + type.animation_name
	if $AnimationPlayer.has_animation(walk_anim):
		$AnimationPlayer.play(walk_anim)
