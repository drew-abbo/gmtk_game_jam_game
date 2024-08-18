@tool	# for the visualizer
class_name VolumeReporter
extends Node2D

@onready var line: Line2D = $Line

## The length (going right) of the line to scan for volume
@export var length: float = 400:
	set(new_length):
		assert(
			line.points != null
			and line.points.size() == 2
			and line.points[0].y == line.points[1].y,
			"The volume reporter line must have exactly 2 points with the same y level."
		)

		line.points[1].x = new_length
	get:
		return line.points[1].x

## The number of positions to check along the line.
@export_range(1, 1e10) var num_query_points: int = 100

@onready var raycast: RayCast2D = $RayCast2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# hide the line if we're in the actual game
	#line.visible = false


## Scans `num_query_points` evenly spaced points along the line and returns the
## percentage of points inside of a collision object. Result will be in the
## range [0, 100].
func report_volume() -> float:
	assert(
		line.points != null
		and line.points.size() == 2
		and line.points[0].y == line.points[1].y,
		"The volume reporter line must have exactly 2 points with the same y level."
	)

	var raycast_start_pos: Vector2 = raycast.position

	var count: int = 0
	for _i in num_query_points:
		raycast.position.x += length / num_query_points
		raycast.force_raycast_update()
		if raycast.is_colliding():
			count += 1

	raycast.position = raycast_start_pos

	return (float(count) / num_query_points) * 100
