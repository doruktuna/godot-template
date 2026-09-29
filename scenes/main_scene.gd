extends Node2D


func _ready() -> void:
	EventBus.quit_requested.connect(func(): get_tree().quit())
	get_window().grab_focus()
