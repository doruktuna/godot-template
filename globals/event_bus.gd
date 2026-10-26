extends Node

@warning_ignore_start("unused_signal")

# Player Signals
signal player_died

# Scene management signals
signal scene_change_requested(scene: SceneManager.Scene, params: Dictionary)

# Save/load signals
signal save_requested(filename: String, cur_scene: SceneManager.Scene, image: Image)
signal load_requested(filename: String)

# Level/Game signals
signal quit_requested
signal restart_requested
signal level_completed
signal node_removed(node_path: String)
signal node_spawned(scene_path: String)

# Debug signals
signal next_level_requested

@warning_ignore_restore("unused_signal")
