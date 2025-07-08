extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var direction: Vector2 = Vector2.RIGHT
var speed: float = 0
var damage: float = 1
var knockback: float = 90
var source
var weapon: Weapon
var animation_to_play: String = ""

func _ready():
	rotation = direction.angle()

	if animation_to_play != "" and animation_player.has_animation(animation_to_play):
		animation_player.play(animation_to_play)

	# Auto-remove after animation
	var duration = animation_player.current_animation_length
	get_tree().create_timer(duration).connect("timeout", Callable(self, "queue_free"))

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.has_method("take_damage") and source != null:
		var final_damage = calculate_final_damage()
		body.take_damage(final_damage)
		if weapon:
			weapon.damage_dealt += final_damage

func _on_area_entered(area: Area2D):
	var target = area.get_parent()
	if target.has_method("take_damage") and source != null:
		var final_damage = calculate_final_damage()
		target.take_damage(final_damage)
		if weapon:
			weapon.damage_dealt += final_damage

func _on_screen_exited():
	queue_free()

func calculate_final_damage() -> float:
	var flat_damage = damage
	if "damage" in source:
		flat_damage += source.damage

	var amplified_damage = flat_damage
	if "amplify" in source:
		amplified_damage *= (1 + source.amplify / 100.0)

	if "crit" in source and "crit_damage" in source:
		if randf() * 100 < source.crit:
			amplified_damage *= source.crit_damage
			if source.has_method("show_crit_feedback"):
				source.show_feedback()

	return amplified_damage
