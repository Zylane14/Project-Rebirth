extends Sprite2D

@export var rotation_speed : float = -25.0 # Negative = counter-clockwise

func _process(delta: float) -> void:
	rotation_degrees += rotation_speed * delta
