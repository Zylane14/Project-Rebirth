extends PanelContainer

@export var item : Artifact: #variable to store passive items
	set(value): #setter to update texture
		item = value
		$TextureRect.texture = value.texture 

func _ready():
	if item != null:
		item.player_reference = owner #sets player reference to the item

func _on_mouse_entered() -> void:
	if item == null:
		return
		
	Popups.ItemPopup(Rect2i( Vector2i(global_position), Vector2i(size) ), item)


func _on_mouse_exited() -> void:
	Popups.HideItemPopup() #hide ItemPopup when mouse exits the slot
