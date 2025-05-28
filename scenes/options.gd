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
	
	
	
	if option_size == 0: #if none of the weapons can be upgraded again, return the function
		return
	
	show()
	particles.show() #show both while showing option
	panel.show()
	get_tree().paused = true #else show the option and pause the scene tree

func dir_contents(path):
	var dir = DirAccess.open(path)
	var item_resources = []
	if dir:
		dir.last_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			print("Found file: " + file_name)
			var item_resource : Item = load(path + file_name)
			item_resources.append(item_resources)
			file_name =dir.get_next()
	else:
		print("An error occured while trying to access the path.")
		return null
	return item_resources


func get_available_upgrades()-> Array[Item]: #set function that will return an array of item
	var upgrades : Array[Item] = []
	for weapon : Weapon in get_available_resource_in(weapons):
		if weapon.is_upgradeable(): #push available weapons to the array
			upgrades.append(weapon)
	
	for passive_item : PassiveItem in get_available_resource_in(passive_items):
		if passive_item.is_upgradeable(): #if any passive item is upgradeable, push it to the array
			upgrades.append(passive_item)
	
	return upgrades
