extends Resource
class_name Item

# Rarity enum
enum Rarity { COMMON, RARE, EPIC, SPECIAL, LEGENDARY }

#common properties for Item
@export_category("Information")
@export var title : String
@export_multiline var description: String = ""
@export var icon : Texture2D #texture and icon stored seperately
@export var texture : Texture2D
@export var rarity: Rarity = Rarity.COMMON #default to COMMON
@export var level = 0

func upgrade_item(): #abstract function in item to keep a track
	pass
