extends CharacterBody2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]

const melee_attacks = ["attack_1", "attack_2", "bite"]
const run_attacks = ["run_start", "run", "run_attack"]

@export var player: CharacterBody2D

var p0 : Vector2 #3 control points for bezier curve
var p1 : Vector2
var p2 : Vector2

var t: float = 1
var speed: float = 3.0 

var facing_right : bool #variable to check if sprite is facing towards player
var run_target : Vector2
var is_running : bool = false
var run_speed : float = 200.0  # Speed in pixels per second
var run_attack_speed : float = 400.0  # Faster than regular run

var health: float = 100: #update healthbar value with setter variable
	set(value):
		health = value
		%HealthBar.value = health
		
		if value <= 0: #if health reaches 0, travel to death and turn off proccess
			state_machine.travel("death")
			set_physics_process(false)
			
func _physics_process(delta):
	facing_right = (player.position - global_position).x <= 0

	$Sprite2D.flip_h = facing_right
	%Hitbox.scale.x = -1 if facing_right else 1

	# Bezier curve movement for jump/dodge
	if t < 1.0:
		t += speed * delta
		position = position.bezier_interpolate(p0, p1, p2, t)

	# Straight-line run movement
	elif is_running:
		var direction = (run_target - global_position).normalized()
		var step = direction * run_speed * delta
		position += step

	# Check if close to player to trigger run attack
	if global_position.distance_to(player.global_position) < 40:
		is_running = false
		run_speed = 200.0  # Reset to normal
		state_machine.travel(run_attacks.pick_random())
	elif global_position.distance_to(run_target) < 10:
		is_running = false
		run_speed = 200.0  # Reset to normal

func run():
	run_target = player.global_position
	is_running = true
	state_machine.travel("run")
	
func jump(): 
	t = 0 #set destination
	speed = 2.0
	
	var correction : Vector2 #position correction
	if facing_right:
		correction = Vector2(25,-7)
	else:
		correction =Vector2(-25,-7)
	
	set_destination(player.position + correction) #start interpolation

func dodge():
	var direction
	t = 0
	speed = 1.5
	
	if facing_right:
		direction = Vector2.RIGHT
	else:
		direction = Vector2.LEFT
	
	set_destination(position + direction * 100) #set direction accordingly and move to that position

func run_to_player():
	run_target = player.global_position
	is_running = true
	state_machine.travel("run")
	
func melee_attack():
	state_machine.travel(melee_attacks.pick_random()) #function to player melee attack

func run_attack():
	run_target = player.global_position
	is_running = true
	run_speed = run_attack_speed  # Use faster speed for run attack

func can_do_bite():
	var chance = randf()
	animation_tree["parameters/conditions/can_dodge"] = chance < 0.5 #50% chance after melee attack

func set_destination(final_position):
	p0 = global_position
	p2 = final_position
	
	var angle 
	if (p2-p0).x < 0:
		angle = 60
	else:
		angle = -60
	
	var tilted_unit_vector = (p2-p0).normalized().rotated(deg_to_rad(angle))
	p1 = p0 + 90 * tilted_unit_vector
	


func _on_player_entered(_body):
	%PlayerCollision.set_deferred("disabled",true) #disable collision and do run attack
	run_attack()
	$%HealthBar.show()

func take_damage(amount = 1):
	health -= amount
	$AnimationPlayer.play("hit")
