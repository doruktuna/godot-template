class_name SettingsMenu
extends Control

@onready var settings_tabs: TabContainer = %SettingsTabs
@onready var discard_button: Button = %DiscardButton
@onready var save_button: Button = %SaveButton

# Video settings
@onready var video_defaults_button: Button = %VideoDefaultsButton
@onready var fullscreen_check_box: CheckBox = %FullscreenCheckBox
@onready var resolution_scale_slider: HSlider = %ResolutionScaleSlider
@onready var resolution_scale_label: Label = %ResolutionScaleLabel
@onready var resolution_value: Label = %ResolutionValue
@onready var vsync_option_button: OptionButton = %VsyncOptionButton
@onready var screen_shake_check_box: CheckBox = %ScreenShakeCheckBox

# Audio settings
@onready var audio_defaults_button: Button = %AudioDefaultsButton
@onready var sfx_slider: HSlider = %SFXSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var master_slider: HSlider = %MasterSlider
@onready var mute_toggle_button: TextureButton = %MuteToggleButton

# Keyboard Input Map settings
@onready var keyboard_defaults_button: Button = %KeyboardDefaultsButton
@onready var keyboard_inputs_container: GridContainer = %KeyboardInputsContainer

const INPUT_KEY_BUTTON_SCENE: PackedScene = preload("res://ui/components/input_key_button.tscn")

const INPUT_ACTION_NAMES: Array[String] = ["up", "down", "left", "right", "action"]


func _ready() -> void:
	settings_tabs.current_tab = 0
	settings_tabs.get_tab_bar().grab_focus()

	discard_button.pressed.connect(_on_discard_pressed)
	save_button.pressed.connect(_on_save_pressed)

	# Video input signals
	video_defaults_button.pressed.connect(_return_video_to_defaults)
	fullscreen_check_box.toggled.connect(_on_fullscreen_check_box_toggled)
	resolution_scale_slider.value_changed.connect(_on_resolution_scale_slider_value_changed)
	resolution_scale_slider.drag_ended.connect(_on_resolution_scale_slider_drag_ended)
	vsync_option_button.item_selected.connect(_on_vsync_option_button_item_selected)
	screen_shake_check_box.toggled.connect(_on_screen_shake_check_box_toggled)

	# Audio input signals
	audio_defaults_button.pressed.connect(_return_audio_to_defaults)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	master_slider.value_changed.connect(_on_master_slider_value_changed)
	mute_toggle_button.pressed.connect(_on_mute_toggle_button_pressed)

	# Keyboard input signals (key inputs will be created and connected via the _update_keyboard_ui_from_settings method)
	keyboard_defaults_button.pressed.connect(_return_keyboard_inputs_to_defaults)

	# Set input values from the actual values
	_update_audio_ui_from_settings()
	_update_video_ui_from_settings()
	_update_keyboard_ui_from_settings()

	# Start editing (this is important to restore values if the settings are discarded)
	SettingsManager.start_editing_settings()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("down"):
		print("DOWN PRESSED")


func _on_discard_pressed() -> void:
	SettingsManager.cancel_editing_settings()
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


func _update_video_ui_from_settings() -> void:
	resolution_scale_slider.value = SettingsManager.get_setting("video", "resolution_scale")
	fullscreen_check_box.button_pressed = SettingsManager.get_setting("video", "fullscreen")
	vsync_option_button.selected = SettingsManager.get_setting("video", "vsync")
	screen_shake_check_box.button_pressed = SettingsManager.get_setting("video", "screen_shake")
	
	
func _return_audio_to_defaults() -> void:
	SettingsManager.reset_to_defaults_for_a_section("audio")
	_update_audio_ui_from_settings()


func _return_video_to_defaults() -> void:
	SettingsManager.reset_to_defaults_for_a_section("video")
	_update_video_ui_from_settings()


func _return_keyboard_inputs_to_defaults() -> void:
	SettingsManager.reset_to_defaults_for_a_section("keyboard_inputs")
	_update_keyboard_ui_from_settings()


func _on_sfx_slider_value_changed(slider_value: float) -> void:
	set_bus_volume("SFX", slider_value)

	
func _on_music_slider_value_changed(slider_value: float) -> void:
	set_bus_volume("Music", slider_value)

	
func _on_master_slider_value_changed(slider_value: float) -> void:
	set_bus_volume("Master", slider_value)
	

func _on_mute_toggle_button_pressed() -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus_index, mute_toggle_button.button_pressed)


