class_name StabilityMeter
extends Node2D

@onready var bar_control: Control = $BarControl

var _max_size: float

func _ready() -> void:
	_max_size = bar_control.size.y


## Set the visibility of the bar as a percent (in the range [0, 100]).
func set_visible_percent(amount: float) -> void:
	amount = clampf(amount, 0.0, 100.0) / 100
	bar_control.size.y = amount * _max_size
