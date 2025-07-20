extends Node

signal time_changed(time_of_day: String)

@export var cycle_duration := 300.0
@export var max_fog_opacity := 0.5
@export var canvas_modulate: CanvasModulate
@export var fog_sprite: ColorRect

var time := 0.0

var sunrise_color := Color(1.0, 0.7, 0.5)
var noon_color := Color(1.0, 1.0, 1.0)
var afternoon_color := Color(1.0, 0.9, 0.7)
var evening_color := Color(0.6, 0.4, 0.7)
var night_color := Color(0.2, 0.2, 0.4)
var midnight_color := Color(0.05, 0.05, 0.1)

var _last_time_of_day := ""

func _ready():
	if canvas_modulate == null:
		print("⚠️ canvas_modulate not assigned!")
	if fog_sprite == null:
		print("⚠️ fog_sprite not assigned!")


func _process(delta):
	time += delta
	var angle: float = fmod((time / cycle_duration) * TAU, TAU)

	var color := get_current_color(angle)


	# SAFELY apply the color if the node is assigned
	if canvas_modulate != null:
		canvas_modulate.color = color
	else:
		print_debug("CanvasModulate not assigned")

	if fog_sprite != null:
		fog_sprite.modulate.a = get_fog_opacity(angle)
	else:
		print_debug("Fog sprite not assigned")

	var current_time_of_day = get_time_of_day(angle)
	if current_time_of_day != _last_time_of_day:
		_last_time_of_day = current_time_of_day
		emit_signal("time_changed", current_time_of_day)




func get_current_color(angle: float) -> Color:
	if angle < TAU * 0.12:
		return sunrise_color.lerp(noon_color, angle / (TAU * 0.12))
	elif angle < TAU * 0.25:
		return noon_color.lerp(afternoon_color, (angle - TAU * 0.12) / (TAU * 0.13))
	elif angle < TAU * 0.40:
		return afternoon_color.lerp(evening_color, (angle - TAU * 0.25) / (TAU * 0.15))
	elif angle < TAU * 0.55:
		return evening_color.lerp(night_color, (angle - TAU * 0.40) / (TAU * 0.15))
	elif angle < TAU * 0.80:
		return night_color.lerp(midnight_color, (angle - TAU * 0.55) / (TAU * 0.25))
	else:
		return midnight_color.lerp(sunrise_color, (angle - TAU * 0.80) / (TAU * 0.20))


func get_fog_opacity(angle: float) -> float:
	if angle >= TAU * 0.40 and angle < TAU * 0.80:
		var t = clamp((angle - TAU * 0.40) / (TAU * 0.40), 0.0, 1.0)
		return t * max_fog_opacity
	elif angle >= TAU * 0.80:
		var t = (angle - TAU * 0.80) / (TAU * 0.20)
		return (1.0 - t) * max_fog_opacity
	return 0.0


func get_time_of_day(angle: float) -> String:
	if angle < TAU * 0.12:
		return "Sunrise"
	elif angle < TAU * 0.25:
		return "Noon"
	elif angle < TAU * 0.40:
		return "Afternoon"
	elif angle < TAU * 0.55:
		return "Evening"
	elif angle < TAU * 0.80:
		return "Night"
	else:
		return "Midnight"
