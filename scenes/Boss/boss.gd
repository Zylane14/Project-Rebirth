extends CharacterBody2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]

@export var player: CharacterBody2D
@export var type: Enemy:
	set(value):
		type = value
		if type:
			$Sprite2D.texture = type.texture
			$Sprite2D.scale = type.scale
			health = type.health
			speed = type.speed

			if type.is_boss:
				print("Boss loaded:", type.title)
				
# --- Animation states ---
const MELEE_ATTACKS = ["attack_1", "attack_2", "bite"]
const RUN_ATTACKS = ["run_start", "run", "run_attack"]

# --- Movement ---
var facing_right: bool
var run_target: Vector2
var is_running: bool = false
var run_speed: float = 150.0
var damage: float = 10.0
var run_attack_speed: float = 400.0
var speed: float = 3.0
var t: float = 1.0
var p0: Vector2
var p1: Vector2
var p2: Vector2

# --- Combat ---
var current_knockback_strength: float = 0.0
var in_phase_2 := false

# --- Health ---
var health: float = 200:
	set(value):
		health = value
		%HealthBar.value = health
		if value <= 0:
			state_machine.travel("death")
			set_physics_process(false)

# === PROCESS ===
func _physics_process(delta):
	facing_right = (player.position - global_position).x <= 0
	$Sprite2D.flip_h = facing_right
	%Hitbox.scale.x = -1 if facing_right else 1

	if t < 1.0:
		t += speed * delta
		position = position.bezier_interpolate(p0, p1, p2, t)
	elif is_running:
		var direction = (run_target - global_position).normalized()
		position += direction * run_speed * delta

	# Attack or stop if close
	if global_position.distance_to(player.global_position) < 40:
		if is_running:
			is_running = false
			run_speed = 200.0
			melee_attack()
	elif global_position.distance_to(run_target) < 10:
		is_running = false
		run_speed = 200.0

func _ready():
	if type and type.is_boss and type.boss_music:
		SoundManager.play_music(load("res://music & sfx/The Westerlands/06 The Haunted Halls of Elmore Keep.wav"))

func _process(delta):
	if type and type.is_boss and type.has_phase_2 and health <= type.health * type.phase_2_health_threshold:
		enter_phase_2()
		
# === ACTIONS ===
func run():
	run_target = player.global_position
	is_running = true
	run_speed = 150.0
	state_machine.travel("run")

func run_to_player():
	run_target = player.global_position
	is_running = true
	state_machine.travel("run")

func jump():
	t = 0
	speed = 2.0
	var offset = Vector2(25, -7) if facing_right else Vector2(-25, -7)
	set_destination(player.position + offset)

func dodge():
	t = 0
	speed = 1.5
	var direction = Vector2.RIGHT if facing_right else Vector2.LEFT
	set_destination(position + direction * 100)

func melee_attack():
	current_knockback_strength = 200.0
	state_machine.travel(MELEE_ATTACKS.pick_random())

func run_attack():
	current_knockback_strength = 500.0
	run_target = player.global_position
	is_running = true
	run_speed = run_attack_speed

func can_do_bite():
	# This could be replaced with actual logic if needed later
	var _chance = randf()
	state_machine.travel("dodge")

# === DESTINATION CALCULATION ===
func set_destination(final_position: Vector2):
	p0 = global_position
	p2 = final_position

	var angle = 60 if (p2 - p0).x < 0 else -60
	var curve = (p2 - p0).normalized().rotated(deg_to_rad(angle))
	p1 = p0 + 90 * curve

# === EVENTS ===
func _on_player_entered(_body):
	%PlayerCollision.set_deferred("disabled", true)
	run_attack()
	%HealthBar.show()

func take_damage(amount := 1):
	health -= amount
	$AnimationPlayer.play("hit")


func enter_phase_2():
	if in_phase_2:
		return
	in_phase_2 = true
	print("Boss has entered Phase 2!")

	# Optional: increase speed/damage or switch animations
	speed *= 1.2
	damage *= 1.5
	state_machine.travel("phase_2_intro")  # optional animation
