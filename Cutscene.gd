extends Node2D

const CUTSCENE_1 = preload("res://Assets/Cutscene 1.png")
const CUTSCENE_2 = preload("res://Assets/Cutscene 2.png")
const CUTSCENE_3 = preload("res://Assets/Cutscene 3.png")
const CUTSCENE_4 = preload("res://Assets/Cutscene 4.png")

@onready var sprite_2d = $Sprite2D
@onready var timer = $Timer

var frameCount := 0
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_2d.texture = CUTSCENE_1
	frameCount = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(frameCount)
	if frameCount == 1:
		sprite_2d.texture = CUTSCENE_1
	if frameCount == 2:
		sprite_2d.texture = CUTSCENE_2
	if frameCount == 3:
		sprite_2d.texture = CUTSCENE_3
	if frameCount == 4:
		sprite_2d.texture = CUTSCENE_4


func _on_timer_timeout():
	frameCount += 1 # Replace with function body.
