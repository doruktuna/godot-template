extends Node

signal setting_changed(section: String, key: String, value: Variant)

const PATH := "user://settings.cfg"

const ASPECT_RATIO := 16.0 / 9.0
const WIDTH_STEP := 16
const TITLE_BAR_MARGIN := 48

enum vsync_modes {DISABLED = 0, ENABLED, ADAPTIVE}

var DEFAULTS := {
	"audio": {
		"master": 1.0,
		"music": 1.0,
		"sfx": 1.0,
		"is_muted": false,
	},
	"video": {
		"fullscreen": false,
		"resolution_scale": 0.75,
		"vsync": vsync_modes.DISABLED,
		"screen_shake": true,
	},
	"keyboard_inputs": {},
	"mouse_inputs": {},
	"joypad_button_inputs": {},
	"joypad_motion_inputs": {},
}

const INPUT_ACTIONS = ["up", "down", "left", "right", "action", "action_2"]

const JOYPAD_BLACKLIST: Array[String] = [
	"keyboard", "keychron", "system control", "consumer control", "mouse", "touchpad",
]

# Use old config to restore values when value changes are discarded
var _config := ConfigFile.new()
var _snapshot := ""


func _ready() -> void:
	var err := _config.load(PATH)
	if err != OK and err != ERR_FILE_NOT_FOUND:
		push_warning("Could not read settings (error: %d), using defaults." % err)
	_set_inputs_in_defaults()
	apply_all()


func _set_inputs_in_defaults() -> void:
	# Set empty arrays
	for input_type in ["keyboard_inputs", "mouse_inputs", "joypad_button_inputs", "joypad_motion_inputs"]:
		for action in INPUT_ACTIONS:
			DEFAULTS[input_type][action] = []

	# For each action, read all InputEvents and set the arrays accordingly
	for action in INPUT_ACTIONS:
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				DEFAULTS["keyboard_inputs"][action].append(event.physical_keycode)
			elif event is InputEventMouseButton:
				DEFAULTS["mouse_inputs"][action].append(event.button_index)
			elif event is InputEventJoypadButton:
				DEFAULTS["joypad_button_inputs"][action].append(event.button_index)
			elif event is InputEventJoypadMotion:
				DEFAULTS["joypad_motion_inputs"][action].append([event.axis, event.axis_value])
			else:
				push_error("Unknown event type: ", action, ", ", event)

	print(JSON.stringify(DEFAULTS, "  "))


func get_setting(section: String, key: String) -> Variant:
	var default: Variant = DEFAULTS[section][key]
	var value: Variant = _config.get_value(section, key, default)
	if typeof(value) != typeof(default): # hand-edited or corrupt value
		return default
	return value


func set_setting(section: String, key: String, value: Variant) -> void:
	var new_value = value
	if value is Array:
		new_value = value.duplicate(true)
	_config.set_value(section, key, new_value)
	_apply(section, key, new_value)
	setting_changed.emit(section, key, new_value)


func set_input_change(section: String, action: String, action_ind: int, value: Variant) -> void:
	var new_value: Variant = get_setting(section, action).duplicate(true)
	new_value[action_ind] = value
	set_setting(section, action, new_value)


func save_settings() -> void:
	var err := _config.save(PATH)
	if err != OK:
		push_error("Could not save settings (error: %d)." % err)
		return
	_snapshot = _config.encode_to_text() # not necessary but a good precaution


func start_editing_settings() -> void:
	_snapshot = _config.encode_to_text()


func cancel_editing_settings() -> void:
	_config.clear()
	var err := _config.parse(_snapshot)
	if err != OK:
		push_error("Could not restore settings snapshot (error %d)." % err)
		return
	apply_all()


func reset_to_defaults() -> void:
	for section: String in DEFAULTS:
		for key: String in DEFAULTS[section]:
			set_setting(section, key, DEFAULTS[section][key])


func reset_to_defaults_for_a_section(section: String) -> void:
	for key: String in DEFAULTS[section]:
		print(section, ", ", key, ", ", DEFAULTS[section][key])
		set_setting(section, key, DEFAULTS[section][key])

	
