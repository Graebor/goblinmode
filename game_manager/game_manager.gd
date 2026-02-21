extends Node

signal level_started

var game: Game

func notify_level_started() -> void:
	level_started.emit()