func _on_fullscreen_check_box_toggled(toggled_on: bool) -> void:
	SettingsManager.set_setting("video", "fullscreen", toggled_on)
	resolution_scale_slider.editable = not toggled_on
	if toggled_on:
		resolution_scale_label.modulate = Color.GRAY
		resolution_value.text = "(fullscreen)"
	else:
		resolution_scale_label.modulate = Color.WHITE
		_on_resolution_scale_slider_value_changed(resolution_scale_slider.value)
		_on_resolution_scale_slider_drag_ended(true)


func _on_resolution_scale_slider_value_changed(value: float) -> void:
	var res = SettingsManager.calculate_resolution_from_scale(value)
	resolution_value.text = "({res_scale} → {res_width} * {res_height})".format({"res_scale": "%0.2f" % value, "res_width": res.x, "res_height": res.y})
	

func _on_resolution_scale_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		SettingsManager.set_setting("video", "resolution_scale", resolution_scale_slider.value)


func _on_vsync_option_button_item_selected(index: int) -> void:
	# This directly works since the option button follows the order of vsync_modes enum
	SettingsManager.set_setting("video", "vsync", index)


func _on_screen_shake_check_box_toggled(toggled_on: bool) -> void:
	SettingsManager.set_setting("video", "screen_shake", toggled_on)


func set_bus_volume(bus_name: String, linear_value: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_value))


func set_audio_slider_value(slider: HSlider, db_value: float) -> void:
	slider.value = db_to_linear(db_value)


func _update_keyboard_ui_from_settings() -> void:
	for child in keyboard_inputs_container.get_children():
		child.queue_free()

	var upper_buttons: Array[InputKeyButton] = []
	
	for action_name in INPUT_ACTION_NAMES:
		var cur_buttons: Array[InputKeyButton] = []
		var label := Label.new()
		label.text = action_name.capitalize()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		keyboard_inputs_container.add_child(label)

		var keys_container := HBoxContainer.new()
		keys_container.add_theme_constant_override("separation", 30)
		keyboard_inputs_container.add_child(keys_container)
		
		# Instantiate input key buttons and set their properties
		var physical_keycodes: Array = SettingsManager.get_setting("keyboard_inputs", action_name)
		for i in physical_keycodes.size():
			var physical_keycode = physical_keycodes[i]
			var keycode := DisplayServer.keyboard_get_keycode_from_physical(physical_keycode)
			var ikb: InputKeyButton = INPUT_KEY_BUTTON_SCENE.instantiate()
			ikb.text = OS.get_keycode_string(keycode)
			ikb.controller_type = InputKeyButton.ControllerType.KEYBOARD
			ikb.action = action_name
			ikb.action_ind = i
			ikb.change_input_requested.connect(_on_change_input_requested)
			keys_container.add_child(ikb)
			cur_buttons.append(ikb)

		# Setup neighbours for a better navigation
		for i in cur_buttons.size():
			var ikb = cur_buttons[i]

			# Up-down
			if upper_buttons.size() > i:
				upper_buttons[i].focus_neighbor_bottom = ikb.get_path()
				ikb.focus_neighbor_top = upper_buttons[i].get_path()

			# Right-left
			if i < cur_buttons.size() - 1:
				cur_buttons[i + 1].focus_neighbor_left = ikb.get_path()
				ikb.focus_neighbor_right = cur_buttons[i + 1].get_path()

			# Left most to upper right most
			if i == 0 and upper_buttons.size() > 0:
				upper_buttons[-1].focus_neighbor_right = ikb.get_path()
				ikb.focus_neighbor_left = upper_buttons[-1].get_path()

		upper_buttons = cur_buttons

	# Connect last buttons right to defaults button
	upper_buttons[-1].focus_neighbor_bottom = keyboard_defaults_button.get_path()
	upper_buttons[-1].focus_neighbor_right = keyboard_defaults_button.get_path()
	keyboard_defaults_button.focus_neighbor_left = upper_buttons[-1].get_path()
	keyboard_defaults_button.focus_neighbor_top = upper_buttons[-1].get_path()

			
func _on_change_input_requested(ikb: InputKeyButton, new_event: InputEvent) -> void:
	# Pause is also cancel
	if InputMap.event_is_action(new_event, "pause"):
		return

	# TODO Add duplication control and warn the user
	# TODO Dont allow for clicking other buttons when one of them is clicked
	if new_event is InputEventKey:
		SettingsManager.set_input_change("keyboard_inputs", ikb.action, ikb.action_ind, new_event.physical_keycode)
		var physical_keycode = new_event.physical_keycode
		var keycode := DisplayServer.keyboard_get_keycode_from_physical(physical_keycode)
		ikb.text = OS.get_keycode_string(keycode)
