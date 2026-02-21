extends Node


func clear() -> void:
	for child in get_children():
		child.queue_free()
