class_name BarrelSpawner
extends Area2D

var barrel_scene: PackedScene = preload("uid://dhh07jophfsnr")

@export var normal_texture: Texture2D
@export var pressed_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var barrels: Node2D = $Barrels

var is_pressed := false

func _ready() -> void:
	print("Barrel spawner ready")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(_body: Player) -> void:
	if is_pressed:
		return

	print("On player entered")
	sprite.texture = pressed_texture
	is_pressed = true

	generate_barrel()
	

func _on_body_exited(_body: Player) -> void:
	print("On player exited")
	sprite.texture = normal_texture
	is_pressed = false

func generate_barrel() -> void:
	var barrel: Barrel = barrel_scene.instantiate()
	barrels.add_child.call_deferred(barrel)
	barrel.position = 400 * Vector2.UP

	# Apply a random force to move the barrel
	var random_dir := Vector2.UP.rotated(randf_range(0, 2 * PI))
	barrel.apply_central_impulse(random_dir * 40)
	barrel.add_to_group("spawned")


func save_state() -> Dictionary:
	return {"is_pressed": is_pressed}


func load_state(data: Dictionary) -> void:
	is_pressed = data.is_pressed
	if is_pressed:
		sprite.texture = pressed_texture