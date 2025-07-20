extends Node2D

@onready var canvas_modulate := $"Day&Night"
@onready var fog_sprite := get_node("FogParallax/ParallaxLayer/ColorRect")

@export var player_scene: PackedScene

var peer = ENetMultiplayerPeer.new()

func _ready():
	GlobalManager.reset()
	print("Reset global buff stage:", GlobalManager.global_buff_stage)

	# Assign references from this scene to the DayNightCycle autoload
	DayNightCycle.canvas_modulate = canvas_modulate
	DayNightCycle.fog_sprite = fog_sprite

	# Connect to the time_changed signal
	DayNightCycle.time_changed.connect(_on_time_changed)

func _on_time_changed(time_str: String):
	print("Time of Day:", time_str)

func _on_host_pressed() -> void:
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func _on_join_pressed() -> void:
	peer.create_client("localhost", 135)
	multiplayer.multiplayer_peer = peer
