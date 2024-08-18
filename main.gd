extends Node2D

## How fast the camera speed should increase
const CAMERA_MOVE_SPEED_MULTIPLIER: float = 0.01
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

## The number of seconds to include in the average volume calculation (e.g. 30
## means the average will be calculated like it's using only data from the last
## 30 seconds).
const AVERAGE_VOLUME_SECONDS: float = 30

## The volume of the tower (how full it is) as a percent (in range [0, 100]).
var average_volume_percent: float = 100

## References to all pieces that have been spawned (in order).
var all_pieces: Array[BuildingPiece] = []

## The maximum y position of a placed piece.
var highest_piece_pos: float = 1e10
## The starting position of the camera (set by `_ready()`).
var camera_start_position: Vector2

## Reference to the piece the user is currently controlling.
var user_current_piece: BuildingPiece = null

## Whether or not the game is over.
var game_is_over: bool = false

@onready var main_camera: Camera2D = $MainCamera

@onready var volume_reporter: VolumeReporter = $MainCamera/VolumeReporter

@onready var game_over_delay_timer: Timer = $GameOverDelayTimer

@onready var recalculate_volume_timer: Timer = $MainCamera/VolumeReporter/RecalculateVolumeTimer

@onready var fade_in_fade_out: FadeInFadeOut = $FadeInFadeOut


func _ready() -> void:
	camera_start_position = main_camera.position
	_spawn_new_building_piece()


func _process(delta: float) -> void:
	if not game_is_over:
		# move camera up
		main_camera.position.y -= vertical_camera_move_speed * delta
		vertical_camera_move_speed *= 1 + (CAMERA_MOVE_SPEED_MULTIPLIER * delta)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart") and not game_is_over:
		end_game()


func end_game() -> void:
	game_is_over = true

	# take away player control
	user_current_piece.disconnect("building_piece_collided", _spawn_new_building_piece)
	user_current_piece.lock_movement()
	user_current_piece = null

	# make pieces fall
	for piece in all_pieces:
		piece.unlock_movement()

	# stop camera from moving and move it down to the starting position
	vertical_camera_move_speed = 0
	main_camera.position = camera_start_position

	# start a timer to reset the scene tree
	# timer takes 3 seconds, fade out takes 0.5
	game_over_delay_timer.start()
	fade_in_fade_out.schedule_fade_to_black(2.5)


## Spawns a new building piece for the player
func _spawn_new_building_piece() -> void:
	if game_is_over:
		return

	# update highest position info
	if (
			user_current_piece != null
			and user_current_piece.is_node_ready()
			and user_current_piece.position.y < highest_piece_pos
	):
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
	if user_current_piece.velocity.y < 0:
		user_current_piece.velocity.y = -user_current_piece.velocity.y
	user_current_piece.angular_velocity = (
		randf_range(-NEW_PIECE_MAX_ANGULAR_VELOCITY, NEW_PIECE_MAX_ANGULAR_VELOCITY))

	# spawn a new building piece when this one collides
	user_current_piece.connect("building_piece_collided", _spawn_new_building_piece)


# end the game
func _on_game_over_delay_timer_timeout() -> void:
	get_tree().reload_current_scene()


func _on_recalculate_volume_timer_timeout() -> void:
	var curr_volume_percent: float = volume_reporter.report_volume()
	var steps: float = AVERAGE_VOLUME_SECONDS * (1 / recalculate_volume_timer.wait_time)
	average_volume_percent = ((average_volume_percent * (steps - 1) + curr_volume_percent) / steps)

	# update volume debug info
	$MainCamera/VolumeDebugInfo.text = (
			"curr vol = " + str(curr_volume_percent) + "%\n" +
			"avg vol = " + str(average_volume_percent) + " %")
