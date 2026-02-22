extends Node3D

@export var min_scale: Vector3 = Vector3.ONE
@export var max_scale: Vector3 = Vector3.ONE
@export var speed: float = 1.0
@export var randomize_start: bool = false

var _start: float

func _ready() -> void:
	if (randomize_start):
		_start = randf_range(-1000, 1000)

func _process(_delta: float) -> void:
	scale = lerp(
		min_scale, 
		max_scale, 
		sin(speed * Time.get_ticks_msec() / 1000.0 + _start) / 2.0 + 0.5
		)
