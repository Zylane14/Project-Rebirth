extends Node2D

#variable for holding lpayer reference and for holding enemy node
@export var player : CharacterBody2D
@export var enemy : PackedScene

#distance for enemy spawning
var distance : float = 400

var minute : int:
	set(value):
		minute = value
		%Minute.text = str(value)
		
#second setter variable updating minute
var second : int:
	set(value):
		second = value
		if second >= 10:
			second -= 10
			minute += 1
		%Second.text = str(second).lpad(2,'0') #padding to the left


#instantiate the enemy node and set spawn position and player reference
func spawn(pos : Vector2):
	var enemy_instance = enemy.instantiate()
	
	enemy_instance.position = pos
	enemy_instance.player_reference = player
	
	get_tree().current_scene.add_child(enemy_instance)


#function to get random postion from player at a particular distance
func get_random_position() -> Vector2:
	return player.position + distance * Vector2.RIGHT.rotated(randf_range(0, 2 * PI))

#function to spawn multiple enemies at a time
func amount(number : int = 1):
	for i in range(number):
		spawn(get_random_position())

#increment "second" with each timeout and spawn enemies
func _on_timer_timeout() -> void:
	second += 1
	amount(second % 10)
