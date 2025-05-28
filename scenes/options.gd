extends VBoxContainer

@export var weapons : HBoxContainer #variable to store weapon container
@export var passive_items : HBoxContainer #variable to store container for passive items in Option
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


func _ready(): #on ready hide the option
	hide()
	particles.hide() #on ready, hide both particle and panel
	panel.hide()
	get_all_item() #load and store every item on ready

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
	var passive_item_available = get_available_resource_in(passive_items) #get both weapon and passive item and store them
	
	if weapons_available.size() == 0 and passive_item_available.size() == 0: #if there are no weapon resource, return the show function
		return
	
	for slot in get_children(): #if there is any weapon, then remove previous option
		slot.queue_free()

	
	var available = get_equipped_item() #get the equipped item from the slots
	if slot_available(weapons): #if any empty weapon slot is available, add the new weapons to array
		available.append_array(get_upgradeable(every_weapon, get_equipped_item()))
	if slot_available(passive_items): #for empty passive slot, add new passive items
		available.append_array(get_upgradeable(every_passive, get_equipped_item()))
	available.shuffle() #shuffle entire array
	
	var chance = randf() #store random fraction in the variable chance
	var modifier : int = 1 if (chance < (1.0 - (1.0/owner.luck))) else 0 #formula for luck to get the fourth option
	
	var option_size = 0
		
	for i in range(3 + modifier): #add 3 options
		if available.size() > 0:
			option_size += add_option(available.pop_front()) #with for loop from available items
	
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
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			print("Found file: " + file_name)
			var item_resource : Item = load(path + file_name)
			item_resources.append(item_resource)
			file_name =dir.get_next()
	else:
		print("An error occured while trying to access the path.")
		return null
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
		if item.is_upgradeable() and item not in flag: #function to get only the upgradeable item
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

func get_upgradable(items, flag = []):
	var array = []
	for item in items:
		if item.is_upgradable() and item not in flag:
			array.append(item)
	return array

func get_available_upgrades()-> Array[Item]: #set function that will return an array of item
	var upgrades : Array[Item] = []
	for weapon : Weapon in get_available_resource_in(weapons):
		if weapon.is_upgradeable(): #push available weapons to the array
			upgrades.append(weapon)
		
		if weapon.max_level_reached() and weapon.item_needed in get_available_resource_in(passive_items):
			upgrades.append(weapon) #for evolution to show in chest
	
	for passive_item : PassiveItem in get_available_resource_in(passive_items):
		if passive_item.is_upgradeable(): #if any passive item is upgradeable, push it to the array
			upgrades.append(passive_item)
	
	return upgrades
