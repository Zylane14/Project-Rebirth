extends CanvasLayer
class_name LevelUpPopup

@export var blessing_pool: Array[Blessing]
@export var blessing_card_scene: PackedScene
@export var player: Player

@onready var portrait: TextureRect = %GodPortrait
@onready var dialogue: Label = %GodDialogue
@onready var blessing_container: HBoxContainer = %BlessingOptions

var current_blessings: Array[Blessing] = []

func show_popup():
	get_tree().paused = true
	visible = true
	blessing_container.clear_children()
	_generate_blessings()

func _generate_blessings():
	current_blessings.clear()
	var chosen = blessing_pool.duplicate()
	chosen.shuffle()
	current_blessings = chosen.slice(0, 3)

	var god = current_blessings[0].zodiac
	portrait.texture = god.portrait
	dialogue.text = god.dialogue_lines.pick_random()

	for blessing in current_blessings:
		var card = blessing_card_scene.instantiate()
		card.set_blessing(blessing)
		card.pressed.connect(_on_blessing_chosen.bind(blessing))
		blessing_container.add_child(card)

func _on_blessing_chosen(blessing: Blessing):
	blessing.apply_blessing(player)
	hide_popup()

func hide_popup():
	get_tree().paused = false
	visible = false
