extends Resource
class_name Artifact

# Artifact Rarity Enum
enum Rarity {NORMAL, RARE, EPIC, SPECIAL, LEGENDARY}

@export var name: String
@export var description: String
@export var rarity: Rarity = Rarity.NORMAL
@export var icon: Texture2D

# Instead of using a Dictionary, reference your Stats resource directly
@export var stats_modifiers: Stats

# Optional passive behavior
@export var passive_script: Script
