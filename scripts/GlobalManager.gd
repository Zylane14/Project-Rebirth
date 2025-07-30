extends Node

##==============================
## GLOBAL GAME STATE
##==============================
var global_buff_stage: int = 0
var elapsed_time: float = 0.0
var buff_interval: float = 15.0
var enemy_kill_count : int = 0
var evolved_weapons: Array[String] = []
var owned_items: Array[Item] = []

##==============================
## ENEMY REGISTRY FOR SWARMING
##==============================
var enemies: Array = []

func _process(delta: float) -> void:
	elapsed_time += delta
	var expected_stage = int(elapsed_time / buff_interval)

	if expected_stage > global_buff_stage:
		global_buff_stage = expected_stage
		print("Buff stage increased to: ", global_buff_stage)

func reset():
	global_buff_stage = 0
	elapsed_time = 0.0
	enemy_kill_count = 0
	enemies.clear()

func register_enemy(enemy: Node) -> void:
	if enemy not in enemies:
		enemies.append(enemy)

func unregister_enemy(enemy: Node) -> void:
	enemies.erase(enemy)

func clear_all_enemies():
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	enemies.clear()

func get_enemy_count() -> int:
	return enemies.size()
	
	
func register_evolution(weapon: Weapon):
	var title = weapon.title if weapon.title != "" else weapon.resource_path
	if title not in evolved_weapons:
		evolved_weapons.append(title)

func is_evolved(title: String) -> bool:
	return title in evolved_weapons
	
func has_item(target_item: Item) -> bool:
	for item in owned_items:
		if item == target_item:
			return true
	return false
