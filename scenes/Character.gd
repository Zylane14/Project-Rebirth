extends Resource
class_name Character

@export var title: String
@export var icon: Texture2D
@export var portrait: Texture2D
@export var animation_name: String = ""
@export var base_stats: Stats
@export var starting_weapon: Weapon
@export var scale: Vector2 = Vector2(1, 1)


@export var can_dash: bool = true
@export var dash_distance: float = 180.0
@export var dash_duration: float = 0.4
@export var dash_cooldown: float = 0.3
@export var post_dash_invincibility_duration: float = 0.2
