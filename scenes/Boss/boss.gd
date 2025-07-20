extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]
@onready var damage_popup_scene = preload("res://scenes/damage.tscn")
@export var phase_2_material: Material

@export var max_health := 10000.0
@export var health := 10000.0
@export var run_speed := 300.0
@export var run_attack_speed := 400.0
@export var curve_speed := 2.0
@export var damage := 20.0
@export var regen_rate := 100.0
@export var regen_interval := 1.0
@export var has_phase_2 := true
@export var phase_2_health_threshold := 0.5
@export var player: CharacterBody2D
@export var player_knockback_multiplier := 0.3

const MELEE_ATTACKS = ["attack_1", "attack_2", "bite"]

var facing_right := true
var run_target: Vector2
var is_running := false
var t := 1.0
var p0: Vector2
var p1: Vector2
var p2: Vector2
var current_knockback_strength := 0.0
var in_phase_2 := false
var is_immovable := false
var is_transforming := false
var has_attacked_during_run := false
var regen_timer := 0.0

func _ready():
	%HealthBar.max_value = max_health
	%HealthBar.value = health
	
	
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
	if is_transforming or is_immovable:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	update_facing()

	if t < 1.0:
		update_bezier(delta)
		return

	var move_vector := Vector2.ZERO

	if is_running:
		var dir = (run_target - global_position).normalized()
		move_vector = dir * run_speed

		if global_position.distance_to(run_target) < 10:
			is_running = false
			run_speed = run_attack_speed

	velocity = move_vector
	move_and_slide()
	apply_knockback_to_player()

func update_facing():
	facing_right = (player.position - global_position).x <= 0
	$Sprite2D.flip_h = facing_right
	%Hitbox.scale.x = -1 if facing_right else 1

func update_bezier(delta):
	t += curve_speed * delta
	global_position = global_position.bezier_interpolate(p0, p1, p2, t)
	velocity = Vector2.ZERO
	move_and_slide()

func apply_knockback_to_player():
	var collision = get_last_slide_collision()
	if collision and collision.get_collider().has_method("apply_knockback"):
		var force_dir = (collision.get_collider().global_position - global_position).normalized()
		collision.get_collider().apply_knockback(force_dir * current_knockback_strength * player_knockback_multiplier)


# === Actions ===
func transform():
	is_immovable = true
	is_transforming = true
	state_machine.travel("Transform")

	await get_tree().create_timer(3.0).timeout # tiny buffer to allow animation to start
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.4, 1.4), 1.5)

func _on_transform_end():
	is_transforming = false
	is_immovable = false


func run():
	current_knockback_strength = 500.0
	var to_player = (player.global_position - global_position).normalized()
	run_target = player.global_position + to_player * 100.0 + Vector2(0, randf_range(-30, 30))
	is_running = true
	run_speed = run_attack_speed
	state_machine.travel("run")

func run_attack():
	run()
	state_machine.travel("run_attack")
	has_attacked_during_run = true

func jump():
	t = 0
	curve_speed = 3.0
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

func _on_melee_end():
	is_immovable = false
	has_attacked_during_run = false

func can_do_bite():
	state_machine.travel("bite")

func _on_bite_end():
	has_attacked_during_run = false

func set_destination(final_position: Vector2):
	p0 = global_position
	p2 = final_position
	var angle = 60 if (p2 - p0).x < 0 else -60
	var curve = (p2 - p0).normalized().rotated(deg_to_rad(angle))
	p1 = p0 + 90 * curve

func _on_player_entered(_body):
	%PlayerCollision.set_deferred("disabled", true)
	transform()
	%HealthBar.show()

	if global_position.distance_to(player.global_position) < 100:
		run_attack()

func start_dissolve():
	$Sprite2D.material = ShaderPool.burn.duplicate()
	$Sprite2D.material.set_shader_parameter("dissolve_texture", $Sprite2D.texture)
	
	var tween = get_tree().create_tween()
	tween.tween_method(_set_dissolve_value, 0.0, 1.0, 1.5)
	await tween.finished
	queue_free()

func _set_dissolve_value(val: float):
	if $Sprite2D.material:
		$Sprite2D.material.set_shader_parameter("dissolve_value", val)
		

func take_damage(amount := 1.0, source: Variant = null):
	var is_crit := false
	var modifier: float = 1.0

	if source != null and source.has_variable("crit") and source.has_variable("crit_damage"):
		var crit_chance: float = source.crit / 100.0
		is_crit = randf() < crit_chance
		if is_crit:
			modifier = 1.0 + (source.crit_damage / 100.0)

	var final_damage: float = amount * modifier
	health -= final_damage
	%HealthBar.value = health

	show_damage_popup(final_damage, is_crit)
	flash()

	if health <= 0:
		state_machine.travel("death")
		set_physics_process(false)
		await animation_player.animation_finished
		await start_dissolve()


func enter_phase_2():
	in_phase_2 = true
	print("Boss has entered Phase 2!")
	$Sprite2D.material = phase_2_material

	damage *= 1.5
	max_health += 1500
	health += 100
	%HealthBar.max_value = max_health
	%HealthBar.value = health

func flash():
	var tween = create_tween()
	$Sprite2D.modulate = Color(1, 0.3, 0.3)  # red tint flash
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1), 0.15)

func show_damage_popup(damage: float, is_crit: bool):
	var popup = damage_popup_scene.instantiate()
	popup.text = str(int(damage))
	popup.position = global_position + Vector2(randf_range(-20, 20), -50)

	if is_crit:
		popup.set("theme_override_colors/font_color", Color.DARK_RED)

	get_tree().current_scene.add_child(popup)
