extends Node

const SAVE_VERSION := 1

const SAVE_INFOS_FILE := "user://save_infos.dat"


func _ready() -> void:
	EventBus.save_requested.connect(_on_save_requested)
	EventBus.load_requested.connect(_on_load_requested)


func _on_save_requested(filename: String, cur_scene: SceneManager.Scene, image: Image) -> void:
	var data: Dictionary = {"cur_scene": cur_scene}
	var saveable_nodes := get_tree().get_nodes_in_group("saveable")
	for sn in saveable_nodes:
		if not sn.is_in_group("spawned"):
			data[sn.get_path()] = sn.save_state()

	save_data(filename, data)
	if image != null:
		save_image(filename, image)
	update_save_info(filename, image != null)


func _on_load_requested(filename: String) -> void:
	var data: Dictionary = load_data(filename)
	var params := {"load_data": data}
	EventBus.scene_change_requested.emit(data["cur_scene"], params)


func load_saveable_nodes(data: Dictionary) -> void:
	print("Load saveables")
	var saveable_nodes := get_tree().get_nodes_in_group("saveable")
	for sn in saveable_nodes:
		if sn.get_path() in data:
			sn.load_state(data[sn.get_path()])


func save_data(filename: String, data: Dictionary) -> bool:
	data["version"] = SAVE_VERSION

	var full_path := create_game_save_path(filename)
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
	print(JSON.stringify(data, "  "))

	# Write a text version of the file for debugging
	if OS.is_debug_build():
		var debug_file := FileAccess.open(full_path + ".debug.txt", FileAccess.WRITE)
		debug_file.store_string(var_to_str(data))
	return true


func update_save_info(filename: String, image_exists: bool) -> bool:
	var save_infos = {}
	var file := FileAccess.open(SAVE_INFOS_FILE, FileAccess.READ)
	if file != null:
		save_infos = file.get_var()

	save_infos[filename] = {
		"date": Time.get_date_dict_from_system(),
		"time": Time.get_time_dict_from_system(),
		"is_image_exists": image_exists
	}

	var tmp_path := SAVE_INFOS_FILE + ".tmp"
	var save_file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if save_file == null:
		push_error("Save failed: %s" % error_string(FileAccess.get_open_error()))
		return false
	save_file.store_var(save_infos)
	save_file.close()

	# Swap in only after a complete write, so a crash mid-save can't corrupt the old save
	DirAccess.rename_absolute(tmp_path, SAVE_INFOS_FILE)
	print("Save infos updated at: ", SAVE_INFOS_FILE)
	print(JSON.stringify(save_infos, "  "))

	return true


func get_save_infos() -> Dictionary:
	var file := FileAccess.open(SAVE_INFOS_FILE, FileAccess.READ)
	if file == null:
		return {}

	var data = file.get_var()
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Save infos file is corrupt or not a dictionary")
		return {}

	return data


func load_data(filename: String) -> Dictionary:
	var full_path := create_game_save_path(filename)
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


func create_game_save_path(filename: String) -> String:
	return "user://save_" + filename + ".dat"


func create_image_save_path(filename: String) -> String:
	return "user://image_" + filename + ".png"


func is_save_exists(filename: String) -> bool:
	var full_path := create_game_save_path(filename)
	return FileAccess.file_exists(full_path)


func is_image_exists(filename: String) -> bool:
	var full_path := create_image_save_path(filename)
	return FileAccess.file_exists(full_path)


func save_image(filename: String, image: Image) -> String:
	var full_path = create_image_save_path(filename)
	var error = image.save_png(full_path)
	if error != OK:
		printerr("Image couldn't be saved: ", filename, ", ", image)
		return ""
	return full_path


func load_image(filename: String) -> Image:
	var full_path = create_image_save_path(filename)
	var image := Image.load_from_file(full_path)
	if image == null:
		printerr("Image couldn't be load: ", filename, ", ", full_path)
	return image