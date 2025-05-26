extends Panel

var skill_tree
var total_stat : Stats #variable to store total stats from skill tree

func _ready():
	load_skill_tree() #loads skill tree when ready

func load_skill_tree():
	if SaveData.skill_tree == []: #if SaveData skill tree is empty, the set default values
		set_skill_tree()
	
	skill_tree = SaveData.skill_tree #else get the values and traverse through the elements
	for branch in get_children():
		for upgrade in branch.get_children():
			upgrade.enabled = skill_tree[branch.get_index()][upgrade.get_index()] #set it's enabled property to every upgrades
	get_total_stats() #get total stats after loading the skill tree

func set_skill_tree():
	skill_tree = []
	for each_branch in get_children(): #gets all the branches of the skill tree
		var branch = []
		for upgrade in each_branch.get_children(): #get enable property from upgrades of each branch and store it in array
			branch.append(upgrade.enabled)
		skill_tree.append(branch) #append the branch in skill tree
	
	SaveData.skill_tree = skill_tree #update skill tree and set & save it
	SaveData.set_and_save()

func add_stats(stat):
	total_stat.max_health += stat.max_health
	total_stat.recovery += stat.recovery
	total_stat.armor += stat.armor
	total_stat.movement_speed += stat.movement_speed
	total_stat.might += stat.might
	total_stat.area += stat.area
	total_stat.magnet += stat.magnet
	total_stat.growth += stat.growth

func get_total_stats():
	total_stat = Stats.new()
	for branch in get_children():
		for upgrade in branch.get_children():
			if upgrade.enabled:
				add_stats(upgrade.skill.stats) #adds stats from every upgrade
	Persistence.bonus_stats = total_stat
