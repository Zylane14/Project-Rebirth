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
	if chance < 0.5: #50% rare
		upgrade_item(2,3) #for rare chance, only the middle element will get filled
		print("rare")
	elif chance < 0.75: #25% epic
		upgrade_item(1,4) #for epic, middle 3 will get filled
		print("epic")
	else:
		upgrade_item(0,5) #all 5 will be used
		print("legendary") #25% legendary

func upgrade_item(start, end):
	for index in range(start, end):
		var upgrades = options.get_available_upgrades() #in for loop, get the available upgrades
		
		if upgrades.size() == 0: #return the function if no upgrades available
			add_gold(index) #add gold when no upgrades available
		else:
			var selected_upgrade : Item
			selected_upgrade = upgrades.pick_random() #if there are any upgrades, then pick a random upgrade
			rewards.get_child(index).texture = selected_upgrade.texture #set texture and upgrade the selected item
			selected_upgrade.upgrade_item()

func clear_reward():
	for slot in rewards.get_children(): #function to clear the rewards
		slot.texture = null

func add_gold(index):
	var gold : Gold = load("res://resources/Pickups/Gold.tres") #loads the gold
	gold.player_reference = owner
	rewards.get_child(index).texture = gold.icon
	gold.activate() #activates gold
