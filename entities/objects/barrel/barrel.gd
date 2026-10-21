class_name Barrel
extends RigidBody2D

@export var normal_texture: Texture2D
@export var cracked_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var invulnerable_timer: Timer = $InvulnerableTimer

var health := 2
var is_invulnerable := false


func _ready() -> void:
	invulnerable_timer.timeout.connect(_on_invulnerable_timer_timeout)


func hit(body: Node):
	print("Barrel hit: ", self, ", ", body)
	if body is Player and not is_invulnerable:
		crack()


func crack() -> void:
	health -= 1
	is_invulnerable = true
	invulnerable_timer.start()
	
	match health:
		1:
			sprite.texture = cracked_texture
		0:
			if not is_in_group("spawned"):
				EventBus.node_removed.emit(get_path())
			queue_free()
	

func _on_invulnerable_timer_timeout() -> void:
	is_invulnerable = false


func save_state() -> Dictionary:
	var data := {
		"global_position": global_position,
		"health": health,
	}
	return data


func load_state(data: Dictionary) -> void:
	global_position = data["global_position"]
	health = data["health"]
	match health:
		2:
			sprite.texture = normal_texture
		1:
			sprite.texture = cracked_texture
