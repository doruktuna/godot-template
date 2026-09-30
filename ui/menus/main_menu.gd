class_name MainMenu
extends Control

@onready var start_button: Button = %StartButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var credits_button: Button = %CreditsButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	start_button.grab_focus()
	quit_button.pressed.connect(_on_quit_button_pressed)


func _on_quit_button_pressed() -> void:
	get_tree().quit()