func apply_all() -> void:
	for section: String in DEFAULTS:
		for key: String in DEFAULTS[section]:
			_apply(section, key, get_setting(section, key))


func _apply_resolution_scale(window_scale: float) -> void:
	var window := get_window()
	var area := DisplayServer.screen_get_usable_rect(window.current_screen)

	var size = calculate_resolution_from_scale(window_scale)
	window.size = size

	@warning_ignore("integer_division")
	window.position = area.position + (area.size - size) / 2


func calculate_resolution_from_scale(window_scale: float) -> Vector2i:
	var window := get_window()
	var area := DisplayServer.screen_get_usable_rect(window.current_screen)

	# Largest 16:9 width that fits the usable area
	var max_width := mini(area.size.x, roundi((area.size.y - TITLE_BAR_MARGIN) * ASPECT_RATIO))

	# Floor to a multiple of 16 so the height is a whole number and we never exceed max_width
	var width := floori(max_width * window_scale / WIDTH_STEP) * WIDTH_STEP
	return Vector2i(width, roundi(width / ASPECT_RATIO))


func _apply(section: String, key: String, value: Variant) -> void:
	match [section, key]:
		["audio", "master"]:
			_set_bus_volume("Master", value)

		["audio", "music"]:
			_set_bus_volume("Music", value)

		["audio", "sfx"]:
			_set_bus_volume("SFX", value)

		["audio", "is_muted"]:
			var bus_index = AudioServer.get_bus_index("Master")
			AudioServer.set_bus_mute(bus_index, value)
			
		["video", "fullscreen"]:
			DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_WINDOWED
			)

		["video", "resolution_scale"]:
			_apply_resolution_scale(value)

		["video", "vsync"]:
			match value:
				vsync_modes.DISABLED:
					DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
				vsync_modes.ENABLED:
					DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
				vsync_modes.ADAPTIVE:
					DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
				_:
					push_error("Unknown vsync mode: ", value)

		["keyboard_inputs", var action]:
			_set_keyboard_inputs(action, value)

		["joypad_button_inputs", var action]:
			_set_joypad_inputs(action, value)

	
func _set_bus_volume(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	AudioServer.set_bus_volume_db(idx, linear_to_db(linear))


func _set_keyboard_inputs(action: String, value: Variant) -> void:
	# Clear events
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			InputMap.action_erase_event(action, event)

	# Add events from array
	for physical_keycode in value:
		var event := InputEventKey.new()
		event.physical_keycode = physical_keycode
		InputMap.action_add_event(action, event)


func _set_joypad_inputs(action: String, value: Variant) -> void:
	# Clear events
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton:
			InputMap.action_erase_event(action, event)

	# Add events from array
	for button_ind in value:
		var event := InputEventJoypadButton.new()
		event.button_index = button_ind
		InputMap.action_add_event(action, event)


func check_keyboard_key_is_used(physical_keycode: int, action_to_exclude: String = "") -> String:
	for action in INPUT_ACTIONS:
		if action == action_to_exclude:
			continue
		
		if physical_keycode in get_setting("keyboard_inputs", action):
			return action

	return ""


func check_joypad_button_is_used(button_index: int, action_to_exclude: String = "") -> String:
	for action in INPUT_ACTIONS:
		if action == action_to_exclude:
			continue
		
		if button_index in get_setting("joypad_button_inputs", action):
			return action

	return ""


func get_real_joypads() -> Array[int]:
	var result: Array[int] = []
	for id in Input.get_connected_joypads():
		if _is_real_joypad(id):
			result.append(id)
	return result


func _is_real_joypad(id: int) -> bool:
	if Input.is_joy_known(id):
		return true

	var joy_name := Input.get_joy_name(id).to_lower()
	for part in JOYPAD_BLACKLIST:
		if part in joy_name:
			return false

	# Unknown but not in blacklist: Give it the benefit of the doubt
	return true
