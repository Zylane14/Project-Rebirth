extends Node
class_name LevelManager

var player: Node = null
var current_level: Node = null

var LEVELS := {
	"test_scene": preload("res://scenes/test_scene.tscn"),
	"lobby": preload("res://scenes/lobby.tscn"),
}

func _ready():
	player = get_tree().get_first_node_in_group("player")

func change_level(level_tag: String, door_tag: String) -> void:
	if not LEVELS.has(level_tag):
		push_error("Unknown level tag: %s" % level_tag)
		return

	var new_level_scene = LEVELS[level_tag]
	var new_level = new_level_scene.instantiate()

	# Add new level first
	get_tree().current_scene.add_child(new_level)

	# Find the destination door
	var target_door: Door = null
	for node in new_level.get_tree().get_nodes_in_group("door"):
		if node is Door and node.door_tag == door_tag:
			target_door = node
			break

	if target_door == null:
		push_error("Target door '%s' not found in level '%s'" % [door_tag, level_tag])
		return

	# Move player
	player.reparent(get_tree().current_scene)
	player.global_position = target_door.spawn.global_position
	player.velocity = Vector2.ZERO

	match target_door.spawn_direction:
		"left":
			player.last_move_dir = Vector2.LEFT
		"right":
			player.last_move_dir = Vector2.RIGHT
		"down":
			player.last_move_dir = Vector2.DOWN
		"up":
			player.last_move_dir = Vector2.UP

	# Remove old level
	if current_level:
		current_level.queue_free()
	current_level = new_level
