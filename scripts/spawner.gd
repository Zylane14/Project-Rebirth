extends Node2D

#variable for holding lpayer reference and for holding enemy node
@export var player : CharacterBody2D
@export var enemy : PackedScene

#distance for enemy spawning
var distance : float = 400

#declare a variable to store array of enemy
@export var enemy_types : Array[Enemy]

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
func spawn(pos : Vector2, elite : bool = false):
	var enemy_instance = enemy.instantiate()
	
	enemy_instance.type = enemy_types[min(minute, enemy_types.size()-1)] #each minute will be a diffirent wave of enemy
	enemy_instance.position = pos
	enemy_instance.player_reference = player
	enemy_instance.elite = elite
	
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


func _on_pattern_timeout():
	for i in range(75):
		spawn(get_random_position())


func _on_elite_timeout() -> void:
	spawn(get_random_position(), true)
