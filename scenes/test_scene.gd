extends Node2D

func _ready():
	GlobalManager.reset()
	print("Reset global buff stage:", GlobalManager.global_buff_stage)
