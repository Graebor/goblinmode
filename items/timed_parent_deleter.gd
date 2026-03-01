class_name TimedParentDeleter
extends Node

@export var time: float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(time).timeout
	get_parent().queue_free()
