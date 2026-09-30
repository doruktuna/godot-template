class_name StartLevel
extends Node2D

@onready var pause_menu: PauseMenu = $CanvasLayer/PauseMenu


func _ready() -> void:
	EventBus.quit_requested.connect(func(): get_tree().quit())
	get_window().grab_focus()

	EventBus.restart_requested.connect(_on_restart_requested)
	pause_menu.resume_requested.connect(_on_resume_requested)
	pause_menu.main_menu_requested.connect(_on_main_menu_requested)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		pause_game()


func pause_game() -> void:
	get_tree().paused = true
	pause_menu.show_menu()


func unpause_game() -> void:
	get_tree().paused = false
	pause_menu.hide_menu()


func _on_restart_requested() -> void:
	print("RESTART request")


func _on_resume_requested() -> void:
	print("RESUME request")
	unpause_game()


func _on_main_menu_requested() -> void:
	EventBus.scene_change_requested.emit(SceneManager.Scene.MAIN_MENU, {})