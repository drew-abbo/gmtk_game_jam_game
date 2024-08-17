extends Node2D


## How fast the camera speed should increase
@export_range(0, 1) var camera_move_speed_multiplier: float = 0.1

## How fast the camera should move at the start
@export var verical_camera_move_speed: float = 10

const ALL_PIECES: Array[Resource] = [
	preload("res://Building/Pieces/test_piece.tscn"),
]

@onready var main_camera: Camera2D = $MainCamera

var current_user_controlled_piece: BuildingPiece = null


func _ready() -> void:
	_spawn_new_building_piece()


func _process(delta: float) -> void:
	# move camera up
	main_camera.position.y -= verical_camera_move_speed * delta
	verical_camera_move_speed *= 1 + (camera_move_speed_multiplier * delta)


## Spawns a new building piece for the player
func _spawn_new_building_piece() -> void:
	current_user_controlled_piece = ALL_PIECES.pick_random().instantiate()
	add_child(current_user_controlled_piece)

	current_user_controlled_piece.connect("building_piece_collided", _spawn_new_building_piece)

	current_user_controlled_piece.position = main_camera.position
