extends Resource
class_name SpeedBoost

func apply_to(target):
	if target and target.has_method("movement_speed"):
		target.movement_speed += 25  # or any logic you want
