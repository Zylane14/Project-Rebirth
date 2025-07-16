extends Control

@onready var option_button = $HBoxContainer/OptionButton as OptionButton

const RESOLUTION_DICTIONARY : Dictionary = {
	"640 x 360" : Vector2i(640, 360),
	"1280 x 720" : Vector2i(1280, 720),
	"1920 x 1080" : Vector2i(1920, 1080)
}

func _ready():
	add_resolution_items()
	option_button.item_selected.connect(on_resolution_selected)

func add_resolution_items() -> void:
	for resolution_text in RESOLUTION_DICTIONARY.keys():
		option_button.add_item(resolution_text)

func on_resolution_selected(index : int) -> void:
	var selected_text = option_button.get_item_text(index)
	var selected_size = RESOLUTION_DICTIONARY[selected_text]
	DisplayServer.window_set_size(selected_size)
