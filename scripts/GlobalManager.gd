extends Node

var global_buff_stage: int = 0
var elapsed_time: float = 0.0
var buff_interval: float = 15.0

func _process(delta: float) -> void:
	elapsed_time += delta
	var expected_stage = int(elapsed_time / buff_interval)

	if expected_stage > global_buff_stage:
		global_buff_stage = expected_stage
		print("Buff stage increased to: ", global_buff_stage)

func reset():
	global_buff_stage = 0
	elapsed_time = 0.0
