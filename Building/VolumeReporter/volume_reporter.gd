@tool	# for the visualizer
class_name VolumeReporter
extends Node2D

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
@export_range(1, 1e10) var num_query_points: int = 50

## How often to read the volume.
const READ_DISTANCE: float = 3

## The number of steps in the average calculation (i.e. how many readings are
## included in the average).
const AVERAGE_VOLUME_STEPS: float = 60

## The volume of the tower (how full it is) as a percent (in range [0, 100]).
var average_volume: float

## The last y position (global) that a reading was made at.
var last_read_y_position: float

## The total number of readings done.
var total_readings: int = 0

@onready var line: Line2D = $Line

@onready var raycast: RayCast2D = $RayCast2D


func _ready() -> void:
	last_read_y_position = global_position.y
	average_volume = 100

	# hide the line if we're in the actual game
	#line.visible = Engine.is_editor_hint()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	while last_read_y_position - READ_DISTANCE > global_position.y:
		last_read_y_position = move_toward(last_read_y_position, global_position.y, READ_DISTANCE)

		average_volume = (
				(average_volume * (AVERAGE_VOLUME_STEPS - 1) + report_volume(last_read_y_position))
				/ AVERAGE_VOLUME_STEPS)
		total_readings += 1

	if line.visible:
		line.global_position.y = last_read_y_position


## Scans `num_query_points` evenly spaced points along the line and returns the
## percentage of points inside of a collision object. Result will be in the
## range [0, 100].
func report_volume(y_pos: float = position.y) -> float:
	assert(
		line.points != null
		and line.points.size() == 2
		and line.points[0].y == line.points[1].y,
		"The volume reporter line must have exactly 2 points with the same y level."
	)

	var raycast_start_x: float = raycast.global_position.x
	raycast.global_position.y = y_pos

	var count: int = 0
	for _i in num_query_points:
		raycast.position.x += length / num_query_points
		raycast.force_raycast_update()
		if raycast.is_colliding():
			count += 1

	raycast.global_position.x = raycast_start_x

	return (float(count) / num_query_points) * 100
