extends Resource
class_name BossType

@export var title: String
@export var scale: Vector2 = Vector2(1, 1)
@export var health: float
@export var damage: float
@export var speed: float

# Boss-specific
@export var boss_music: AudioStream
@export var has_phase_2: bool = false
@export var phase_2_health_threshold: float = 0.5
@export var intro_animation: String
@export var special_attacks: Array[String]
