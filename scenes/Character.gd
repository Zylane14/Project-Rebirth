extends Resource
class_name Character

@export var title : String
@export var icon : Texture2D
@export var portrait : Texture2D
@export var animation_name : String

@export var base_stats : Stats #stats from player script
@export var starting_weapon : Weapon
@export var scale: Vector2 = Vector2(1, 1)
@export var dash_distance : float
@export var dash_duration : float
@export var dash_cooldown : float
