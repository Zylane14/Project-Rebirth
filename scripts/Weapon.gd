extends Resource
class_name Weapon

@export var title : String
@export var texture : Texture2D

#properties for projectiles
@export var damage : float
@export var cooldown : float
@export var speed : float

#preload projectile node
@export var projectile_node : PackedScene = preload("res://scenes/projectile.tscn")

func activate(_source, _target, _scene_tree):
	pass
