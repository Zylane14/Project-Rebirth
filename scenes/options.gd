extends VBoxContainer

@export var weapons : HBoxContainer #variable ro store weapon container
@export var passive_items : HBoxContainer #variable to store container for passive items in Option
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

func get_available_resource_in(items)-> Array[Item]: #function to extract resource from the slot present in the container
	var resources : Array[Item] = []
	for item in items.get_children():
		if item.item != null:
			resources.append(item.item)
	return	resources

func add_option(item) -> int: #function to add Option with the item Resource
	if item.is_upgradeable():
		var option_slot = OptionSlot.instantiate()
		option_slot.item = item
		add_child(option_slot)
		return 1 #if the item can be upgraded return 1, else return 0
	return 0


func show_option():
	var weapons_available = get_available_resource_in(weapons)
	var passive_item_available = get_available_resource_in(passive_items) #get both weapon and passive item and store them
	if weapons_available.size() == 0 and passive_item_available.size() == 0: #if there are no weapon resource, return the show function
		return
	
	for slot in get_children(): #if there is any weapon, then remove previous option
		slot.queue_free()
	
	var option_size = 0
	for weapon in weapons_available:
		option_size += add_option(weapon) #add weapon option for any available upgrade
		
		#if weapon reached max level, and if the passive is available
		if weapon.max_level_reached() and weapon.item_needed in passive_item_available:
			var option_slot = OptionSlot.instantiate()
			option_slot.item = weapon #add option for overleveling to trigger evolution
			add_child(option_slot)
			option_size += 1
	
	for passive_item in passive_item_available:
		option_size += add_option(passive_item)
	
	if option_size == 0: #if none of the weapons can be upgraded again, return the function
		return
	
	show()
	particles.show() #show both while showing option
	panel.show()
	get_tree().paused = true #else show the option and pause the scene tree
