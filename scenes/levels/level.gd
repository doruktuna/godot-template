class_name Level
extends Node

@export var next_scene: SceneManager.Scene

@onready var pause_menu: PauseMenu = $CanvasLayer/PauseMenu
@onready var finish_area: Area2D = %FinishArea


func _ready() -> void:
	EventBus.quit_requested.connect(func(): get_tree().quit())
	get_window().grab_focus()

	EventBus.restart_requested.connect(_on_restart_requested)
	pause_menu.resume_requested.connect(_on_resume_requested)
	pause_menu.main_menu_requested.connect(_on_main_menu_requested)
	finish_area.body_entered.connect(_on_finish_area_body_entered)


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
	EventBus.restart_requested.emit()


func _on_resume_requested() -> void:
	unpause_game()


func _on_main_menu_requested() -> void:
	EventBus.scene_change_requested.emit(SceneManager.Scene.MAIN_MENU, {})


func _on_finish_area_body_entered(body: Node2D) -> void:
	print("FINISH AREA ENTERED: ", self, ", ", body)
	EventBus.scene_change_requested.emit(next_scene, {})