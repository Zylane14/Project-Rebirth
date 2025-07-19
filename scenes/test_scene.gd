extends Node2D

@onready var canvas_modulate := $"Day&Night"
@onready var fog_sprite = get_node("FogParallax/ParallaxLayer/ColorRect")

@export var cycle_duration := 300.0 # total time (in seconds) for full day-night cycle
@export var max_fog_opacity := 0.5
@export var player_scene: PackedScene

var time := 0.0
var peer = ENetMultiplayerPeer.new()
# Tint colors for each time of day
var sunrise_color := Color(1.0, 0.7, 0.5)    # soft orange-pink
var noon_color := Color(1.0, 1.0, 1.0)       # bright white
var afternoon_color := Color(1.0, 0.9, 0.7)  # warm light yellow
var evening_color := Color(0.6, 0.4, 0.7)    # purple dusk
var night_color := Color(0.2, 0.2, 0.4)      # dark blue

func _ready():
	GlobalManager.reset()
	print("Reset global buff stage:", GlobalManager.global_buff_stage)

func _process(delta):
	time += delta
	var angle: float = fmod((time / cycle_duration) * TAU, TAU) # range: 0 to TAU
	var color := Color(1, 1, 1) # default fallback

	# ===== Day & Night Color Transitions =====
	if angle < TAU * 0.15:  # Sunrise → Noon
		var t = angle / (TAU * 0.15)
		color = sunrise_color.lerp(noon_color, t)
	elif angle < TAU * 0.30:  # Noon → Afternoon
		var t = (angle - TAU * 0.15) / (TAU * 0.15)
		color = noon_color.lerp(afternoon_color, t)
	elif angle < TAU * 0.45:  # Afternoon → Evening
		var t = (angle - TAU * 0.30) / (TAU * 0.15)
		color = afternoon_color.lerp(evening_color, t)
	elif angle < TAU * 0.65:  # Evening → Night
		var t = (angle - TAU * 0.45) / (TAU * 0.20)
		color = evening_color.lerp(night_color, t)
	else:  # Night → Sunrise
		var t = (angle - TAU * 0.65) / (TAU * 0.35)
		color = night_color.lerp(sunrise_color, t)

	canvas_modulate.color = color

	# ===== Fog Opacity (fade in at night) =====
	var fog_opacity := 0.0
	if angle < TAU * 0.65:
		if angle >= TAU * 0.45:  # Evening → Night
			var t = (angle - TAU * 0.45) / (TAU * 0.20)
			fog_opacity = t * max_fog_opacity
	else:  # Night → Sunrise (fade out)
		var t = (angle - TAU * 0.65) / (TAU * 0.35)
		fog_opacity = (1.0 - t) * max_fog_opacity

	fog_sprite.modulate.a = fog_opacity

func get_time_of_day() -> String:
	var angle: float = fmod((time / cycle_duration) * TAU, TAU)
	if angle < TAU * 0.15:
		return "Sunrise"
	elif angle < TAU * 0.30:
		return "Noon"
	elif angle < TAU * 0.45:
		return "Afternoon"
	elif angle < TAU * 0.65:
		return "Evening"
	else:
		return "Night"


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
