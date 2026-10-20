extends Node

const SAVE_VERSION := 1


func _ready() -> void:
	EventBus.save_requested.connect(_on_save_requested)
	EventBus.load_requested.connect(_on_load_requested)


func _on_save_requested(file_path: String, cur_scene: SceneManager.Scene) -> void:
	var data: Dictionary = {"cur_scene": cur_scene}
	var saveable_nodes := get_tree().get_nodes_in_group("saveable")
	for sn in saveable_nodes:
		data[sn.get_path()] = sn.save()
	print("Save data: ", data)
	save_data(file_path, data)


func _on_load_requested(file_path: String) -> void:
	var data: Dictionary = load_data(file_path)
	var params := {"load_data": data}
	EventBus.scene_change_requested.emit(data["cur_scene"], params)

	
func load_saveable_nodes(data: Dictionary) -> void:
	var saveable_nodes := get_tree().get_nodes_in_group("saveable")
	for sn in saveable_nodes:
		if sn.get_path() in data:
			sn.load(data[sn.get_path()])


func save_data(file_path: String, data: Dictionary) -> bool:
	data["version"] = SAVE_VERSION

	var full_path := "user://save_" + file_path + ".dat"
	var tmp_path := full_path + ".tmp"
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		push_error("Save failed: %s" % error_string(FileAccess.get_open_error()))
		return false
	file.store_var(data)
	file.close()

	# Swap in only after a complete write, so a crash mid-save can't corrupt the old save
	DirAccess.rename_absolute(tmp_path, full_path)
	print("Saved to: ", full_path)

	# Write a text version of the file for debugging
	if OS.is_debug_build():
		var debug_file := FileAccess.open(full_path + ".debug.txt", FileAccess.WRITE)
		debug_file.store_string(var_to_str(data))
	return true


func load_data(file_path: String) -> Dictionary:
	var full_path := "user://save_" + file_path + ".dat"
	if not FileAccess.file_exists(full_path):
		push_error("Load file doesn't exist: ", full_path)
		return {}

	var file := FileAccess.open(full_path, FileAccess.READ)
	if file == null:
		push_error("Load failed: %s" % error_string(FileAccess.get_open_error()))
		return {}

	var data = file.get_var()
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Save file is corrupt or not a dictionary")
		return {}

	# TODO Add version migration while loading
	return data
