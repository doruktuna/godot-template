extends Node

signal setting_changed(section: String, key: String, value: Variant)

const PATH := "user://settings.cfg"

const DEFAULTS := {
	"audio": {
		"master": 1.0,
		"music": 1.0,
		"sfx": 1.0,
		"is_muted": false,
	},
	"video": {
		"fullscreen": false,
		"vsync": true,
	},
}

var _config := ConfigFile.new()


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

		["video", "vsync"]:
			DisplayServer.window_set_vsync_mode(
				DisplayServer.VSYNC_ENABLED if value else DisplayServer.VSYNC_DISABLED
			)


func _set_bus_volume(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	AudioServer.set_bus_volume_db(idx, linear_to_db(linear))