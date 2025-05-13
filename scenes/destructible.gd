extends Sprite2D

var frame_counter = 0
var seperation : float
var health : float = 10:
	set(value):
		health = value
		if health < 0:
			drop_item() #drop item when health is below 0
	
@onready var player_reference = get_tree().current_scene.find_child("Player") #get the player from the scene tree
var drop_node = preload("res://scenes/pickups.tscn")
@export var drops : Array[Pickups]

func _physics_process(_delta):
	frame_counter += 1
	if frame_counter >= 6:
		frame_counter = 0
		frame = (frame + 1) % (hframes * vframes) #animates the sprite
	
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
	var item = drops.pick_random() #get random pickup and instantiate the node
	
	var item_to_drop = drop_node.instantiate()
	
	item_to_drop.type = item
	item_to_drop.position = position
	item_to_drop.player_reference = player_reference #properties
	
	get_tree().current_scene.call_deferred("add_child", item_to_drop)
	queue_free()
