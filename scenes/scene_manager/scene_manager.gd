class_name SceneManager
extends Node

@export var start_scene: PackedScene

@onready var scene_container: Node = $SceneContainer
@onready var persist_objects: Node = $PersistObjects
@onready var transition_layer: CanvasLayer = $TransitionLayer
@onready var snapshot: TextureRect = $TransitionLayer/Snapshot
@onready var overlay: ColorRect = $TransitionLayer/Overlay
@onready var loading_label: Label = $TransitionLayer/LoadingLabel
@onready var animation_player: AnimationPlayer = $TransitionLayer/AnimationPlayer

enum Scene {MAIN_MENU, SETTINGS_MENU, CREDITS, LEVEL_1, LEVEL_2}

const SCENES := {
	Scene.MAIN_MENU: "uid://c14p3tv3084fc",
	Scene.SETTINGS_MENU: "uid://bmn6dp2fgrq76",
	Scene.CREDITS: "uid://c43wcx7i5vjej",
	Scene.LEVEL_1: "uid://da3wyax0qgsew",
	Scene.LEVEL_2: "uid://m3wdqb178x4o",
}


func _ready() -> void:
	instantiate_start_scene()
	EventBus.scene_change_requested.connect(_on_scene_change_request)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		print("--- TEST ---")
		var search := "Player"
		var child := scene_container.find_child(search, true, false)
		if child:
			print("A pn match is found: ", search, ", ", child)
		else:
			print("A pn match couldn't be found: ", search, ", in ", scene_container)
		print()


func instantiate_start_scene() -> void:
	snapshot.hide()

	var scene_to_add := start_scene.instantiate()
	scene_container.add_child(scene_to_add)

	animation_player.play("fade_out")
	await animation_player.animation_finished

	transition_layer.hide()


func _on_scene_change_request(scene: Scene, params: Dictionary) -> void:
	print("Scene change requested: ", scene)
	change_to_scene(scene, params)


func change_to_scene(scene: Scene, _params: Dictionary) -> void:
	get_tree().paused = true

	# Reparent persistent objects to PersistObjects node so that they aren't freed
	capture_persistent_objects()

	# This starts loading the new scene into memory
	ResourceLoader.load_threaded_request(SCENES[scene])

	# Remove current scene and fade out to black
	await capture_and_show_snapshot()
	remove_current_scene()
	await fade_out_animation()

	# Add new scene and fade in from black
	var new_scene := await add_new_scene(scene)
	var original_mode := new_scene.process_mode
	new_scene.process_mode = Node.PROCESS_MODE_DISABLED

	# Restore persistent objects to the new scene
	restore_persistent_objects()

	# Fade in and unpause the game
	await fade_in_animation()
	new_scene.process_mode = original_mode
	get_tree().paused = false

	
func capture_persistent_objects() -> void:
	print("CAPTURING PERSISTENT OBJECTS")
	var persistent_nodes := get_tree().get_nodes_in_group("persistent")
	for pn in persistent_nodes:
		pn.start_persisting()
		pn.reparent.call_deferred(persist_objects)


func restore_persistent_objects() -> void:
	for pn in persist_objects.get_children():
		# If a node with same name exists in the new scene
		var child := scene_container.find_child(pn.name, true, false)
		if child:
			print("A pn match is found: ", pn.name, ", ", child)
			child.name = child.name + "_TO_BE_FREED"
			pn.reparent(child.get_parent())
			if pn is Node2D:
				pn.global_position = child.global_position
				pn.rotation = child.rotation
			pn.end_persisting()
			child.queue_free()
		else:
			print("A pn match couldn't be found: ", pn.name)
			pn.queue_free()

		
func capture_and_show_snapshot() -> void:
	# Wait the frame draw in order not to capture unfinished frames
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image != null:
		snapshot.texture = ImageTexture.create_from_image(image)
		snapshot.show()

	hide_overlay()
	transition_layer.show()

	
func hide_overlay() -> void:
	overlay.color.a = 0
	loading_label.modulate.a = 0


func fade_out_animation() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	snapshot.hide()
	snapshot.texture = null


func fade_in_animation() -> void:
	animation_player.play("fade_in")
	await animation_player.animation_finished
	transition_layer.hide()


func remove_current_scene() -> void:
	for child in scene_container.get_children():
		child.queue_free()


func add_new_scene(scene: Scene) -> Node:
	var path: String = SCENES[scene]
	
	# Wait if necessary
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
	
	# Load and instantiate the scene
	var packed := ResourceLoader.load_threaded_get(path) as PackedScene
	var new_scene := packed.instantiate()
	scene_container.add_child(new_scene)

	return new_scene
