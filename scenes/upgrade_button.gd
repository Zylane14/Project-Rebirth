extends TextureButton

@export var skill : Skill #variable to store skill class
var enabled : bool = false:
	set(value):
		enabled = value
		$Panel.show_behind_parent = value


func _ready():
	if skill:
		texture_normal = skill.texture #sets texture from the skill resource

func is_upgradeable() -> bool: #function to check if skill is upgradeable
	if get_index() == 0: #always upgradeable for the first element
		return true
	elif get_index() > 0: #if the previous skill is upgraded, only the current skill is upgradeable
		if get_parent().get_child(get_index() - 1).enabled == true:
			return true
		else:
			return false
	
	return false


func _on_pressed():
	if skill.cost <= SaveData.gold and is_upgradeable() and not enabled:
		SaveData.gold -= skill.cost
		enabled = true #pressing it will buy and enable it
		get_parent().get_parent().set_skill_tree() #pressing the button will set the skill tree
		get_parent().get_parent().get_total_stats() #update total stats when player buys new skills
