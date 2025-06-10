extends Resource
class_name Enemy

@export var title : String
@export var texture : Texture2D #set different propert for the enemy
@export var health : float
@export var damage : float
@export var speed : float
@export var frames : int = 1
@export var drops : Array[Pickups]
@export var gold : int = 0

@export var spawn_weight: float = 1.0
@export var unlock_minute: int = 0 

enum EnemyClass { MELEE, RANGED, BRAWLER, TANK, MAGE, ASSASSIN }
@export var enemy_class: EnemyClass = EnemyClass.MELEE
