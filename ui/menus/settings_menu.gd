class_name SettingsMenu
extends Control

@onready var discard_button: Button = %DiscardButton
@onready var save_button: Button = %SaveButton
@onready var audio_defaults_button: Button = %AudioDefaultsButton
@onready var sfx_slider: HSlider = %SFXSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var master_slider: HSlider = %MasterSlider
@onready var mute_toggle_button: TextureButton = %MuteToggleButton


func _ready() -> void:
	discard_button.grab_focus()
	discard_button.pressed.connect(_on_discard_pressed)
	save_button.pressed.connect(_on_save_pressed)
	audio_defaults_button.pressed.connect(_return_audio_to_defaults)

	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	master_slider.value_changed.connect(_on_master_slider_value_changed)
	mute_toggle_button.pressed.connect(_on_mute_toggle_button_pressed)

	# Set slider values from the actual values
	_update_audio_ui_from_settings()


func _on_discard_pressed() -> void:
	EventBus.scene_change_requested.emit(SceneManager.Scene.MAIN_MENU, {})


func _on_save_pressed() -> void:
	set_audio_settings()
	SettingsManager.save_settings()
	EventBus.scene_change_requested.emit(SceneManager.Scene.MAIN_MENU, {})


func set_audio_settings() -> void:
	SettingsManager.set_setting("audio", "sfx", sfx_slider.value)
	SettingsManager.set_setting("audio", "music", music_slider.value)
	SettingsManager.set_setting("audio", "master", master_slider.value)
	SettingsManager.set_setting("audio", "is_muted", mute_toggle_button.button_pressed)


func _update_audio_ui_from_settings() -> void:
	sfx_slider.value = SettingsManager.get_setting("audio", "sfx")
	music_slider.value = SettingsManager.get_setting("audio", "music")
	master_slider.value = SettingsManager.get_setting("audio", "master")
	mute_toggle_button.button_pressed = SettingsManager.get_setting("audio", "is_muted")


func _return_audio_to_defaults() -> void:
	SettingsManager.reset_to_defaults_for_a_section("audio")
	_update_audio_ui_from_settings()


func _on_sfx_slider_value_changed(slider_value: float) -> void:
	set_bus_volume("SFX", slider_value)

	
func _on_music_slider_value_changed(slider_value: float) -> void:
	set_bus_volume("Music", slider_value)

	
func _on_master_slider_value_changed(slider_value: float) -> void:
	set_bus_volume("Master", slider_value)
	

func _on_mute_toggle_button_pressed() -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus_index, mute_toggle_button.button_pressed)


func set_bus_volume(bus_name: String, linear_value: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_value))


func set_slider_value(slider: HSlider, db_value: float) -> void:
	slider.value = db_to_linear(db_value)