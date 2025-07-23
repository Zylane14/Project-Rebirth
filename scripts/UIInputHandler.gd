extends Node

@export var player: Player

func _input(event):
	if event.is_action_pressed("toggle_weapon_inventory") and is_instance_valid(player):
		player.toggle_inventory()
