extends CharacterBody2D
class_name Player

##==============================
## EXPORTS AND NODE REFERENCES
##==============================
@export var character: Character
@export var ghost_node: PackedScene
@onready var ghost_timer: Timer = $GhostTimer

##==============================
## DASH SETTINGS
##==============================
@export var dash_distance := 180.0
@export var dash_duration := 0.4
@export var dash_cooldown := 0.3
@export var post_dash_invincibility_duration := 0.2

var can_dash := true
var is_dashing := false
var is_invincible: bool = false
var last_move_dir := Vector2.RIGHT
var damage_cooldown = 0.3
var damage_timer = 0.0

##==============================
## HEALTH, STATS, AND UI
##==============================
var health: float = 500.0:
	set(value):
		health = max(value, 0.0)
		%Health.value = int(value)
		if health <= 0:
			die()
			show_game_over_screen()

var max_health: float = 500.0:
	set(value):
		var delta = value - max_health
		max_health = value
		%Health.max_value = int(value)
		%HealthMax.text = "Max Health : " + str(int(value))
		if delta > 0:
			health = min(health + delta, max_health)

var movement_speed: float = 75:
	set(value):
		movement_speed = value
		%MovementSpeed.text = "Movement Speed : " + str(value)

var recovery: float = 1.0:
	set(value):
		recovery = value
		%Recovery.text = "Recovery : " + str(value) + " hp/sec"

var armor: float = 0:
	set(value):
		armor = value
		%Armor.text = "Armor : %.1f" % value + "%"

var damage: int = 1:
	set(value):
		damage = value
		%Damage.text = "Damage : " + str(value)

var amplify: float = 0.1:
	set(value):
		amplify = value
		%Amplify.text = "Amplify : " + str(value) + "%"

var area: float = 0:
	set(value):
		area = value
		%Area.text = "Area : " + str(value)

var magnet: float = 0:
	set(value):
		magnet = value
		%Magnet.shape.radius = 100 + value
		%MagnetL.text = "Magnet : " + str(value)

var growth: float = 1:
	set(value):
		growth = value
		%Growth.text = "Growth : " + str(value) + " exp/rate"

var luck: float = 0.1:
	set(value):
		luck = value
		%Luck.text = "Luck : " + str(value) + "%"

var dodge: float = 1.0:
	set(value):
		dodge = value
		%Dodge.text = "Dodge : " + str(value) + "%"

var crit: float = 5.0:
	set(value):
		crit = value
		%Crit.text = "Crit : " + str(value) + "%"

var crit_damage: float = 10.0:
	set(value):
		crit_damage = value
		%CritDamage.text = "Crit Damage : " + str(value) + "%"

##==============================
## ENEMY DETECTION
##==============================
var nearest_enemy
var nearest_enemy_distance: float = 150 + area

##==============================
## XP AND LEVELING
##==============================
var XP: int = 0:
	set(value):
		XP = value
		%XP.value = value

var total_XP: int = 0

var level: int = 1:
	set(value):
		level = value
		%Level.text = "Level " + str(value)
		%Options.show_option()

const XP_BASE := 20
const XP_SCALE := 10.0
const XP_EXP := 1.5

##==============================
## GOLD
##==============================
var gold: int = 0:
	set(value):
		gold = value
		%Gold.text = "$ " + str(value)

##==============================
## COMBAT STATUS EFFECTS
##==============================
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
var knockback_duration: float = 0.2
var is_stunned := false
var stun_timer := 0.0

##==============================
## READY
##==============================
func _ready() -> void:
	Persistence.gain_bonus_stats(self)
	character = Persistence.character

	if character:
		scale = character.scale
		set_base_stats(character.base_stats)

	if character.starting_weapon:
		character.starting_weapon.owner = self

	%XP.max_value = get_xp_needed(level)
	%Options.check_item(character.starting_weapon)
	update_xp_ui()

##==============================
## PHYSICS PROCESS
##==============================
func _physics_process(delta):
	#if is_multiplayer_authority():
	if damage_timer > 0:
		damage_timer -= delta
	
	if is_dashing:
		return

	if character and character.starting_weapon:
		character.starting_weapon.update(delta)
	
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity = knockback_velocity
	else:
		velocity = Input.get_vector("left", "right", "up", "down") * movement_speed

	if velocity != Vector2.ZERO:
		last_move_dir = velocity.normalized()

	if is_instance_valid(nearest_enemy):
		nearest_enemy_distance = nearest_enemy.seperation
	else:
		nearest_enemy_distance = 150 + area
		nearest_enemy = null

	move_and_collide(velocity * delta)

	check_XP()
	animation(delta)
	
	var new_health = min(health + recovery * delta, max_health)
	if new_health > health:
		health = new_health



