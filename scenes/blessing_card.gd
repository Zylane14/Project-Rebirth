extends Button

@onready var icon = %Icon
@onready var title_label = %Title
@onready var description_label = %Description

var blessing: Blessing

func set_blessing(b: Blessing):
	blessing = b
	icon.texture = b.icon
	title_label.text = b.title
	description_label.text = b.description
