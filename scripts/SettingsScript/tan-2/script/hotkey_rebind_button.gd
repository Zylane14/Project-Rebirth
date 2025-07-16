class_name HotKeyRebindButton
extends Control

@onready var label = $HBoxContainer/Label as Label
@onready var button = $HBoxContainer/Button as Button

@export var action_name: String = "left"

var rebinding := false

func _ready():
	_set_action_label()
	_update_key_text()
	button.pressed.connect(_start_rebinding)

func _set_action_label() -> void:
	match action_name:
		"left": label.text = "Move Left"
		"right": label.text = "Move Right"
		"up": label.text = "Move Up"
		"down": label.text = "Move Down"
		"dash": label.text = "Dash"
		"click": label.text = "Attack"
		_: label.text = "Unassigned"

func _update_key_text() -> void:
	var events = InputMap.action_get_events(action_name)

	if events.is_empty():
		button.text = "Unassigned"
		return

	var event = events[0]

	if event is InputEventKey:
		button.text = OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventMouseButton:
		match event.button_index:
			1: button.text = "LMB"
			2: button.text = "RMB"
			3: button.text = "MMB"
			_: button.text = "Mouse %d" % event.button_index
	else:
		button.text = "Unknown"

func _start_rebinding() -> void:
	rebinding = true
	button.text = "Press a key..."
	button.disabled = true
	get_viewport().set_input_as_handled()  # Prevents button click from leaking
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if not rebinding:
		return

	# Keyboard keys
	if event is InputEventKey and event.pressed and not event.echo:
		_finish_rebind(event)

	# Mouse buttons
	elif event is InputEventMouseButton and event.pressed:
		_finish_rebind(event)

func _finish_rebind(event: InputEvent) -> void:
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event.duplicate())
	_update_key_text()
	rebinding = false
	button.disabled = false
	set_process_input(false)
