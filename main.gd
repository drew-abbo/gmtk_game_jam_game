extends Node2D

## How fast the camera speed should increase
const CAMERA_MOVE_SPEED_MULTIPLIER: float = 0.025
## How fast the camera should move at the start
var vertical_camera_move_speed: float = 2

## An array of all pieces that can be spawned. This array is shuffled, pieces
## are picked from it in order and then it's re-shuffled.
var new_piece_pool: Array[Resource] = [
	preload("res://Building/Pieces/Variants/circle_piece.tscn"),
	preload("res://Building/Pieces/Variants/octagon_piece.tscn"),
	preload("res://Building/Pieces/Variants/plus_piece.tscn"),
	preload("res://Building/Pieces/Variants/square_piece.tscn"),
	preload("res://Building/Pieces/Variants/triangle_piece.tscn"),
]
## The index of the next piece. If >= the length of the array the array will
## be shuffled and the index will be reset to 0 before picking.
var next_new_piece_index: int = new_piece_pool.size();

## Max possible velocity (magnitude) of newly spawned pieces.
const NEW_PIECE_MAX_VELOCITY_MAG: float = 100.0
## Max possible angular velocity of newly spawned pieces (spin).
const NEW_PIECE_MAX_ANGULAR_VELOCITY: float = 5.0
## The vertical offset from the middle of the camera where new pieces should go
const NEW_PIECE_OFFSET: float = 150.0

## References to all pieces that have been spawned (in order).
var all_pieces: Array[BuildingPiece] = []

## The maximum y position of a placed piece.
var highest_piece_pos: float = 1e10

@onready var main_camera: Camera2D = $MainCamera

var user_current_piece: BuildingPiece = null

var game_is_over: bool = false

func _ready() -> void:
	_spawn_new_building_piece()


func _process(delta: float) -> void:
	# move camera up
	main_camera.position.y -= vertical_camera_move_speed * delta
	vertical_camera_move_speed *= 1 + (CAMERA_MOVE_SPEED_MULTIPLIER * delta)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart") and not game_is_over:
		game_is_over = true

		# take away player control
		user_current_piece.disconnect("building_piece_collided", _spawn_new_building_piece)
		user_current_piece.lock_movement()
		user_current_piece = null

		# make pieces fall
		for piece in all_pieces:
			piece.unlock_movement()

		# stop camera from moving
		vertical_camera_move_speed = 0

## Spawns a new building piece for the player
func _spawn_new_building_piece() -> void:
	# update highest position info
	if (user_current_piece != null and user_current_piece.position.y < highest_piece_pos):
		highest_piece_pos = user_current_piece.position.y

	# make sure that pieces don't spawn in each other
	var new_piece_y_pos: float = main_camera.position.y;
	if highest_piece_pos < new_piece_y_pos:
		new_piece_y_pos = highest_piece_pos

	# make sure that the camera keeps up with the pieces
	if new_piece_y_pos < main_camera.position.y:
		main_camera.position.y = new_piece_y_pos

	# pick the next piece and then initialize (once it's loaded)
	if next_new_piece_index >= new_piece_pool.size():
		new_piece_pool.shuffle()
		next_new_piece_index = 0
	user_current_piece = new_piece_pool[next_new_piece_index].instantiate()
	next_new_piece_index += 1
	call_deferred("_initialize_new_building_piece", new_piece_y_pos - NEW_PIECE_OFFSET)


## Initializes the most recently added building piece
func _initialize_new_building_piece(new_piece_y_pos: float) -> void:
	if game_is_over:
		return

	add_child(user_current_piece)
	all_pieces.append(user_current_piece)

	# set the start position and give it a little starting movement
	user_current_piece.position.y = new_piece_y_pos
	var rand_angle: float = randf() * TAU
	user_current_piece.velocity = (
			Vector2(cos(rand_angle), sin(rand_angle))
			* randf_range(-NEW_PIECE_MAX_VELOCITY_MAG, NEW_PIECE_MAX_VELOCITY_MAG))
	user_current_piece.angular_velocity = (
		randf_range(-NEW_PIECE_MAX_ANGULAR_VELOCITY, NEW_PIECE_MAX_ANGULAR_VELOCITY))

	# spawn a new building piece when this one collides
	user_current_piece.connect("building_piece_collided", _spawn_new_building_piece)
