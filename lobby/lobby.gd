extends Node3D
class_name Lobby

signal players_confirmed

@export var slots: Array[PlayerReadySlot]

func _ready() -> void:
	for slot: PlayerReadySlot in slots:
		slot.start_requested.connect(_on_start_requested)

func _on_start_requested() -> void:
	players_confirmed.emit()
