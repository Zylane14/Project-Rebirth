extends Node
class_name ArtifactManager

var artifacts: Array[Artifact] = []

func add_artifact(artifact: Artifact):
	if artifact in artifacts:
		return # Skip duplicates unless stacking is allowed
	artifacts.append(artifact)
	apply_artifact_stats(artifact)

func apply_artifact_stats(artifact: Artifact):
	if not artifact.stats_modifiers:
		return
	var stats = artifact.stats_modifiers
	var player = get_node("/root/Player")
	
	player.modify_stat("max_health", stats.max_health)
	player.modify_stat("recovery", stats.recovery)
	player.modify_stat("armor", stats.armor)
	player.modify_stat("movement_speed", stats.movement_speed)
	player.modify_stat("amplify", stats.amplify)
	player.modify_stat("area", stats.area)
	player.modify_stat("magnet", stats.magnet)
	player.modify_stat("growth", stats.growth)
	player.modify_stat("luck", stats.luck)
	player.modify_stat("dodge", stats.dodge)
