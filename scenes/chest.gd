extends NinePatchRect

@onready var chest = $AnimatedSprite2D
@onready var options = %Options
@onready var rewards = $Rewards

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


func set_reward(): #set reward get a random value between 0 and 1
	clear_reward()
	var chance = randf()
	var weight = [5.0,2.0,1.0] #weight for rare, epic, and legendary chance
	print(chance)
	if chance < get_weighted_chance(weight, 0):
		upgrade_item(2,3)
		print("rare")
	elif chance < get_weighted_chance(weight, 1):
		upgrade_item(1,4)
		print("epic")
	else:
		upgrade_item(0,5)
		print("legendary")


func upgrade_item(start, end):
	for index in range(start, end):
		var upgrades = options.get_available_upgrades() #in for loop, get the available upgrades
		
		if upgrades.size() == 0: #return the function if no upgrades available
			add_gold(index) #add gold when no upgrades available
		else:
			var selected_upgrade : Item
			selected_upgrade = upgrades.pick_random() #if there are any upgrades, then pick a random upgrade
			if selected_upgrade is Weapon and selected_upgrade.max_level_reached():
				rewards.get_child(index).texture = selected_upgrade.evolution.icon
			else:
				rewards.get_child(index).texture = selected_upgrade.icon
			
			selected_upgrade.upgrade_item()


func clear_reward():
	for slot in rewards.get_children(): #function to clear the rewards
		slot.texture = null

func add_gold(index):
	var gold : Gold = load("res://resources/Pickups/Gold.tres") #loads the gold
	gold.player_reference = owner
	rewards.get_child(index).texture = gold.icon
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
