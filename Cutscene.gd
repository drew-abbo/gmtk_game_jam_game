extends Node2D

const CUTSCENE_FRAME_1: Resource = preload("res://Assets/Cutscene 1.png")
const CUTSCENE_FRAME_2: Resource = preload("res://Assets/Cutscene 2.png")
const CUTSCENE_FRAME_3: Resource = preload("res://Assets/Cutscene 3.png")
const CUTSCENE_FRAME_4: Resource = preload("res://Assets/Cutscene 4.png")

@onready var frame: Sprite2D = $Frame

var frameCount: int = 1


func _ready() -> void:
	frame.texture = CUTSCENE_FRAME_1
	frameCount = 1


func _on_timer_timeout() -> void:
	frameCount += 1
	match frameCount:
		1: frame.texture = CUTSCENE_FRAME_1
		2: frame.texture = CUTSCENE_FRAME_2
		3: frame.texture = CUTSCENE_FRAME_3
		4: frame.texture = CUTSCENE_FRAME_4
		5: get_tree().change_scene_to_file("res://game_intro.tscn")
