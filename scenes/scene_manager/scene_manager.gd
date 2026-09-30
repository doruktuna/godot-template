class_name SceneManager
extends Node

@export var start_scene: PackedScene

@onready var scene_container: Node = $SceneContainer
@onready var transition_layer: CanvasLayer = $TransitionLayer
@onready var snapshot: TextureRect = $TransitionLayer/Snapshot
@onready var animation_player: AnimationPlayer = $TransitionLayer/AnimationPlayer


func _ready() -> void:
	instantiate_start_scene()


func instantiate_start_scene() -> void:
	snapshot.hide()

	var scene_to_add := start_scene.instantiate()
	scene_container.add_child(scene_to_add)

	animation_player.play("fade_out")
	await animation_player.animation_finished

	transition_layer.hide()
