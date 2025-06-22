extends Node2D

@onready var bonus_stats : Stats = Stats.new()
var character = null #set character property

func gain_bonus_stats(player):
	player.max_health += bonus_stats.max_health
	player.recovery += bonus_stats.recovery
	player.armor += bonus_stats.armor
	player.movement_speed += bonus_stats.movement_speed
	player.damage += bonus_stats.damage
	player.amplify += bonus_stats.amplify
	player.area += bonus_stats.area
	player.magnet += bonus_stats.magnet
	player.growth += bonus_stats.growth
	player.luck += bonus_stats.luck
	player.dodge += bonus_stats.dodge
	player.crit += bonus_stats.crit
	player.crit_damage += bonus_stats.crit_damage
