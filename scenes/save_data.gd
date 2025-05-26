extends Node2D

var gold = 1000
var skill_tree = []

const PATH = "user://player_data.cfg" #path for saving the config file in SaveData
@onready var config = ConfigFile.new()

func _ready():
	load_data()

func save_data():
	config.save(PATH) #function to save data in the file

func set_data():
	config.set_value("Player", "gold", gold) #function to set data before saving
	config.set_value("Player", "skill_tree", skill_tree) #set skill tree in SaveData

func set_and_save(): #function to set and save
	set_data()
	save_data()

func load_data():
	if config.load(PATH) != OK: #if file doesn't exists, then set and save with default values
		set_and_save()
	
	gold = config.get_value("Player", "gold", 1000) #load function to get the values from the file
	skill_tree = config.get_value("Player", "skill_tree", []) #get value from file by loading data
