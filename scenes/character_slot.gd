extends Panel

var icon = null:
	set(value):
		icon = value
		$TextureButton.texture_normal = value #variable icon that updates texture from the button

signal pressed

func _ready():
	$Select.hide()

func _button_pressed() -> void:
	for slot in get_parent().get_children(): #pressing this slot will deselect all its sibling slots
		slot.deselect()
	
	$Select.show() #show current slot and emit pressed signal
	pressed.emit()

func deselect():
	$Select.hide()
