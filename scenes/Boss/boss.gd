extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]
@export var phase_2_material: Material

# === Exposed Stats ===
@export var max_health: float = 1000.0
@export var health: float = 1000.0
@export var walk_speed: float = 100.0
@export var run_speed: float = 300.0
@export var run_attack_speed: float = 400.0
@export var curve_speed: float = 2.0  # used for bezier jump/dodge
@export var damage: float = 10.0
@export var regen_rate: float = 5.0
@export var regen_interval: float = 1.0
@export var has_phase_2: bool = true
@export var phase_2_health_threshold: float = 0.5
@export var player: CharacterBody2D
@export var player_knockback_multiplier: float = 0.3

# --- Animation States ---
const MELEE_ATTACKS = ["attack_1", "attack_2", "bite"]

# --- Movement ---
var facing_right: bool
var run_target: Vector2
var is_running: bool = false
var t: float = 1.0
var p0: Vector2
var p1: Vector2
var p2: Vector2
var knockback: Vector2 = Vector2.ZERO

# --- Combat ---
var current_knockback_strength: float = 0.0
var in_phase_2 := false
var is_immovable: bool = false

# --- Regen ---
var regen_timer := 0.0

func _ready():
	%HealthBar.max_value = max_health
	%HealthBar.value = health

	if animation_tree:
		animation_player.connect("animation_finished", _on_animation_finished)

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

	# Bezier movement (jump or dodge)
	if t < 1.0:
		t += curve_speed * delta
		global_position = global_position.bezier_interpolate(p0, p1, p2, t)
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Skip movement if immovable
	if is_immovable:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Running movement
	var move_vector := Vector2.ZERO

	if is_running:
		var dir = (run_target - global_position).normalized()
		var current_run_speed := run_speed

		if global_position.distance_to(player.global_position) < 40:
			is_running = false
			current_run_speed = 300.0
			melee_attack()
		elif global_position.distance_to(run_target) < 10:
			is_running = false
			current_run_speed = 200.0

		move_vector = dir * current_run_speed
	else:
		move_vector = (player.position - global_position).normalized() * walk_speed

	# Knockback logic
	knockback = knockback.move_toward(Vector2.ZERO, 100 * delta)

	# Clamp knockback strength
	var max_knockback_strength := 300.0
	if knockback.length() > max_knockback_strength:
		knockback = knockback.normalized() * max_knockback_strength

	move_vector += knockback

	# Apply final velocity
	self.velocity = move_vector
	move_and_slide()

	# Knockback player on contact
	var collision = get_last_slide_collision()
	if collision and collision.get_collider().has_method("apply_knockback"):
		var force_dir = (collision.get_collider().global_position - global_position).normalized()
		collision.get_collider().apply_knockback(force_dir * current_knockback_strength * player_knockback_multiplier)

# === Actions ===
func run():
	run_target = player.global_position
	is_running = true
	state_machine.travel("run")

func run_to_player():
	run_target = player.global_position
	is_running = true
	state_machine.travel("run")

func jump():
	t = 0
	curve_speed = 2.0
	var offset = Vector2(25, -7) if facing_right else Vector2(-25, -7)
	set_destination(player.position + offset)

func dodge():
	t = 0
	curve_speed = 1.5
	var direction = Vector2.RIGHT if facing_right else Vector2.LEFT
	set_destination(position + direction * 100)

func melee_attack():
	current_knockback_strength = 200.0
	is_immovable = true
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

	# Apply the red outline material
	$Sprite2D.material = phase_2_material

	# Stat upgrades
	walk_speed *= 1.2
	damage *= 1.5
	run_speed *= 1.2
	run_attack_speed *= 1.2
	max_health += 1500
	health += 100
	%HealthBar.max_value = max_health
	%HealthBar.value = health
	state_machine.travel("phase_2_intro")

func _on_animation_finished(anim_name: String):
	if anim_name in MELEE_ATTACKS:
		is_immovable = false
