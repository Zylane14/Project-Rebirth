extends NinePatchRect

@onready var chest = $AnimatedSprite2D
@onready var options = %Options
@onready var rewards = $Rewards
@export var sound = AudioStream

func _ready():
	randomize() #set different seed every run
	hide()
	$Open.show()
	$Close.hide()
	
	
func open(): #in open function, play idle and pause the scene tree
	clear_reward()
	chest.play("idle_boss_chest")
	get_tree().paused = true
	show()
	$Open.show()
	$Close.hide()


func _on_open_pressed(): #play open animation on pressing the button
	chest.play("open_boss_chest")
	SoundManager.play_sfx(load("res://music & sfx/Minifantasy_Dungeon_SFX/01_chest_open_3.wav"))
	await chest.animation_finished #wait for animation then set reward
	set_reward()
	$Open.hide()
	$Close.show() #after opening chest, show close button


func _on_close_pressed(): #resumes the scene tree and hide the chest
	get_tree().paused = false
	hide()


func set_reward():
	# Set rewards for each slot independently; gold chance depends on player luck.
	clear_reward()
	var weights = [5.0, 2.0, 1.0] #weights for rare, epic, legendary upgrades

	# --- Gold chance based on luck ---
	var min_gold_chance = 0.2 # never less than 20% gold chance
	var max_gold_chance = 0.7 # up to 70% gold chance at lowest luck
	var luck = owner.luck if owner.has_method("luck") else 1.0 # fallback if no luck property
	var gold_chance = clamp(max_gold_chance - (luck * 0.1), min_gold_chance, max_gold_chance)
	# e.g. at luck = 1.0, gold chance = 0.6. At luck = 5.0, gold chance = 0.2 (never lower).

	for index in range(rewards.get_child_count()): # loop through each reward slot
		var roll = randf()
		if roll < gold_chance:
			add_gold(index)
			print("Gold reward")
		else:
			# Roll for upgrade rarity
			var rarity_chance = randf()
			var rarity = 0
			if rarity_chance < get_weighted_chance(weights, 0):
				rarity = 2 # rare
			elif rarity_chance < get_weighted_chance(weights, 1):
				rarity = 1 # epic
			else:
				rarity = 0 # legendary
			upgrade_item(index, rarity)



func upgrade_item(start, end):
	for index in range(start, end):
		var upgrades = options.get_available_upgrades() #in for loop, get the available upgrades
		
		if upgrades.size() == 0: #return the function if no upgrades available
			add_gold(index) #add gold when no upgrades available
		else:
			var selected_upgrade : Item
			selected_upgrade = upgrades.pick_random() #if there are any upgrades, then pick a random upgrade
			rewards.get_child(index).texture = selected_upgrade.icon
			
			rewards.get_child(index).show()
			selected_upgrade.upgrade_item()


func clear_reward():
	for slot in rewards.get_children(): #function to clear the rewards
		slot.texture = null
		slot.hide()

func add_gold(index):
	var gold : Gold = load("res://resources/Pickups/Gold.tres") #loads the gold
	gold.player_reference = owner
	rewards.get_child(index).texture = gold.icon
	rewards.get_child(index).show()
	gold.activate() #activates gold

func get_weighted_chance(weight, index):
	var modified_weight = []
	var sum = 0
	for i in range(weight.size()):
		if i == 0:
			modified_weight.append(weight[i])
			sum += weight[i]
		else:
			modified_weight.append(weight[i] * owner.luck) #higher luck = better rarity
			sum += weight[i] * owner.luck
	
	var cumulative = 0
	for i in range(index + 1):
		cumulative += modified_weight[i] #get the cumulative fraction and return it
	
	return float(cumulative)/sum
