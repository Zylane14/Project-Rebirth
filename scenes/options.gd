extends HBoxContainer

@export var weapons : VBoxContainer #variable to store weapon container
@export var passive_items : VBoxContainer #variable to store container for passive items in Option
var OptionSlot = preload("res://scenes/option_slot.tscn") #preloads the option slot

#variable to store both particle and panel
@export var particles : GPUParticles2D
@export var panel : NinePatchRect
@export var player_reference : CharacterBody2D


const weapon_path : String = "res://resources/Weapons/" 
const passive_item_path : String = "res://resources/Passive Items/"

var every_item #variable to store every item, weapon & passive resources
var every_weapon
var every_passive

var game_paused := false
	
func _ready(): #on ready hide the option
	hide()
	particles.hide() #on ready, hide both particle and panel
	panel.hide()
	get_all_item() #load and store every item on ready
	
func close_option(): #will hide option and resume the scene tree
	hide()
	particles.hide() #hide both while closing option
	panel.hide()
	%Gold.show()
	%XP.show()
	get_tree().paused = false

func get_available_resource_in(items)-> Array[Item]: #function to extract resource from the slot present in the container
	var resources : Array[Item] = []
	for item in items.get_children():
		if item.item != null:
			resources.append(item.item)
	return resources

func add_option(item) -> int: #function to add Option with the item Resource
	if item is Item and item.is_upgradeable():
		var option_slot = OptionSlot.instantiate()
		option_slot.item = item
		add_child(option_slot)
		return 1 #if the item can be upgraded return 1, else return 0
	return 0


func show_option():
	var weapons_available = get_available_resource_in(weapons)
	var passive_item_available = get_available_resource_in(passive_items)

	if weapons_available.size() == 0 and passive_item_available.size() == 0:
		return

	# Remove previous options
	for slot in get_children():
		slot.queue_free()

	var available = get_equipped_item()

	# Add unequipped upgradeable items if there's space
	if slot_available(weapons):
		available.append_array(get_upgradeable(every_weapon, get_equipped_item()))
	if slot_available(passive_items):
		available.append_array(get_upgradeable(every_passive, get_equipped_item()))

	available.shuffle()

	var modifier := 0
	var luck_roll := randf() * 100.0
	if luck_roll < owner.luck:
		modifier = 1

	var option_size := 0

	# Handle evolutions
	for weapon in weapons_available:
		if weapon.max_level_reached() and weapon.item_needed in passive_item_available:
			var option_slot = OptionSlot.instantiate()
			available.append(weapon)
			option_slot.item = weapon
			add_child(option_slot)
			option_size += 1

	# Add up to 4 options max (even if lucky)
	var max_options: int = min(4, 3 + modifier)
	for i in range(max_options):
		if available.size() > 0:
			option_size += add_option(available.pop_front())

	if option_size == 0:
		return

	# Dynamic spacing based on number of options
	if option_size == 4:
		self.add_theme_constant_override("separation", 5) # tighter spacing for 4
	else:
		self.add_theme_constant_override("separation", 20) # default spacing

	# Show UI
	show()
	particles.show()
	panel.show()
	%Gold.hide()
	%XP.hide()
	get_tree().paused = true

func dir_contents(path):
	var dir = DirAccess.open(path)
	var item_resources = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".remap") or file_name.ends_with(".tres") or file_name.ends_with(".res"): # Only load valid resource files
				var resource = load(path + file_name)
				if resource is Item: # ensure it's an Item before adding
					item_resources.append(resource)
				else:
					print("Skipped non-item resource: ", file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred while trying to access the path.")
		return []
	return item_resources


func get_all_item():
	var item_resources = dir_contents(weapon_path)
	every_weapon = item_resources #load and store weapon resources
	
	item_resources = dir_contents(passive_item_path)
	every_passive = item_resources #load and store passive resources
	
	every_item = every_weapon.duplicate() #combines them to store every item
	every_item.append_array(every_passive)


func slot_available(items):
	for item in items.get_children(): #function to check for empty slots
		if item.item == null:
			return true
	return false

func get_upgradeable(items, flag = []): #set flag to not include specific items
	var array = []
	for item in items:
		if item.is_upgradeable() and item not in flag:
			if item is Weapon and GlobalManager.is_evolved(item.title):
				continue  # Skip already-evolved weapons
			array.append(item)
	return array


func get_equipped_item():
	var equipped_items = get_available_resource_in(weapons)
	equipped_items.append_array(get_available_resource_in(passive_items)) #get the equipped items from the slots
	
	return get_upgradeable(equipped_items) #return only the upgradeable ones


func add_weapon(item): #function to add weapon to weapon slot
	for slot in weapons.get_children():
		if slot.item == null:
			slot.item = item
			return

func add_passive(item): #function to add passive to passive slots
	for slot in passive_items.get_children():
		if slot.item == null:
			slot.item = item
			return
		
func check_item(item): #check function, if item is already present in slot then return
	if item in get_available_resource_in(weapons) or item in get_available_resource_in(passive_items):
		return
	else:
		if item is Weapon:
			add_weapon(item)
		elif item is PassiveItem:
			item.player_reference = owner
			add_passive(item)

func get_available_upgrades()-> Array[Item]: #set function that will return an array of item
	var upgrades : Array[Item] = []
	for weapon : Weapon in get_available_resource_in(weapons):
		if weapon.is_upgradeable(): #push available weapons to the array
			upgrades.append(weapon)
	
	for passive_item : PassiveItem in get_available_resource_in(passive_items):
		if passive_item.is_upgradeable(): #if any passive item is upgradeable, push it to the array
			upgrades.append(passive_item)
	
	return upgrades
