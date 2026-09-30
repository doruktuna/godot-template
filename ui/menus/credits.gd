class_name Credits
extends Control


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		EventBus.scene_change_requested.emit(SceneManager.Scene.MAIN_MENU, {})

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		EventBus.scene_change_requested.emit(SceneManager.Scene.MAIN_MENU, {})
