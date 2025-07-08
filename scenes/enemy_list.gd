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
	%Name.text = "Name : " + enemies[index].title #function to update beastiary labels
	%Health.text = "Health : " + str(enemies[index].health)
	%Damage.text = "Damage : " + str(enemies[index].damage)
	var sprite_node: AnimatedSprite2D = %Texture
	sprite_node.sprite_frames = enemies[index].frames
	sprite_node.play("idle")
	SoundManager.play_sfx(load("res://music & sfx/RPG_Essentials_Free/10_UI_Menu_SFX/071_Unequip_01.wav"))
