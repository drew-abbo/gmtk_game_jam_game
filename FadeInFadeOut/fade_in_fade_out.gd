class_name FadeInFadeOut
extends Node2D

## Emitted when a fade finishes.
signal fade_completed

## The possible things that can be done on load.
enum DoOnReadyOptions {
	SET_CLEAR,
	SET_BLACK,
	FADE_TO_BLACK,
	FADE_FROM_BLACK,
}

## What to do when this node is ready.
@export var do_on_ready: DoOnReadyOptions = DoOnReadyOptions.SET_CLEAR
## Time in seconds that fades should take to complete.
@export_range(0.01, 120.0) var fade_time: float = 2.5
 
var _curr_black_amount: float
var _target_black_amount: float;
var _in_fade: bool

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer


func _ready() -> void:
	match do_on_ready:
		DoOnReadyOptions.SET_CLEAR:
			set_clear()
		DoOnReadyOptions.SET_BLACK:
			set_black()
		DoOnReadyOptions.FADE_TO_BLACK:
			fade_to_black()
		DoOnReadyOptions.FADE_FROM_BLACK:
			fade_from_black()


func _process(delta: float) -> void:
	if _in_fade:
		_curr_black_amount = move_toward(_curr_black_amount, _target_black_amount, delta / fade_time)
		sprite.material.set("shader_parameter/black_amount", clampf(_curr_black_amount, 0.0, 1.0))
		if _curr_black_amount == _target_black_amount:
			_in_fade = false
			fade_completed.emit()


func set_clear() -> void:
	_curr_black_amount = 0.0
	_target_black_amount = 0.0
	_in_fade = false


func set_black() -> void:
	_curr_black_amount = 1.0
	_target_black_amount = 1.0
	_in_fade = false


func fade_from_black() -> void:
	_curr_black_amount = 1.0
	_target_black_amount = 0.0
	_in_fade = true


func fade_to_black() -> void:
	_curr_black_amount = 0.0
	_target_black_amount = 1.0
	_in_fade = true


func schedule_fade_from_black(seconds: float) -> void:
	_curr_black_amount = 1.0 + (seconds / fade_time)
	_target_black_amount = 0.0
	_in_fade = true


func schedule_fade_to_black(seconds: float) -> void:
	_curr_black_amount = 0.0 - (seconds / fade_time)
	_target_black_amount = 1.0
	_in_fade = true
