class_name BuildingPiece
extends Node


## Emits when the block contacts something
signal building_piece_collided

@export_category("User Movement Speed")
@export var left_right_move_speed: float = 500
@export var up_down_move_speed: float = 500
@export var rotate_speed: float = 10

@export_category("Body")
@export var mass_kg: float = 1:
	set(new_mass):
		print("Setting mass")
		mass_kg = new_mass
		rigid_body_2d.mass = new_mass

var is_player_controlled: bool = true
var is_locked: bool = false

@onready var rigid_body_2d: RigidBody2D = $RigidBody2D

var position: Vector2:
	set(pos):
		rigid_body_2d.position = pos
	get:
		return rigid_body_2d.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_player_controlled:
		rigid_body_2d.linear_velocity.x += (
				Input.get_axis("move_left", "move_right") * left_right_move_speed * delta)
		rigid_body_2d.linear_velocity.y += (
				Input.get_axis("move_up", "move_down") * up_down_move_speed * delta)
		rigid_body_2d.angular_velocity += (
				Input.get_axis("rotate_left", "rotate_right") * rotate_speed * delta)


# when it contacts something lock it in place and remove player control
func _on_rigid_body_2d_body_entered(_body: Node) -> void:
	print("COLLISION!!!")

	is_player_controlled = false;

	# stop movement
	rigid_body_2d.linear_velocity = Vector2(0, 0);
	rigid_body_2d.angular_velocity = 0;

	# remove it's ability to collide
	rigid_body_2d.set_collision_mask_value(1, false)

	# disable the ability for the signal to be sent in the future (even if it
	# regains the ability to collide)
	rigid_body_2d.call_deferred("set_contact_monitor", false)
	rigid_body_2d.max_contacts_reported = 0

	# send the signal that says that we hit something
	building_piece_collided.emit()
