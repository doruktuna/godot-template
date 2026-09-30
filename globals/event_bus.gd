extends Node

@warning_ignore_start("unused_signal")

# Player Signals
signal player_died

# Scene management signals
signal scene_change_requested(scene: SceneManager.Scene, params: Dictionary)

# Level/Game signals
signal quit_requested
signal restart_requested
signal level_completed

# Debug signals
signal previous_level_requested
signal next_level_requested

@warning_ignore_restore("unused_signal")
