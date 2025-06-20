extends Area2D

@export var damage: float = 5.0
@export var linger_time: float = 3.0
@export var tick_interval: float = 0.4  # how often to apply damage
var player_reference: CharacterBody2D

func _ready():
	#Play the start animation (one-time)
	if $AnimatedSprite2D.sprite_frames.has_animation("poison_start"):
		$AnimatedSprite2D.play("poison_start")
		await $AnimatedSprite2D.animation_finished

	#Play the loop animation (repeats during damage)
	if $AnimatedSprite2D.sprite_frames.has_animation("poison_loop"):
		$AnimatedSprite2D.play("poison_loop")

	#Damage over time while looping
	var total_ticks = int(linger_time / tick_interval)
	for i in range(total_ticks):  # FIXED: use `range()` instead of `for i in total_ticks`
		await get_tree().create_timer(tick_interval).timeout
		if player_reference and is_overlapping_body(player_reference):  # FIXED: correct function name
			player_reference.take_damage(damage)

	#Play fade-out animation (one-time)
	if $AnimatedSprite2D.sprite_frames.has_animation("poison_fade"):
		$AnimatedSprite2D.play("poison_fade")
		await $AnimatedSprite2D.animation_finished

	#Cleanup
	queue_free()

func is_overlapping_body(body: Node2D) -> bool:
	return get_overlapping_bodies().has(body)
