extends TextureButton

@export var skill : Skill #variable to store skill class
var enabled : bool = false:
	set(value):
		enabled = value
		$Panel.show_behind_parent = value
		
		if value: #adds corner points for the outline if skill is enabled
			$Outline.add_point(Vector2(0, -1))
			$Outline.add_point(Vector2(40, -1))
			$Outline.add_point(Vector2(40, 39))
			$Outline.add_point(Vector2(0, 39))
		if value and get_index() !=0: #for connection, add midpoints for 2 upgrades
			$Connection.add_point(Vector2(20, 20) + initial_modifier()) #add initial modifier to the first connection
			$Connection.add_point(get_parent().get_child(get_index() - 1).position - position + Vector2(20,20) + final_modifier()) #final modifier for the second


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
		SoundManager.play_sfx(load("res://music & sfx/RPG_Essentials_Free/10_UI_Menu_SFX/051_use_item_01.wav"))
		SaveData.gold -= skill.cost
		enabled = true #pressing it will buy and enable it
		get_parent().get_parent().set_skill_tree() #pressing the button will set the skill tree
		get_parent().get_parent().get_total_stats() #update total stats when player buys new skills

func initial_modifier() -> Vector2:
	var difference = get_parent().get_child(get_index() - 1).position - position 
	var modification : Vector2 = Vector2.ZERO
	
	if difference.x < 0:
		modification += Vector2(-20,0)
	elif difference.x > 0:
		modification += Vector2(20,0)
	
	if difference.y < 0:
		modification += Vector2(0, -20)
	elif difference.y > 0:
		modification += Vector2(0, 20)
	
	return modification

func final_modifier() -> Vector2:
	var difference = get_parent().get_child(get_index() - 1).position - position 
	var modification : Vector2 = Vector2.ZERO
	
	if difference.x < 0:
		modification += Vector2(20,0)
	elif difference.x > 0:
		modification += Vector2(-20,0)
	
	if difference.y < 0:
		modification += Vector2(0, 20)
	elif difference.y > 0:
		modification += Vector2(0, -20)
	
	return modification
