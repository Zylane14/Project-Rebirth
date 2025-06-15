extends Node
class_name SummonChestPassive

@export var drop_scene: PackedScene  # This should be your generic Drop scene (e.g., "Drop.tscn")
@export var chest_item: Resource     # This is the specific Pickup type (e.g., "Chest.tres")
@export var summon_interval: float = 5.0 #300.0  # Every 5 minutes

var timer: Timer
var player_ref: Node

func activate(player):
	player_ref = player

	timer = Timer.new()
	timer.wait_time = summon_interval
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_on_timeout)
	player.add_child(timer)

func _on_timeout():
	if not drop_scene or not chest_item or not is_instance_valid(player_ref):
		return

	var item_to_drop = drop_scene.instantiate()
	item_to_drop.type = chest_item
	item_to_drop.position = player_ref.global_position + Vector2(randi_range(-40, 40), randi_range(-40, 40))
	item_to_drop.player_reference = player_ref
	player_ref.get_tree().current_scene.call_deferred("add_child", item_to_drop)
