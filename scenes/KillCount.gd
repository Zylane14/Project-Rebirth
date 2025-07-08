extends TextureRect

@onready var kill_label = $EnemyKills  # Make sure this matches your scene

var last_kill_count := -1

func _process(_delta: float) -> void:
	if GlobalManager.enemy_kill_count != last_kill_count:
		last_kill_count = GlobalManager.enemy_kill_count
		kill_label.text = "Kills: " + str(last_kill_count)
