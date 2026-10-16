class_name SettingsMenu
extends Control

const INPUT_KEY_BUTTON_SCENE: PackedScene = preload("res://ui/components/input_key_button.tscn")

# Dont allow for joypad mapping of direction keys
const KEYBOARD_ACTION_NAMES: Array[String] = ["up", "down", "left", "right", "action", "action_2"]
const JOYPAD_ACTION_NAMES: Array[String] = ["action", "action_2"]

# For human readeble button text
const JOY_BUTTON_NAMES := {
	JOY_BUTTON_A: "A",
	JOY_BUTTON_B: "B",
	JOY_BUTTON_X: "X",
	JOY_BUTTON_Y: "Y",
	JOY_BUTTON_BACK: "Back",
	JOY_BUTTON_GUIDE: "Guide",
	JOY_BUTTON_START: "Start",
	JOY_BUTTON_LEFT_STICK: "Left Stick Click",
	JOY_BUTTON_RIGHT_STICK: "Right Stick Click",
	JOY_BUTTON_LEFT_SHOULDER: "LB",
	JOY_BUTTON_RIGHT_SHOULDER: "RB",
	JOY_BUTTON_DPAD_UP: "D-Pad Up",
	JOY_BUTTON_DPAD_DOWN: "D-Pad Down",
	JOY_BUTTON_DPAD_LEFT: "D-Pad Left",
	JOY_BUTTON_DPAD_RIGHT: "D-Pad Right",
}

@onready var settings_tabs: TabContainer = %SettingsTabs
@onready var joypad_tab: Control = %JoypadTab
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

# Joypad Input Map settings
@onready var joypad_defaults_button: Button = %JoypadDefaultsButton
@onready var joypad_inputs_container: GridContainer = %JoypadInputsContainer

# Error box/popup
@onready var error_box: PanelContainer = %ErrorBox
@onready var error_box_text: Label = %ErrorBoxText


func _ready() -> void:
	settings_tabs.current_tab = 3
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

	# Joypad input signals
	joypad_defaults_button.pressed.connect(_return_joypad_inputs_to_defaults)
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_refresh_joypad_tab()

	# Set input values from the actual values
	_update_audio_ui_from_settings()
	_update_video_ui_from_settings()
	_update_keyboard_ui_from_settings()
	_update_joypad_ui_from_settings()

	# Hide error box
	error_box.hide()

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

func _return_joypad_inputs_to_defaults() -> void:
	SettingsManager.reset_to_defaults_for_a_section("joypad_button_inputs")
	_update_joypad_ui_from_settings()


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


func _on_joy_connection_changed(_device_id: int, _connected: bool):
	_refresh_joypad_tab()


func set_bus_volume(bus_name: String, linear_value: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_value))


func set_audio_slider_value(slider: HSlider, db_value: float) -> void:
	slider.value = db_to_linear(db_value)


func _update_keyboard_ui_from_settings() -> void:
	for child in keyboard_inputs_container.get_children():
		child.queue_free()

	var upper_buttons: Array[InputKeyButton] = []
	
	for action_name in KEYBOARD_ACTION_NAMES:
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
			var ikb = _create_input_key_button(action_name, i, InputKeyButton.ControllerType.KEYBOARD, physical_keycode)
			keys_container.add_child(ikb)
			cur_buttons.append(ikb)

		# Setup neighbours for a better navigation
		_connect_input_button_neighbours(cur_buttons, upper_buttons)

		upper_buttons = cur_buttons

	# Connect last buttons right to defaults button
	upper_buttons[-1].focus_neighbor_bottom = keyboard_defaults_button.get_path()
	upper_buttons[-1].focus_neighbor_right = keyboard_defaults_button.get_path()
	keyboard_defaults_button.focus_neighbor_left = upper_buttons[-1].get_path()
	keyboard_defaults_button.focus_neighbor_top = upper_buttons[-1].get_path()


