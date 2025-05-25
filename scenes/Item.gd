extends Resource
class_name Item

#common properties for Item
@export var title : String
@export var icon : Texture2D #texture and icon stored seperately
@export var texture : Texture2D
var level = 1

func upgrade_item(): #abstract function in item to keep a track
	pass
