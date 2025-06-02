extends Node2D

var effects = {
	"blood" : load("res://shaders/blood.tres")
}
var particle : PackedScene = preload("res://scenes/particle.tscn")
 
func add_effect(effect_name: String, pos: Vector2, parent: Node = null):
	if effect_name not in effects:
		print("Effect '%s' not found!" % effect_name)
		return
 
	var effect = effects[effect_name]
	if parent == null:
		parent = get_tree().current_scene
 
	var particle_instance : GPUParticles2D = particle.instantiate()
	particle_instance.process_material = effect
	particle_instance.global_position = pos
	parent.add_child(particle_instance)
