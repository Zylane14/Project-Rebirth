extends Sprite2D

@export var fade_duration : float = 6.0
var fading_in := true

func _ready():
	modulate.a = 0.0
	start_looping_fade()

func start_looping_fade():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	tween.set_loops() 
	
