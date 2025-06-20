extends Resource
class_name Enemy

@export var title : String
@export var animation_name: String
@export var texture : Texture2D #set different propert for the enemy
@export var scale: Vector2 = Vector2(1, 1)
@export var health : float
@export var damage : float
@export var speed : float
@export var drops : Array[Pickups]
#@export var gold : int = 0
#@export var HurtSound : AudioStream #property for storing audio

@export var spawn_weight: float = 1.0
@export var unlock_minute: float = 0.0 

enum EnemyClass { MELEE, RANGED, BRAWLER, TANK, MAGE, ASSASSIN, HYBRID }
@export var enemy_class: EnemyClass = EnemyClass.MELEE


#Enemy Attack
@export var attack_cooldown : float = 1.5
@export var attack_range : float = 60.0 # used for melee
@export var ranged_attack_range : float = 300.0 # used for hybrid or ranged attacks
@export var projectile_spawns_at_player: bool = false
@export var projectile_scene : PackedScene = null # used for ranged