func _update_joypad_ui_from_settings() -> void:
	for child in joypad_inputs_container.get_children():
		child.queue_free()

	var upper_buttons: Array[InputKeyButton] = []
	
	for action_name in JOYPAD_ACTION_NAMES:
		var cur_buttons: Array[InputKeyButton] = []
		var label := Label.new()
		label.text = action_name.capitalize()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		joypad_inputs_container.add_child(label)

		var keys_container := HBoxContainer.new()
		keys_container.add_theme_constant_override("separation", 30)
		joypad_inputs_container.add_child(keys_container)
		
		# Instantiate input key buttons and set their properties
		var joypad_indices: Array = SettingsManager.get_setting("joypad_button_inputs", action_name)
		for i in joypad_indices.size():
			var joypad_indice = joypad_indices[i]
			var ikb = _create_input_key_button(action_name, i, InputKeyButton.ControllerType.JOYPAD_BUTTON, joypad_indice)
			keys_container.add_child(ikb)
			cur_buttons.append(ikb)

		# Setup neighbours for a better navigation
		_connect_input_button_neighbours(cur_buttons, upper_buttons)

		upper_buttons = cur_buttons

	# Connect last buttons right to defaults button
	upper_buttons[-1].focus_neighbor_bottom = joypad_defaults_button.get_path()
	upper_buttons[-1].focus_neighbor_right = joypad_defaults_button.get_path()
	joypad_defaults_button.focus_neighbor_left = upper_buttons[-1].get_path()
	joypad_defaults_button.focus_neighbor_top = upper_buttons[-1].get_path()


# key_value is physical_keycode for keyboard keys and button index for joypad buttons
func _create_input_key_button(action_name: String, action_ind: int, btn_type: InputKeyButton.ControllerType, key_value: int) -> InputKeyButton:
	var ikb: InputKeyButton = INPUT_KEY_BUTTON_SCENE.instantiate()
	if btn_type == InputKeyButton.ControllerType.KEYBOARD:
		var keycode = DisplayServer.keyboard_get_keycode_from_physical(key_value)
		ikb.text = OS.get_keycode_string(keycode)
	elif btn_type == InputKeyButton.ControllerType.JOYPAD_BUTTON:
		ikb.text = joy_button_text(key_value)
	ikb.controller_type = btn_type
	ikb.action_name = action_name
	ikb.action_ind = action_ind
	ikb.change_input_requested.connect(_on_change_input_requested)
	return ikb


func _connect_input_button_neighbours(cur_buttons: Array[InputKeyButton], upper_buttons: Array[InputKeyButton]) -> void:
	for i in cur_buttons.size():
		var ikb = cur_buttons[i]

		# Top-left to tab container
		if i == 0 and upper_buttons.size() == 0:
			ikb.focus_neighbor_left = settings_tabs.get_tab_bar().get_path()
			ikb.focus_neighbor_top = settings_tabs.get_tab_bar().get_path()

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


func joy_button_text(button_index: JoyButton) -> String:
	return JOY_BUTTON_NAMES.get(button_index, "Button %d" % button_index)


func _on_change_input_requested(ikb: InputKeyButton, new_event: InputEvent) -> void:
	# Pause is also cancel
	if InputMap.event_is_action(new_event, "pause"):
		return

	# Duplication control, warn the user if there is one
	var conflicting_action := ""
	if new_event is InputEventKey:
		conflicting_action = SettingsManager.check_keyboard_key_is_used(new_event.physical_keycode, ikb.action_name)
	elif new_event is InputEventJoypadButton:
		conflicting_action = SettingsManager.check_joypad_button_is_used(new_event.button_index, ikb.action_name)

	if conflicting_action != "":
		var error_msg := "Input conflicts with another action: " + conflicting_action.capitalize()
		_show_error_box(error_msg)
		return

	# All is good, change the input key and button text
	if new_event is InputEventKey:
		SettingsManager.set_input_change("keyboard_inputs", ikb.action_name, ikb.action_ind, new_event.physical_keycode)
		var keycode := DisplayServer.keyboard_get_keycode_from_physical(new_event.physical_keycode)
		ikb.text = OS.get_keycode_string(keycode)
	# All is good, change the joypad input and button text
	elif new_event is InputEventJoypadButton:
		SettingsManager.set_input_change("joypad_button_inputs", ikb.action_name, ikb.action_ind, new_event.button_index)
		ikb.text = joy_button_text(new_event.button_index)


func _show_error_box(msg: String) -> void:
	error_box.show()
	error_box.modulate.a = 0
	error_box_text.text = msg
	var tween := create_tween()
	tween.tween_property(error_box, "modulate:a", 1, 0.3)
	tween.tween_interval(3)
	tween.tween_property(error_box, "modulate:a", 0, 0.3)
	tween.tween_callback(error_box.hide)


func _refresh_joypad_tab() -> void:
	var idx := settings_tabs.get_tab_idx_from_control(joypad_tab)
	var has_joypad := not SettingsManager.get_real_joypads().is_empty()

	settings_tabs.set_tab_disabled(idx, not has_joypad)
	settings_tabs.set_tab_tooltip(idx, "" if has_joypad else "Connect a controller")

	# If there are no joypads and if joypad tab is active, move away from it
	if not has_joypad and settings_tabs.current_tab == idx:
		settings_tabs.current_tab = 0
