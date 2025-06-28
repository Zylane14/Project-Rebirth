extends Item
class_name Artifact

@export var stat_bonus: Stats # Flat stats added when picked
@export_multiline var description: String
@export var passive_script: Script

var player_reference
var passive_instance: Node = null

func get_bonus() -> Stats:
	return stat_bonus

func apply_passive(target):
	if passive_script:
		passive_instance = passive_script.new()
		if passive_instance.has_method("apply"):
			passive_instance.apply(target)
	
	# Apply stat bonus to player
	if target and target.has_method("add_stats"):
		target.add_stats(stat_bonus)

func remove_passive(target):
	if passive_instance and passive_instance.has_method("remove"):
		passive_instance.remove(target)
		passive_instance = null

	# Remove stat bonus from player
	if target and target.has_method("remove_stats"):
		target.remove_stats(stat_bonus)
