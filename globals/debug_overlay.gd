extends CanvasLayer

@onready var fps_value: Label = %FPSValue

@onready var restart_button: Button = %RestartButton
@onready var previous_level_button: Button = %PreviousLevelButton
@onready var next_level_button: Button = %NextLevelButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	hide()
	if not OS.is_debug_build():
		queue_free()

	connect_button_signals()


func connect_button_signals() -> void:
	restart_button.pressed.connect(func(): EventBus.restart_requested.emit())
	previous_level_button.pressed.connect(func(): EventBus.previous_level_requested.emit())
	next_level_button.pressed.connect(func(): EventBus.next_level_requested.emit())
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(func(): EventBus.quit_requested.emit())
	

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed('show_debug'):
		if visible:
			hide()
		else:
			show()


func _process(_delta: float) -> void:
	fps_value.text = str(Engine.get_frames_per_second())


func _on_main_menu_pressed() -> void:
	EventBus.scene_change_requested.emit(SceneManager.Scene.MAIN_MENU, {})
	hide()
