extends Area2D

@export var speed: float = 300.0
@export var damage: float = 5.0
@export var poison_pool_scene: PackedScene  # assign PoisonPool.tscn in Inspector
@export var stop_distance: float = 10.0  # distance threshold to trigger explosion

var direction: Vector2 = Vector2.ZERO
var target_position: Vector2
var player_reference: CharacterBody2D

func _ready():
	if player_reference:
		target_position = player_reference.global_position

	if $AnimatedSprite2D.sprite_frames.has_animation("vial_throw"):
		$AnimatedSprite2D.play("vial_throw")

func _physics_process(delta):
	var to_target = target_position - global_position
	if to_target.length() <= stop_distance:
		spawn_poison_pool()
		queue_free()
	else:
		direction = to_target.normalized()
		position += direction * speed * delta

func spawn_poison_pool():
	if not poison_pool_scene:
		return
	var pool = poison_pool_scene.instantiate()
	pool.global_position = global_position
	pool.damage = damage
	pool.player_reference = player_reference
	get_tree().current_scene.add_child(pool)
