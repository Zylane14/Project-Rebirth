extends Panel

var skill_tree
var total_stat : Stats #variable to store total stats from skill tree

func _ready():
	load_skill_tree() #loads skill tree when ready

func load_skill_tree():
	var branch_count = get_child_count()
	var is_valid_tree = (
		SaveData.skill_tree.size() == branch_count and
		SaveData.skill_tree.all(func(branch): return branch is Array)
	)

	if not is_valid_tree:
		set_skill_tree()
	
	skill_tree = SaveData.skill_tree
	for branch in get_children():
		var branch_index = branch.get_index()
		for upgrade in branch.get_children():
			var upgrade_index = upgrade.get_index()
			if branch_index < skill_tree.size() and upgrade_index < skill_tree[branch_index].size():
				upgrade.enabled = skill_tree[branch_index][upgrade_index]
	get_total_stats()


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
	total_stat.amplify += stat.amplify
	total_stat.area += stat.area
	total_stat.magnet += stat.magnet
	total_stat.growth += stat.growth
	total_stat.luck += stat.luck
	total_stat.crit += stat.crit
	total_stat.crit_damage += stat.crit_damage

func get_total_stats():
	total_stat = Stats.new()
	for branch in get_children():
		for upgrade in branch.get_children():
			if upgrade.enabled:
				add_stats(upgrade.skill.stats) #adds stats from every upgrade
	Persistence.bonus_stats = total_stat
	
