class_name PauseMenu
extends Control

@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var main_menu_button: Button = %MainMenuButton

@onready var save_load_menu: SaveLoadMenu = %SaveLoadMenu

signal resume_requested
signal main_menu_requested


func _ready() -> void:
	save_load_menu.hide()
	save_load_menu.save_load_canceled.connect(_on_save_load_canceled)

	resume_button.pressed.connect(_on_resume_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		resume_requested.emit()
		get_viewport().set_input_as_handled()


func show_menu() -> void:
	show()
	resume_button.grab_focus()


func hide_menu() -> void:
	hide()


func _on_resume_button_pressed() -> void:
	resume_requested.emit()


func _on_restart_button_pressed() -> void:
	EventBus.restart_requested.emit()


func _on_main_menu_button_pressed() -> void:
	main_menu_requested.emit()


func _on_save_button_pressed() -> void:
	save_load_menu.setup_slots(false)
	save_load_menu.show()


func _on_load_button_pressed() -> void:
	save_load_menu.setup_slots(true)
	save_load_menu.show()


func _on_save_load_canceled() -> void:
	save_load_menu.hide()