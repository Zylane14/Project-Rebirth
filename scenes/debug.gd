extends VBoxContainer

func _ready():
	for child in %Debug.get_children():
		if child is Label:
			child.connect("mouse_entered", Callable(self, "_on_stat_hovered").bind(child))
			child.connect("mouse_exited", Callable(self, "_on_stat_exit"))

func _on_stat_hovered(label: Label):
	var descriptions = {
		"Damage": "Damage dealt by the player per hit.",
		"Armor": "Reduces incoming damage.",
		"HealthMax": "Maximum HP of the player.",
		"Recovery": "HP recovered per second.",
		# Add more as needed
	}
	
	var text = descriptions.get(label.name, "No description.")
	Popups.TooltipPopup.show_tooltip(text, get_viewport().get_mouse_position())

func _on_stat_exit():
	Popups.TooltipPopup.hide_tooltip()
