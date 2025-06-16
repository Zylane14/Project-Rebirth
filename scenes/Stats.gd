extends Resource
class_name Stats

@export_multiline var description : String

@export var max_health : float
@export var recovery : float
@export var armor : float
@export var movement_speed : float
@export var amplify : float
@export var area : float
@export var magnet : float
@export var growth : float
@export var luck : float
@export var dodge : float

# Operator overloading for + (add)
func _operator_add(other):
	if typeof(other) != TYPE_OBJECT or not other is Stats:
		return self

	var result := Stats.new()
	result.max_health = max_health + other.max_health
	result.recovery = recovery + other.recovery
	result.armor = armor + other.armor
	result.movement_speed = movement_speed + other.movement_speed
	result.amplify = amplify + other.amplify
	result.area = area + other.area
	result.magnet = magnet + other.magnet
	result.growth = growth + other.growth
	result.luck = luck + other.luck
	result.dodge = dodge + other.dodge
	return result

# Operator overloading for - (subtract)
func _operator_subtract(other):
	if typeof(other) != TYPE_OBJECT or not other is Stats:
		return self

	var result := Stats.new()
	result.max_health = max_health - other.max_health
	result.recovery = recovery - other.recovery
	result.armor = armor - other.armor
	result.movement_speed = movement_speed - other.movement_speed
	result.amplify = amplify - other.amplify
	result.area = area - other.area
	result.magnet = magnet - other.magnet
	result.growth = growth - other.growth
	result.luck = luck - other.luck
	result.dodge = dodge - other.dodge
	return result

# Optional: Safe deep copy
func copy() -> Stats:
	var result := Stats.new()
	result.max_health = max_health
	result.recovery = recovery
	result.armor = armor
	result.movement_speed = movement_speed
	result.amplify = amplify
	result.area = area
	result.magnet = magnet
	result.growth = growth
	result.luck = luck
	result.dodge = dodge
	return result
