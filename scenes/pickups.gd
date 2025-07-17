extends Area2D

var direction : Vector2
var speed : float = 175
var current_frame := 0
var frame_timer := 0.0

@export var type : Pickups
@export var player_reference : CharacterBody2D:
	set(value):
		player_reference = value
		type.player_reference = value


var can_follow : bool = false

func _ready():
	if type.icon:
		$Sprite2D.texture = type.icon
		if type.frame_count > 1:
			$Sprite2D.region_enabled = true


func _physics_process(delta):
	if type.frame_count > 1:
		frame_timer += delta
		if frame_timer >= type.frame_duration:
			frame_timer = 0.0
			current_frame = (current_frame + 1) % type.frame_count
			update_sprite_frame()

	if player_reference and can_follow:
		direction = (player_reference.position - position).normalized()
		position += direction * speed * delta


func follow(_target : CharacterBody2D, gem_flag = false): #function follow will set the flag to true
	if type is Chest: #stops chest from magnet
		return
	if gem_flag == true: #for gem_flag only, Gem type Pickups can follow
		if type is Gem:
			can_follow = true
		return
	can_follow = true

func update_sprite_frame():
	var tex = type.icon
	if tex == null:
		return

	var frame_width = tex.get_width()
	$Sprite2D.region_enabled = true
	$Sprite2D.texture = tex
	$Sprite2D.region_rect = Rect2(current_frame * frame_width, 0, frame_width, tex.get_height())


func _on_body_entered(_fbody): #after interacting with the player, activate pickupResource and free it from memory
	type.activate()
	queue_free()
