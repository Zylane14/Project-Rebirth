extends TextureButton

@onready var options_menu = get_parent()
@onready var label = $Label

func _ready():
	label.text = "Exit" 
	self.pressed.connect(on_exit_pressed)

func on_exit_pressed():
	print("Exit button pressed!")
	options_menu.hide() 
