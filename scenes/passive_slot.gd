extends PanelContainer

@export var item : PassiveItem: #variable to store passive items
	set(value): #setter to update texture
		item = value
		$TextureRect.texture = value.texture 


func _ready():
	if item != null:
		item.player_reference = owner #sets player reference to the item
