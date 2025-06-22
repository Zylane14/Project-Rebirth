extends CharacterBody2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]

# === Exposed Stats ===
@export var max_health: float = 1000.0
@export var health: float = 1000.0
@export var speed: float = 3.0
@export var damage: float = 10.0
@export var regen_rate: float = 5.0
@export var regen_interval: float = 1.0
@export var has_phase_2: bool = true
@export var phase_2_health_threshold: float = 0.5
@export var boss_music: AudioStream
@export var player: CharacterBody2D

# --- Animation States ---
const MELEE_ATTACKS = ["attack_1", "attack_2", "bite"]

# --- Movement ---
var facing_right: bool
var run_target: Vector2
var is_running: bool = false
var run_speed: float = 150.0
var run_attack_speed: float = 300.0
var t: float = 1.0
var p0: Vector2
var p1: Vector2
var p2: Vector2
var knockback: Vector2 = Vector2.ZERO
# --- Combat ---
var current_knockback_strength: float = 0.0
var in_phase_2 := false

# --- Regen ---
var regen_timer := 0.0

# === Lifecycle ===
func _ready():
	%HealthBar.max_value = max_health
	%HealthBar.value = health
	if boss_music:
		SoundManager.play_music(boss_music)

func _process(delta):
	if has_phase_2 and not in_phase_2 and health <= max_health * phase_2_health_threshold:
		enter_phase_2()

	if in_phase_2 and health < max_health:
		regen_timer += delta
		if regen_timer >= regen_interval:
			regen_timer = 0.0
			health = min(health + regen_rate, max_health)
			%HealthBar.value = health

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

	if global_position.distance_to(player.global_position) < 40:
		if is_running:
			is_running = false
			run_speed = 200.0
			melee_attack()
	elif global_position.distance_to(run_target) < 10:
		is_running = false
		run_speed = 200.0
	
	var velocity = (player.position - position).normalized() * speed
	knockback = knockback.move_toward(Vector2.ZERO, 100 * delta)
	velocity += knockback

	var collision = move_and_collide(velocity * delta)
	if collision and collision.get_collider().has_method("apply_knockback"):
		collision.get_collider().apply_knockback((collision.get_collider().global_position - global_position).normalized() * 50)

# === Actions ===
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
	var to_player = (player.global_position - global_position).normalized()
	run_target = player.global_position + to_player * 100.0
	run_target += Vector2(0, randf_range(-30, 30))
	is_running = true
	run_speed = run_attack_speed
	state_machine.travel("run_attack")

func can_do_bite():
	state_machine.travel("dodge")

# === Helpers ===
func set_destination(final_position: Vector2):
	p0 = global_position
	p2 = final_position
	var angle = 60 if (p2 - p0).x < 0 else -60
	var curve = (p2 - p0).normalized().rotated(deg_to_rad(angle))
	p1 = p0 + 90 * curve

func _on_player_entered(_body):
	%PlayerCollision.set_deferred("disabled", true)
	run_attack()
	%HealthBar.show()

func take_damage(amount := 1):
	health -= amount
	%HealthBar.value = health
	if health <= 0:
		state_machine.travel("death")
		set_physics_process(false)

func enter_phase_2():
	in_phase_2 = true
	print("Boss has entered Phase 2!")
	speed *= 1.2
	damage *= 1.5
	max_health += 1500
	health += 100
	%HealthBar.max_value = max_health
	%HealthBar.value = health
	state_machine.travel("phase_2_intro")
