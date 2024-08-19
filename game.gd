extends Node2D

## The minimum average volume percent (building topples).
const MIN_AVG_VOLUME: float = 71


## How fast the camera speed should increase
const CAMERA_MOVE_SPEED_MULTIPLIER: float = 0.0125
## How fast the camera should move at the start
var vertical_camera_move_speed: float = 2

## An array of all pieces that can be spawned. This array is shuffled, pieces
## are picked from it in order and then it's re-shuffled.
var new_piece_pool: Array[Resource] = [
	preload("res://Building/Pieces/Variants/angle_box_1.tscn"),
	preload("res://Building/Pieces/Variants/angle_box_2.tscn"),
	preload("res://Building/Pieces/Variants/box_1.tscn"),
	preload("res://Building/Pieces/Variants/circle_1.tscn"),
	preload("res://Building/Pieces/Variants/octagon_1.tscn"),
	preload("res://Building/Pieces/Variants/plus_1.tscn"),
	preload("res://Building/Pieces/Variants/triangle_1.tscn"),
	preload("res://Building/Pieces/Variants/t_box_1.tscn"),
	preload("res://Building/Pieces/Variants/t_box_2.tscn"),
	preload("res://Building/Pieces/Variants/wide_box_1.tscn"),
	preload("res://Building/Pieces/Variants/wide_box_2.tscn"),
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

## The starting position of the camera (set by `_ready()`).
var camera_start_position: Vector2

## The distance between the middle and top of the camera.
const CAMERA_TOP_OFFSET: int = 200

## Reference to the piece the user is currently controlling.
var user_current_piece: BuildingPiece = null

## Whether or not the game is over.
var game_is_over: bool = false

@onready var main_camera: Camera2D = $MainCamera

@onready var volume_reporter: VolumeReporter = $MainCamera/VolumeReporter

@onready var game_over_delay_timer: Timer = $GameOverDelayTimer

@onready var fade_in_fade_out: FadeInFadeOut = $FadeInFadeOut

func _ready() -> void:
	camera_start_position = main_camera.position
	_spawn_new_building_piece()


func _process(delta: float) -> void:
	if not game_is_over:
		# move camera up
		main_camera.position.y -= vertical_camera_move_speed * delta
		vertical_camera_move_speed *= 1 + (CAMERA_MOVE_SPEED_MULTIPLIER * delta)

		# update volume debug info
		$MainCamera/VolumeDebugInfo.text = "avg vol = " + str(volume_reporter.average_volume) + "%"

		# fail the game if the average volume is too low
		if volume_reporter.average_volume < MIN_AVG_VOLUME:
			print("Game over: avg volume dropped below " + str(MIN_AVG_VOLUME) + "%")
			end_game()


func _physics_process(_delta: float) -> void:
	if user_current_piece != null and user_current_piece.is_node_ready():
		# make sure the block doesn't pass the top barrier
		if user_current_piece.position.y <= main_camera.position.y - CAMERA_TOP_OFFSET:
			if user_current_piece.velocity.y < 0:
				user_current_piece.velocity.y = 0
			user_current_piece.position.y = main_camera.position.y - CAMERA_TOP_OFFSET

	if Input.is_action_just_pressed("restart") and not game_is_over:
		end_game()


func end_game() -> void:
	game_is_over = true

	# take away player control
	if user_current_piece != null and user_current_piece.is_node_ready():
		user_current_piece.disconnect("building_piece_became_steel", _spawn_new_building_piece)
		user_current_piece.lock_movement()
	user_current_piece = null

	# make pieces fall
	for piece in all_pieces:
		piece.unlock_movement()

	# stop camera from moving and move it down to the starting position
	vertical_camera_move_speed = 0
	main_camera.position = camera_start_position

	# start a timer to reset the scene tree
	game_over_delay_timer.start()
	fade_in_fade_out.schedule_fade_to_black(
			game_over_delay_timer.wait_time - fade_in_fade_out.fade_time)


## Spawns a new building piece for the player
func _spawn_new_building_piece() -> void:
	if game_is_over:
		return

	if user_current_piece != null and user_current_piece.is_node_ready():
		# move camera up if the block became steel too high
		if user_current_piece.position.y < main_camera.position.y:
			main_camera.position.y = user_current_piece.position.y

	# pick the next piece and then initialize (once it's loaded)
	if next_new_piece_index >= new_piece_pool.size():
		new_piece_pool.shuffle()
		next_new_piece_index = 0
	user_current_piece = new_piece_pool[next_new_piece_index].instantiate()
	next_new_piece_index += 1

	call_deferred("_initialize_new_building_piece")


## Initializes the most recently added building piece
func _initialize_new_building_piece() -> void:
	if game_is_over:
		return

	add_child(user_current_piece)
	all_pieces.append(user_current_piece)

	# set the start position and give it a little starting movement
	user_current_piece.position.y = main_camera.position.y - NEW_PIECE_OFFSET
	var rand_angle: float = randf() * TAU
	user_current_piece.velocity = (
			Vector2(cos(rand_angle), sin(rand_angle))
			* randf_range(-NEW_PIECE_MAX_VELOCITY_MAG, NEW_PIECE_MAX_VELOCITY_MAG))
	if user_current_piece.velocity.y < 0:
		user_current_piece.velocity.y = -user_current_piece.velocity.y
	user_current_piece.angular_velocity = (
		randf_range(-NEW_PIECE_MAX_ANGULAR_VELOCITY, NEW_PIECE_MAX_ANGULAR_VELOCITY))

	# spawn a new building piece when this one collides
	user_current_piece.connect("building_piece_became_steel", _spawn_new_building_piece)


# end the game
func _on_game_over_delay_timer_timeout() -> void:
	get_tree().reload_current_scene()
