extends VBoxContainer

const path = "res://resources/Enemies/"

var enemies = []

func _ready():
	dir_contents() #load the beastiary on ready

func dir_contents():
	var dir = DirAccess.open(path) #function to get file names from directory
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			print("Found file: " + file_name)
			
			var resource = load(path + file_name)
			if resource is Enemy:
				var enemy_resource: Enemy = resource
				enemies.append(enemy_resource)

				var button = Button.new()
				button.pressed.connect(_on_pressed.bind(button))
				button.text = enemy_resource.title
				add_child(button)
			
			file_name = dir.get_next()
	else:
		print("An error occured while trying to access the path.")
	print(enemies)

func _on_pressed(button : Button):
	var index = button.get_index()
	var enemy = enemies[index]

	%Name.text = "Name : " + enemy.title
	%Health.text = "Health : " + str(enemy.health)
	%Damage.text = "Damage : " + str(enemy.damage)
	%Speed.text = "Speed : " + str(enemy.speed)
	%Cooldown.text = "Cooldown : " + str(enemy.attack_cooldown) + "s"

	%Class.text = "Class : " + Enemy.EnemyClass.keys()[enemy.enemy_class]
	%Unlock.text = "Unlock : " + str(enemy.unlock_minute) + " min"
	%SpawnWeight.text = "Spawn : " + str(enemy.spawn_weight)

	# Sprite Animation
	var sprite_node: AnimatedSprite2D = %Texture
	sprite_node.sprite_frames = enemy.frames
	sprite_node.play("idle")

	SoundManager.play_sfx(load("res://music & sfx/RPG_Essentials_Free/10_UI_Menu_SFX/071_Unequip_01.wav"))
