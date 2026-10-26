extends CanvasLayer

@onready var fps_value: Label = %FPSValue
@onready var ram_value: Label = %RAMValue
@onready var ss_texture_rect: TextureRect = %SSTextureRect

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
	next_level_button.pressed.connect(func(): EventBus.next_level_requested.emit())
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(func(): EventBus.quit_requested.emit())
	

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed('show_debug'):
		if visible:
			hide()
		else:
			show()

	if Input.is_action_just_pressed("capture_ss"):
		capture_and_update_ss()


func _process(_delta: float) -> void:
	fps_value.text = str(Engine.get_frames_per_second())

	var used_memory_bytes = Performance.get_monitor(Performance.MEMORY_STATIC)
	var used_memory_mb = used_memory_bytes / (1024 * 1024)
	var used_memory_gb = used_memory_mb / 1024
	if used_memory_gb > 1:
		ram_value.text = "%.1f GB" % used_memory_gb
	else:
		ram_value.text = "%.1f MB" % used_memory_mb


func _on_main_menu_pressed() -> void:
	EventBus.scene_change_requested.emit(SceneManager.Scene.MAIN_MENU, {})
	hide()


func capture_and_update_ss() -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image != null:
		ss_texture_rect.texture = ImageTexture.create_from_image(image)
		SaveManager.save_image("debug_ss", image)
