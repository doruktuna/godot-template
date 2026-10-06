extends Node

signal setting_changed(section: String, key: String, value: Variant)

const PATH := "user://settings.cfg"

const ASPECT_RATIO := 16.0 / 9.0
const WIDTH_STEP := 16
const TITLE_BAR_MARGIN := 48

const DEFAULTS := {
	"audio": {
		"master": 1.0,
		"music": 1.0,
		"sfx": 1.0,
		"is_muted": false,
	},
	"video": {
		"fullscreen": false,
		"resolution_scale": 0.5,
		"vsync": true,
	},
}

# Use old config to restore values when value changes are discarded
var _config := ConfigFile.new()
var _snapshot := ""


func _ready() -> void:
	var err := _config.load(PATH)
	if err != OK and err != ERR_FILE_NOT_FOUND:
		push_warning("Could not read settings (error: %d), using defaults." % err)
	apply_all()
	
		
func get_setting(section: String, key: String) -> Variant:
	var default: Variant = DEFAULTS[section][key]
	var value: Variant = _config.get_value(section, key, default)
	if typeof(value) != typeof(default): # hand-edited or corrupt value
		return default
	return value


func set_setting(section: String, key: String, value: Variant) -> void:
	_config.set_value(section, key, value)
	_apply(section, key, value)
	setting_changed.emit(section, key, value)


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
			DisplayServer.window_set_vsync_mode(
				DisplayServer.VSYNC_ENABLED if value else DisplayServer.VSYNC_DISABLED
			)


func _set_bus_volume(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	AudioServer.set_bus_volume_db(idx, linear_to_db(linear))