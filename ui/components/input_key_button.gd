class_name InputKeyButton
extends Button

enum ControllerType {KEYBOARD, MOUSE, JOYPAD_BUTTON, JOYPAD_MOTION}

var controller_type: ControllerType
var action_name: String
var action_ind: int

var old_text: String

signal change_input_requested(input_key_button: InputKeyButton, new_event: InputEvent)

static var listening_button: InputKeyButton = null


func _ready() -> void:
	old_text = text
	_stop_listening()


func _start_listening() -> void:
	listening_button = self
	old_text = text
	text = "..."
	set_process_input(true)


func _stop_listening() -> void:
	button_pressed = false
	set_process_input(false)
	if listening_button == self:
		listening_button = null
	text = old_text


func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		_start_listening()
	else:
		_stop_listening()


func _input(event: InputEvent) -> void:
	# Swallow everything while listening
	get_viewport().set_input_as_handled()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_stop_listening()
	elif event.is_pressed() and is_controller_type_match(event):
		print("Pressed: ", event)
		_stop_listening()
		change_input_requested.emit(self, event)


func is_controller_type_match(event: InputEvent) -> bool:
	match controller_type:
		ControllerType.KEYBOARD:
			return event is InputEventKey
		ControllerType.JOYPAD_BUTTON:
			return event is InputEventJoypadButton
		ControllerType.JOYPAD_MOTION:
			return event is InputEventJoypadMotion
		_:
			push_error("Unknown controller type in InputKeyButton: ", controller_type)

	return false