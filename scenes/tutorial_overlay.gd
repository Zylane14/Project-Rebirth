extends CanvasLayer

@onready var labels := [
	$HBoxContainer/WASD,
	$HBoxContainer/Spacebar,
	$HBoxContainer/Inventory,
	$HBoxContainer/Light,
	$HBoxContainer/Mouse,
	$RichTextLabel
]

func _ready() -> void:
	for label in labels:
		label.modulate.a = 1.0
	show()
	fade_out_after_delay()

func fade_out_after_delay():
	await get_tree().create_timer(10.0).timeout
	var tween = create_tween()
	for label in labels:
		tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.finished.connect(_on_fade_out_finished)

func _on_fade_out_finished():
	hide()
