class_name Player
extends CharacterBody2D

@export var speed: float = 300.0
@export var speed_up_coef: float = 1000.0


func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")

	velocity = velocity.move_toward(direction * speed, delta * speed_up_coef)
	move_and_slide()
