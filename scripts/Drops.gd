extends Node

static func pick_weighted_drop(drops: Array[Pickups], luck: float) -> Pickups:
	if drops.is_empty():
		return null

	var weights: Array[float] = []

	for pickup in drops:
		if pickup == null:
			weights.append(0.0)
			continue

		var weight = pickup.weight

		# Apply normalized luck boost (e.g. 25 luck = +25% weight)
		if not (pickup is Gold):
			weight *= 1.0 + (luck / 100.0)

		weights.append(weight)

	var total_weight := 0.0
	for w in weights:
		total_weight += w

	if total_weight <= 0.0:
		return null

	var roll = randf() * total_weight
	var cumulative = 0.0

	for i in range(drops.size()):
		cumulative += weights[i]
		if roll <= cumulative:
			return drops[i]

	return drops[0]  # fallback
