extends Node2D

@onready var frame_timer: Timer = $SwitchFrameTimer
@onready var fade_in_fade_out: FadeInFadeOut = $FadeInFadeOut

const PRE_DELAY: float = 1
const POST_DELAY: float = 1

var _fade_in_done: bool = false


func _ready() -> void:
	fade_in_fade_out.schedule_fade_from_black(PRE_DELAY)	


func _on_switch_frame_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://game.tscn")


func _on_fade_in_fade_out_fade_completed() -> void:
	if not _fade_in_done:
		_fade_in_done = true
		fade_in_fade_out.schedule_fade_to_black(
				frame_timer.time_left - fade_in_fade_out.fade_time - POST_DELAY)	
