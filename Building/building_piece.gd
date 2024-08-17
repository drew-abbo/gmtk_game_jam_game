class_name BuildingPiece
extends Node

## Emits when the block contacts something
signal building_piece_collided

## The speed added to the piece when being moved by the player.
const PLAYER_MOVE_SPEED: float = 300
## The speed added to the piece when being rotated by the player.
const PLAYER_ROTATE_SPEED: float = 10
## The maximum distance the piece can get from the center of the screen while
## being controlled by the player.
const PLAYER_MAX_DIST_X_FROM_CENTER: float = 200
## The amount of force to use to push the piece towards the center of the screen
## when it gets too far.
const PLAYER_TOO_FAR_PUSH_FORCE: float = 200

## Whether the piece is currently being controlled by the player.
var is_player_controlled: bool = true

@onready var rigid_body_2d: RigidBody2D = $RigidBody2D

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
	# handle player movement
	if is_player_controlled:
		velocity.x += (Input.get_axis("move_left", "move_right") * PLAYER_MOVE_SPEED * delta)
		velocity.y += (Input.get_axis("move_up", "move_down") * PLAYER_MOVE_SPEED * delta)
		angular_velocity += (
			Input.get_axis("rotate_left", "rotate_right") * PLAYER_ROTATE_SPEED * delta)

		# make sure we don't keep moving if we're out of bounds
		if (position.x > PLAYER_MAX_DIST_X_FROM_CENTER and velocity.x > 0):
			velocity.x = -PLAYER_TOO_FAR_PUSH_FORCE
		elif (position.x < -PLAYER_MAX_DIST_X_FROM_CENTER and velocity.x < 0):
			velocity.x = PLAYER_TOO_FAR_PUSH_FORCE


# when it contacts something lock it in place and remove player control
func _on_rigid_body_2d_body_entered(_body: Node) -> void:
	lock_movement()

	# disable the ability for the signal to be sent in the future (even if it
	# regains the ability to collide)
	rigid_body_2d.call_deferred("set_contact_monitor", false)
	rigid_body_2d.max_contacts_reported = 0

	# send the signal that says that we hit something
	building_piece_collided.emit()


## Locks the piece in place and removes player control.
func lock_movement() -> void:
	is_player_controlled = false;

	# stop movement
	velocity = Vector2(0, 0);
	rigid_body_2d.angular_velocity = 0;

	# remove it's ability to collide with anything
	rigid_body_2d.set_collision_mask_value(1, false)


## Enables gravity and physics for the piece. Doesn't return player control.
func unlock_movement() -> void:
	# allow collisions
	rigid_body_2d.set_collision_mask_value(1, true)

	# gravity
	rigid_body_2d.gravity_scale = 1.0