##==============================
## MULTIPLAYER
##==============================
func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	
##==============================
## DASHING
##==============================
func dash():
	if is_dashing or not can_dash:
		return

	is_dashing = true
	is_invincible = true
	can_dash = false
	ghost_timer.start()
	%Collision.set_deferred("disabled", true)

	$AnimationPlayer.play("dash_" + character.animation_name)
	SoundManager.play_sfx(load("res://music & sfx/RPG_Essentials_Free/8_Atk_Magic_SFX/Wind_02.wav"))

	var dash_dir = velocity.normalized()
	if dash_dir == Vector2.ZERO:
		dash_dir = last_move_dir

	var target_position = position + dash_dir * dash_distance
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_position, dash_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished

	%Collision.set_deferred("disabled", false)
	ghost_timer.stop()
	is_dashing = false

	await get_tree().create_timer(post_dash_invincibility_duration).timeout
	is_invincible = false

	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

func _input(event):
	if event.is_action_pressed("attack_primary"):
		if character and character.starting_weapon and character.starting_weapon.manual_only:
			character.starting_weapon.activate(self, nearest_enemy, get_tree())

	if event.is_action_pressed("dash"):
		dash()

##==============================
## COMBAT / DAMAGE
##==============================
func take_damage(amount: float, bypass_invincibility: bool = false, source: Variant = null):
	if is_invincible and not bypass_invincibility:
		return

	if damage_timer > 0:
		return

	damage_timer = damage_cooldown

	if randf() * 100 < dodge:
		show_dodge_feedback()
		return

	var damage_multiplier = 100.0 / (100.0 + armor)
	var reduced_damage = max(amount * damage_multiplier, 1)

	print("Incoming Damage:", amount)
	print("Reduced by Armor:", reduced_damage)
	if source != null:
		print("Damage Source:", source.name)

	health -= reduced_damage


func apply_knockback(force: Vector2):
	if is_dashing:
		return
	knockback_velocity = force
	knockback_timer = knockback_duration

func show_dodge_feedback():
	print("DODGED!")
	SoundManager.play_sfx(preload("res://music & sfx/Minifantasy_Dungeon_SFX/18_orc_charge.wav"))

func _on_self_damage_body_entered(body):
	take_damage(body.damage)

##==============================
## DEATH
##==============================
func die():
	if character:
		$AnimationPlayer.play("death_" + character.animation_name)
	AudioController.bg_music.play()
	$Sprite2D.visible = true
	get_tree().paused = true
	await $AnimationPlayer.animation_finished

func show_game_over_screen():
	await $AnimationPlayer.animation_finished
	var game_over = preload("res://scenes/GameOver.tscn").instantiate()
	add_child(game_over)
	get_tree().paused = true

##==============================
## XP SYSTEM
##==============================
func get_xp_needed(lvl: int) -> int:
	return int(XP_BASE + pow(lvl, XP_EXP) * XP_SCALE)

func gain_XP(amount):
	XP += amount * growth
	total_XP += amount * growth
	update_xp_ui()

func check_XP():
	while XP >= get_xp_needed(level):
		XP -= get_xp_needed(level)
		level += 1
		SoundManager.play_sfx(load("res://music & sfx/RPG_Essentials_Free/12_Player_Movement_SFX/88_Teleport_02.wav"))
	update_xp_ui()

func update_xp_ui():
	%XP.max_value = get_xp_needed(level)
	%XP.value = XP
	%XPLabel.text = "XP: %d / %d" % [XP, get_xp_needed(level)]

##==============================
## STATS & GOLD
##==============================
func set_base_stats(base_stats: Stats):
	max_health += base_stats.max_health
	recovery += base_stats.recovery
	armor += base_stats.armor
	movement_speed += base_stats.movement_speed
	damage += base_stats.damage
	amplify += base_stats.amplify
	area += base_stats.area
	magnet += base_stats.magnet
	growth += base_stats.growth
	luck += base_stats.luck
	dodge += base_stats.dodge
	crit += base_stats.crit
	crit_damage += base_stats.crit_damage

func gain_gold(amount):
	gold += amount

##==============================
## GHOST & CHEST
##==============================
func add_ghost():
	var ghost = ghost_node.instantiate()
	ghost.set_property(position, $Sprite2D.scale)
	get_tree().current_scene.add_child(ghost)

func open_chest():
	$UI/Chest.open()

func _on_ghost_timer_timeout():
	add_ghost()

##==============================
## UI / MISC
##==============================
func animation(_delta):
	if velocity == Vector2.ZERO:
		$AnimationPlayer.play("idle_" + character.animation_name)
	else:
		$AnimationPlayer.play("walk_" + character.animation_name)

	$Sprite2D.flip_h = velocity.x < 0

func _on_magnet_area_entered(pickup_area):
	if pickup_area.has_method("follow"):
		pickup_area.follow(self)

func _on_timer_timeout():
	%Collision.set_deferred("disabled", true)
	%Collision.set_deferred("disabled", false)
