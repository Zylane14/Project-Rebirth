extends Weapon
class_name MeleeWeapon

@export var area: float = 1.0
@export var amount: int = 1
@export var arc_angle: float = 90.0 # total spread angle in degrees
@export var delay: float = 0.15
@export var reversible: bool = false
@export var knockback: float = 100.0

var hitbox_scene: PackedScene = preload("res://scenes/melee_hitbox.tscn")

func activate(source, _target, scene_tree):
	if not can_attack():
		return

	cooldown_timer = cooldown

	spawn_hitboxes(source, scene_tree)

func spawn_hitboxes(source, scene_tree):
	var mouse_pos = source.get_global_mouse_position()
	var base_angle = (mouse_pos - source.global_position).angle()

	var angle_step = deg_to_rad(arc_angle) / max(1, amount - 1)
	var start_angle = base_angle - deg_to_rad(arc_angle) / 2

	for i in range(amount):
		var current_angle = start_angle + i * angle_step
		var _dir = Vector2.RIGHT.rotated(current_angle)

		var hitbox = hitbox_scene.instantiate()

		var direction = (source.get_global_mouse_position() - source.global_position).normalized()
		hitbox.direction = direction
		hitbox.rotation = direction.angle()
		hitbox.position = direction * 16 * area  # local if following player

		hitbox.damage = damage
		hitbox.source = source
		hitbox.weapon = self
		hitbox.knockback = knockback
		hitbox.animation_to_play = projectile_animation_name

		if sound:
			SoundManager.play_sfx(sound)
		if particle and hitbox.has_node("Sprite2D"):
			hitbox.get_node("Sprite2D").material = particle

		#follows the player
		source.call_deferred("add_child", hitbox)

		await scene_tree.create_timer(delay).timeout

func upgrade_item():
	if max_level_reached():
		slot.item = evolution
		return

	if not is_upgradeable():
		return

	var upgrade = upgrades[level - 1]
	damage += upgrade.damage
	area += upgrade.area
	amount += int(upgrade.amount)
	level += 1
