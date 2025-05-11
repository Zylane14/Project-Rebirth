extends VBoxContainer

@export var weapons : HBoxContainer #variable ro store weapon container
var OptionSlot = preload("res://scenes/option_slot.tscn") #preloads the option slot

#variable to store both particle and panel
@export var particles : GPUParticles2D
@export var panel : NinePatchRect

func _ready(): #on ready hide the option
	hide()
	particles.hide() #on ready, hide both particle and panel
	panel.hide()

func close_option(): #will hide option and resume the scene tree
	hide()
	particles.hide() #hide both while closing option
	panel.hide()
	get_tree().paused = false

func get_available_weapons(): #checks all weapons and store available weapon resource
	var weapon_resource = []
	for weapon in weapons.get_children():
		if weapon.weapon != null:
			weapon_resource.append(weapon.weapon)
	return weapon_resource #return the array of weapon resource

func show_option():
	var weapons_available = get_available_weapons()
	if weapons_available.size() == 0: #if there are no weapon resource, return the show function
		return
	
	for slot in get_children(): #if there is any weapon, then remove previous option
		slot.queue_free()
	
	var option_size = 0
	for weapon in weapons_available:
		if weapon.is_upgradeable():
			var option_slot = OptionSlot.instantiate() #add option for every weapon available
			option_slot.weapon = weapon
			add_child(option_slot)
			option_size += 1
	
	if option_size == 0: #if none of the weapons can be upgraded again, return the function
		return
	
	show()
	particles.show() #show both while showing option
	panel.show()
	get_tree().paused = true #else show the option and pause the scene tree
