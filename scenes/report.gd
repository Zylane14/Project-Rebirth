extends Panel

@onready var text: RichTextLabel = $Panel/Text
@onready var weapons: VBoxContainer = %Weapons

var game_over : bool = false
var temp = [] #temp array for storing both current and previously used weapons

func _ready(): #hide the report on ready
	hide()

func _process(_delta): #update text in process function
	set_text()

func _input(event):
	if event.is_action_pressed("ui_cancel") and not game_over: #toggle report node by pressing ESC key
		visible = not visible
		get_tree().paused = visible

func _on_continue_pressed() -> void:
	visible = false
	%PauseButton.show()
	get_tree().paused = false #pressing continue will unpause the game
 
func set_icon(path : String):
	return "[img=32x32]%s[/img]" % path #function to set icon 

func get_available_resource_in(items) -> Array[Item]:
	var resources: Array[Item] = []
	if items == null:
		return resources
	for item in items.get_children():
		if item.item != null:
			resources.append(item.item)
	return resources


func set_text():
	if weapons == null:
		return  # Early exit if the weapons container no longer exists

	text.clear()

	for weapon : Weapon in get_available_resource_in(weapons):
		if weapon not in temp:
			temp.append(weapon)
		text.append_text(set_icon(weapon.icon.resource_path) + "%20.2f" % weapon.damage_dealt + "\n")

	for weapon : Weapon in temp:
		if weapon not in get_available_resource_in(weapons):
			text.append_text(set_icon(weapon.icon.resource_path) + "%20.2f" % weapon.damage_dealt + "\n")
