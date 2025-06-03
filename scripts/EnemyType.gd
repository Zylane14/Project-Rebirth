extends Resource
class_name Enemy

@export var title : String
@export var texture : Texture2D #set different propert for the enemy
@export var health : float
@export var damage : float
@export var frames : int = 1
@export var drops : Array[Pickups]
