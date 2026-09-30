class_name SettingsMenu
extends Control

@onready var discard_button: Button = %DiscardButton
@onready var save_button: Button = %SaveButton


func _ready() -> void:
	discard_button.grab_focus()
	discard_button.pressed.connect(_on_discard_pressed)
	save_button.pressed.connect(_on_save_pressed)


func _on_discard_pressed() -> void:
	EventBus.scene_change_requested.emit(SceneManager.Scene.MAIN_MENU, {})


func _on_save_pressed() -> void:
	EventBus.scene_change_requested.emit(SceneManager.Scene.MAIN_MENU, {})