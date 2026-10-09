class_name InputKeyButton
extends Button

enum ControllerType {KEYBOARD, MOUSE, JOYPAD_BUTTON, JOYPAD_MOTION}

var controller_type: ControllerType
var action: String
var action_ind: int

var old_text: String

signal change_input_requested(input_key_button: InputKeyButton, new_event: InputEvent)


func _ready() -> void:
	set_process_unhandled_input(false)


func _toggled(toggled_on: bool) -> void:
	set_process_unhandled_input(toggled_on)
	if toggled_on:
		old_text = text
		text = "..."


func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and is_controller_type_match(event):
		print("Pressed: ", event)
		button_pressed = false
		release_focus()
		change_input_requested.emit(self, event)
		text = old_text


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