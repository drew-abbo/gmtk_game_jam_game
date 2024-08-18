class_name BuildingPiece
extends Node

## Emits when the block contacts something
signal building_piece_collided

## The speed added to the piece when being moved by the player.
const PLAYER_MOVE_SPEED: float = 300
## The speed added to the piece when being rotated by the player.
const PLAYER_ROTATE_SPEED: float = 10

## The speed at which to accelerate something up when dropped by the player.
const PLAYER_DROP_BOOST: float = 100

## Whether the piece is currently being controlled by the player.
var is_player_controlled: bool = true

## When true the piece will freeze once it is going slow enough.
var freeze_when_slow: bool = false

## If `not is_player_controlled and freeze_when_slow` and the velocity magnitude
## is less than this value the piece will freeze.
var freeze_below_velocity: float = 30

@onready var rigid_body_2d: RigidBody2D = $RigidBody2D

@onready var allow_freeze_timer: Timer = $AllowFreezeTimer


var position: Vector2:
	set(new_position):
		rigid_body_2d.position = new_position
	get:
		return rigid_body_2d.position

var velocity: Vector2:
	set(new_velocity):
		rigid_body_2d.linear_velocity = new_velocity
	get:
		return rigid_body_2d.linear_velocity

var angular_velocity: float:
	set(new_angular_velocity):
		rigid_body_2d.angular_velocity = new_angular_velocity
	get:
		return rigid_body_2d.angular_velocity


func _physics_process(delta: float) -> void:
	if is_player_controlled:
		# player drops piece
		if Input.is_action_just_pressed("drop_piece"):
			is_player_controlled = false
			allow_freeze_timer.start()
			rigid_body_2d.gravity_scale = 1.0
			rigid_body_2d.linear_velocity.y -= PLAYER_DROP_BOOST
			send_building_piece_collided()
			return

		# handle player movement
		velocity.x += (Input.get_axis("move_left", "move_right") * PLAYER_MOVE_SPEED * delta)
		velocity.y += (Input.get_axis("move_up", "move_down") * PLAYER_MOVE_SPEED * delta)
		angular_velocity += (
			Input.get_axis("rotate_left", "rotate_right") * PLAYER_ROTATE_SPEED * delta)

	if freeze_when_slow:
		if absf(velocity.length()) < freeze_below_velocity:
			freeze_when_slow = false
			lock_movement()
		else:
			freeze_below_velocity += delta


func send_building_piece_collided() -> void:
	# disable the ability for the signal to be sent in the future (even if it
	# regains the ability to collide)
	rigid_body_2d.call_deferred("set_contact_monitor", false)
	rigid_body_2d.max_contacts_reported = 0

	# send the signal that says that we hit something
	building_piece_collided.emit()


## Locks the piece in place and removes player control.
func lock_movement() -> void:
	print("LOCKING IN")
	is_player_controlled = false;

	# stop movement
	velocity = Vector2(0, 0);
	rigid_body_2d.angular_velocity = 0;
	rigid_body_2d.gravity_scale = 0.0

	# remove it's ability to collide with anything
	rigid_body_2d.set_collision_mask_value(1, false)	# gound/other pieces
	rigid_body_2d.set_collision_mask_value(2, false)	# invisible walls


## Enables gravity and physics for the piece. Doesn't return player control.
func unlock_movement() -> void:
	# unschedule freeze
	allow_freeze_timer.stop()
	freeze_when_slow = false

	# allow collisions w/ gound/other pieces
	rigid_body_2d.set_collision_mask_value(1, true)

	# gravity
	rigid_body_2d.gravity_scale = 1.0


func _on_allow_freeze_timer_timeout() -> void:
	freeze_when_slow = true
