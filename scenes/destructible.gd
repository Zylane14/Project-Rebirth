extends Sprite2D
	
var frame_counter = 0
var health : float = 10:
	set(value):
		health = value
		if health < 0:
			drop_item() #drop item when health is below 0
var seperation : float
@onready var player_reference = get_tree().current_scene.find_child("Player") #get the player from the scene tree

var drop_node = preload("res://scenes/pickups.tscn")
@export var drops : Array[Pickups]


func _physics_process(_delta):
	frame_counter += 1
	if frame_counter >= 6:
		frame_counter = 0
		frame = (frame + 1) % 8 #animates the sprite
	
	seperation = (player_reference.position - position).length() #update seperation and if it's near player, then set nearest enemy
	if seperation < player_reference.nearest_enemy_distance:
		player_reference.nearest_enemy = self

func take_damage(amount = 1):
	health -= amount #taking damage reduces health
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(3, 0.25, 0.25), 0.2) #modulate color for the hit effect
	tween.chain().tween_property(self, "modulate", Color(1, 1, 1), 0.2)
	tween.bind_node(self)


func drop_item():
	var item = Drops.pick_weighted_drop(drops, player_reference.luck)
	if item == null:
		queue_free()
		return

	var item_to_drop = drop_node.instantiate()
	item_to_drop.type = item
	item_to_drop.position = position
	item_to_drop.player_reference = player_reference

	get_tree().current_scene.call_deferred("add_child", item_to_drop)
	queue_free()

func get_weighted_chance(weight, index):
	var sum = 0
	for i in range(weight.size()):
		sum += weight[i]
	
	var cumulative = 0
	for i in range(index + 1):
		cumulative += weight[i]
	
	return float(cumulative)/sum
