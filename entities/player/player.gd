class_name Player
extends CharacterBody2D

const COLORS: Array[Color] = [Color.WHITE, Color.RED, Color.YELLOW, Color.REBECCA_PURPLE, Color.DARK_ORANGE]

# TODO Revert high speed when testing is finished
@export var speed: float = 300.0 * 3
@export var speed_up_coef: float = 1000.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var color_ind = 0


func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")

	velocity = velocity.move_toward(direction * speed, delta * speed_up_coef)
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		sprite.rotate(PI / 4)
		collision_shape.rotate(PI / 4)

	if event.is_action_pressed("action_2"):
		color_ind = posmod(color_ind + 1, COLORS.size())
		sprite.modulate = COLORS[color_ind]


func start_persisting() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO


func end_persisting() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	velocity = Vector2.ZERO


func save() -> Dictionary:
	var data := {
		"global_position": global_position,
		"rotation": rotation,
		"sprite_rotation": sprite.rotation,
		"color_ind": color_ind
	}
	return data


func load(data: Dictionary) -> void:
	global_position = data["global_position"]
	rotation = data["rotation"]
	sprite.rotation = data["sprite_rotation"]
	color_ind = data["color_ind"]
	sprite.modulate = COLORS[color_ind]
