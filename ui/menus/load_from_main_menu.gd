class_name LoadFromMainMenu
extends Control

@onready var save_load_menu: SaveLoadMenu = %SaveLoadMenu


func _ready() -> void:
	save_load_menu.save_load_canceled.connect(_on_save_load_canceled)


func _on_save_load_canceled() -> void:
	EventBus.scene_change_requested.emit(SceneManager.Scene.MAIN_MENU, {})