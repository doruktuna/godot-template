# TODO Create a Level scene and instantiate levels from that scene, so that required nodes exists (finish_area and pause_menu)
class_name Level
extends Node

@export var next_scene: SceneManager.Scene

@onready var pause_menu: PauseMenu = $CanvasLayer/PauseMenu
@onready var finish_area: Area2D = %FinishArea

var removed_nodes: Array[String] = []


func _ready() -> void:
	get_window().grab_focus()

	EventBus.quit_requested.connect(func(): get_tree().quit())
	EventBus.restart_requested.connect(_on_restart_requested)
	EventBus.node_removed.connect(_on_node_freed)
	EventBus.hide_menus_requested.connect(_on_hide_menus_requested)
	EventBus.show_menus_requested.connect(_on_show_menus_requested)

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


func _on_node_freed(node_path: String) -> void:
	print("Node freed: ", node_path)
	removed_nodes.append(node_path)


func save_state() -> Dictionary:
	print("Level save")
	var spawned_nodes = get_spawned_nodes()
	var data := {
		"removed": removed_nodes,
		"spawned": spawned_nodes,
	}
	return data


func load_state(data: Dictionary) -> void:
	print("Level load")
	removed_nodes = data.removed
	free_removed_nodes(removed_nodes)
	restore_spawned_nodes(data.spawned)
	

func free_removed_nodes(freed_node_paths: Array[String]) -> void:
	for fnp: String in freed_node_paths:
		var node = get_node(fnp)
		if node:
			node.queue_free()

# TODO Its a better idea to migrate all this logic into SaveManager
func get_spawned_nodes() -> Array:
	var spawned_nodes: Array = []
	for i_node in get_tree().get_nodes_in_group("spawned"):
		spawned_nodes.append({
			"parent_path": str(get_path_to(i_node.get_parent())),
			"scene_path": i_node.scene_file_path,
			"data": i_node.save_state()
		})
	return spawned_nodes


func restore_spawned_nodes(spawned_nodes: Array) -> void:
	for entry in spawned_nodes:
		var parent := get_node_or_null(entry.parent_path)
		if parent == null:
			push_warning("Spawn parent not found: %s" % entry.parent_path)
			continue

		var packed := load(entry.scene_path) as PackedScene
		if packed == null:
			push_warning("Spawn scene not found: %s" % entry.scene_path)
			continue

		var node := packed.instantiate()
		parent.add_child(node)
		node.load_state(entry.data)
		node.add_to_group("spawned")


func _on_hide_menus_requested() -> void:
	pause_menu.hide()


func _on_show_menus_requested() -> void:
	pause_menu.show()