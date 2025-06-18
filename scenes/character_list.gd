extends GridContainer

@onready var starting_weapon = %StartingWeapon
@onready var start_button = %Start # Reference to StartButton
@onready var portrait_display = %Portrait
@export var character_slot : PackedScene

@export var characters : Array[Character] #variable to store characters

func _ready() -> void: #call the load function on ready
	load_character()
	start_button.visible = false #hide start button

func load_character():
	for character in characters:
		var slot = character_slot.instantiate() #instatiate character slot
		slot.icon = character.icon
		slot.pressed.connect(_on_pressed.bind(character)) #connect the pressed signal to the pressed function
		add_child(slot) #add slot to GridContainer

func _on_pressed(character : Character): #presseng any character slot will store a reference in Persistence Autoload
	Persistence.character = character
	starting_weapon.texture = character.starting_weapon.icon #updates the texture of starting weapon of currently selected character
	portrait_display.texture = character.portrait
	%Portrait.show()
	start_button.visible = true #show the Start button when a character is selected
