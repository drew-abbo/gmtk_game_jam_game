extends AnimatedSprite2D

@onready var timer = $Timer

var RNG = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
			shoot()
func shoot():
	if timer.time_left < 0.05:
		RNG = randf_range(0, 10)
		if RNG > 9:
			play("Shoot")
		if RNG < 9 and animation_finished:
			play("Nothing")
