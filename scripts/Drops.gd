extends Node

static func pick_weighted_drop(drops: Array[Pickups], luck: float) -> Pickups:
	if drops.is_empty():
		return null

	var weights = []
	for pickup in drops:
		var weight = pickup.weight
		if not (pickup is Gold):
			weight *= luck
		weights.append(weight)

	var total_weight = 0.0
	for w in weights:
		total_weight += w

	var roll = randf() * total_weight
	var cumulative = 0.0

	for i in range(drops.size()):
		cumulative += weights[i]
		if roll <= cumulative:
			return drops[i]

	return drops[0] # fallback
