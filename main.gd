extends Node2D


## How fast the camera speed should increase
@export_range(0, 1) var camera_move_speed_multiplier: float = 0.1

## How fast the camera should move at the start
@export var verical_camera_move_speed: float = 10


@onready var main_camera: Camera2D = $MainCamera


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# move camera up every so often
	main_camera.position.y -= verical_camera_move_speed * delta
	verical_camera_move_speed *= 1 + (camera_move_speed_multiplier * delta)
