extends Node3D
class_name ScoreScreen

signal finished_looking_at_scores

@export var label: Label3D

func _ready() -> void:
	var text: String = "SCORES:\n\n"
	
	for context: PlayerContext in GameManager.game._scores.keys():
		text += "Player " + str(context.device_id) + ": " + str(GameManager.game._scores[context])

	label.text = text
	
	await get_tree().create_timer(3).timeout
	
	finished_looking_at_scores.emit()
