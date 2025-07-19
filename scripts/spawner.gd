extends Node2D

#variable for holding lpayer reference and for holding enemy node
@export var player : CharacterBody2D
@export var enemy : PackedScene
@export var destructible : PackedScene
@export var boss_scene: PackedScene
@export var boss_unlock_minute := 5  # change this to whatever minute you want

var boss_spawned := false
var enemy_types: Array[Enemy] = [] #declare a variable to store array of enemy

#distance for enemy spawning
var distance : float = 400
var can_spawn : bool = true #flag variable for spawning
var unlocked_enemy_types: Array[Enemy] = []
var gold_drop = preload("res://scenes/Gold.gd")

# Time tracking
var minute : int:
	set(value):
		minute = value
		%Minute.text = str(value)

#second setter variable updating minute
var second : int:
	set(value):
		second = value
		if second >= 60:
			second -= 60
			minute += 1
		%Second.text = str(second).lpad(2,'0') #padding to the left


func load_enemy_types(path: String):
	enemy_types.clear()
	var dir := DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var full_path = path + "/" + file_name
				var res = load(full_path)
				if res is Enemy:
					enemy_types.append(res)
			file_name = dir.get_next()
		dir.list_dir_end()

# Called when the node enters the scene tree
func _ready():
	load_enemy_types("res://resources/Enemies/")
	
func _physics_process(_delta):
	if get_tree().get_node_count_in_group("Enemy") < 700: #limit mob spawns below 700
		can_spawn = true
	else:
		can_spawn = false
	

#instantiate the enemy node and set spawn position and player reference
func spawn(pos : Vector2, elite : bool = false):
	if not can_spawn and not elite: #using flag to control spawn
		return
	
	var enemy_instance = enemy.instantiate()
	
	enemy_instance.type = pick_weighted_enemy_type()
	enemy_instance.position = pos
	enemy_instance.player_reference = player
	enemy_instance.elite = elite
	enemy_instance.apply_buff(minute)
	
	enemy_instance.scale = enemy_instance.type.scale
	
	get_tree().current_scene.add_child(enemy_instance)

func spawn_boss():
	if boss_spawned:
		return

	var boss = boss_scene.instantiate()
	boss.global_position = get_random_position()
	boss.player = player
	get_tree().current_scene.add_child(boss)

	boss_spawned = true

func update_unlocked_enemies():
	var unlock_interval = 1  #every 1 minute, unlock a new enemy type
	@warning_ignore("integer_division")
	var num_to_unlock = clamp(floor(minute / unlock_interval) + 1, 1, enemy_types.size())

	unlocked_enemy_types.clear()
	for i in range(num_to_unlock):
		unlocked_enemy_types.append(enemy_types[i])

#function to calculate how many enemies to spawn based on time passed
#base is the starting spawn count, scaling controls how fast enemy count increases per minute
#this setup starts easy and slowly ramps up difficulty over time
func get_spawn_amount() -> int:
	var time = float(minute) + float(second) / 60.0
	var base = 1
	var scaling = 5
	return int(base + time * scaling)

func pick_weighted_enemy_type() -> Enemy: #function to pick a random enemy type using time-scaled weighted rarity
	var weighted_list: Array[Enemy] = []
	var weights: Array[float] = []

	var time = float(minute) + float(second) / 60.0
	var total_weight: float = 0.0

	for enemy_type in enemy_types:
		if time >= enemy_type.unlock_minute:
			var progression = clamp((time - enemy_type.unlock_minute) * 0.1, 0.0, 3.0)
			var scaled_weight = enemy_type.spawn_weight * (1.0 + progression)
			weighted_list.append(enemy_type)
			weights.append(scaled_weight)
			total_weight += scaled_weight

	if weighted_list.is_empty():
		return unlocked_enemy_types.pick_random()

	var roll := randf_range(0.0, total_weight)
	var cumulative := 0.0

	for i in weighted_list.size():
		cumulative += weights[i]
		if roll <= cumulative:
			return weighted_list[i]

	return weighted_list[0] # safety fallback

#function to get random postion from player at a particular distance
func get_random_position() -> Vector2:
	return player.position + distance * Vector2.RIGHT.rotated(randf_range(0, 2 * PI))

#function to spawn multiple enemies at a time
func amount(number : int = 1):
	for i in range(number):
		spawn(get_random_position())

#increment "second" with each timeout and spawn enemies
func _on_timer_timeout():
	second += 1
	update_unlocked_enemies()

	var spawn_amount := get_spawn_amount() + randi_range(-3, 3)
	spawn_amount = max(spawn_amount, 1)
	amount(spawn_amount)

	# === Boss unlock check ===
	if not boss_spawned and minute >= boss_unlock_minute:
		spawn_boss()


func _on_pattern_timeout():
	var base := 30
	var time := float(minute) + float(second) / 60.0
	var count := int(base + time * 15.0)
	for i in range(count):
		spawn(get_random_position())

func _on_elite_timeout():
	spawn(get_random_position(), true)

func _on_destructible_timeout():
	spawn_destructible(get_random_position()) #spawning destructible with each timeout
	
func spawn_destructible(pos: Vector2):
	var object_instance = destructible.instantiate() #function to spawn destructible
	object_instance.position = pos
	get_tree().current_scene.add_child(object_instance)
