extends RigidBody2D


## Emits when the block contacts something
signal building_piece_collided

## The speed that the piece moves at left and right when controlled.
@export var left_right_move_speed: float = 500
@export var up_down_move_speed: float = 500
@export var rotate_speed: float = 10

var is_player_controlled: bool = true
var is_locked: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_player_controlled:
		linear_velocity.x += (
				Input.get_axis("move_left", "move_right") * left_right_move_speed * delta)
		linear_velocity.y += (
				Input.get_axis("move_up", "move_down") * up_down_move_speed * delta)
		angular_velocity += (
				Input.get_axis("rotate_left", "rotate_right") * rotate_speed * delta)


# when it contacts something lock it in place and remove player control
func _on_body_entered(_body: Node) -> void:
	is_player_controlled = false;

	# stop movement
	linear_velocity = Vector2(0, 0);
	angular_velocity = 0;

	# remove it's ability to collide
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	# make it so that this function doesn't get fired again if it regains the
	# ability to collide
	max_contacts_reported = 0
	contact_monitor = false

	# send a signal that says that we hit something
	building_piece_collided.emit()
