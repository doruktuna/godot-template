class_name MainMenu
extends Control

@onready var start_button: Button = %StartButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var credits_button: Button = %CreditsButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	start_button.grab_focus()
	start_button.pressed.connect(_on_start_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)


func _on_start_button_pressed() -> void:
	EventBus.scene_change_requested.emit(SceneManager.Scene.LEVEL_1, {})


func _on_quit_button_pressed() -> void:
	get_tree().quit()