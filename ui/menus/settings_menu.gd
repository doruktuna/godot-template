class_name SettingsMenu
extends Control

@onready var discard_button: Button = %DiscardButton
@onready var save_button: Button = %SaveButton
@onready var sfx_slider: HSlider = %SFXSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var master_slider: HSlider = %MasterSlider
@onready var mute_toggle_button: TextureButton = %MuteToggleButton


func _ready() -> void:
	discard_button.grab_focus()
	discard_button.pressed.connect(_on_discard_pressed)
	save_button.pressed.connect(_on_save_pressed)

	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	master_slider.value_changed.connect(_on_master_slider_value_changed)
	mute_toggle_button.pressed.connect(_on_mute_toggle_button_pressed)

	# TODO Set slider values from the actual values (which are set via the SettingsManager)


func _on_discard_pressed() -> void:
	EventBus.scene_change_requested.emit(SceneManager.Scene.MAIN_MENU, {})


func _on_save_pressed() -> void:
	EventBus.scene_change_requested.emit(SceneManager.Scene.MAIN_MENU, {})


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