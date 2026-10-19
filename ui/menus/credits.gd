class_name Credits
extends Control

@export var scroll_speed := 60.0 # pixels per second
@export var fast_multiplier := 4.0
@export var ramp := 400.0 # speed change per second

@onready var content: VBoxContainer = %Content
@onready var spinning_godot: TextureRect = %SpinningGodot
@onready var scaling_godot: TextureRect = %ScalingGodot
@onready var modulating_godot: TextureRect = %ModulatingGodot
@onready var thanks_label: Label = %ThanksLabel
@onready var instruction_label: Label = %InstructionLabel

var _speed := 0.0
var _is_scroll_finished := false


func _ready() -> void:
	content.position.y = size.y # start just below the visible area
	_speed = scroll_speed


func _process(delta: float) -> void:
	if _is_scroll_finished:
		if Input.is_action_pressed("action"):
			EventBus.scene_change_requested.emit(SceneManager.Scene.MAIN_MENU, {})
		return
		
	var target := scroll_speed
	if Input.is_action_pressed("action"):
		target *= fast_multiplier
	_speed = move_toward(_speed, target, ramp * delta)
	content.position.y -= _speed * delta

	# Finish with thanks for playing label in the middle of screen, remove the last part to finish with credits going out of screen
	var content_stop_y := content.position.y + content.get_combined_minimum_size().y - thanks_label.size.y / 2
	if content_stop_y < get_viewport().get_visible_rect().size.y / 2:
		_is_scroll_finished = true
		instruction_label.text = "Click action or left mouse button to exit"
		instruction_label.add_theme_color_override("font_color", Color.html("#19e098"))
		return

	animate_godot_logos(delta)


func animate_godot_logos(delta: float) -> void:
	var time: float = float(Time.get_ticks_msec()) / 1000
	spinning_godot.offset_transform_rotation += delta * PI / 10
	scaling_godot.offset_transform_scale = (1 + (sin(time) / 2)) * Vector2.ONE # range: [0.5, 1.5]
	
	var modulate_mix = (1 + sin(time)) / 2 # range [0, 1]
	modulating_godot.modulate = Color.WHITE.lerp(Color.PURPLE, modulate_mix)
