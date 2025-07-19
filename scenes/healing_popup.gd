extends RichTextLabel


@export var float_speed := 30.0
@export var duration := 1.0

func _ready():
	modulate = Color(0, 1, 0)  # green
	get_tree().create_timer(duration).connect("timeout", self.queue_free)

func _process(delta):
	position.y -= float_speed * delta
