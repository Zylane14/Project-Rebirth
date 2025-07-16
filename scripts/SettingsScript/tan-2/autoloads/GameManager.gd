extends Node

# Global variables
var player_health : int = 100
var player_max_health : int = 100
var current_level : int = 1
var is_paused : bool = false

func _ready():
	print("GameManager ready!")

# Example functions
func reset_game():
	player_health = player_max_health
	current_level = 1
	print("Game reset!")

func take_damage(amount : int):
	player_health -= amount
	player_health = clamp(player_health, 0, player_max_health)
	print("Player health: %d" % player_health)
