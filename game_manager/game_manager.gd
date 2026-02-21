extends Node

signal level_started

func notify_level_started() -> void:
	level_started.emit()
