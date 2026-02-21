extends Node3D
class_name Lobby

signal players_confirmed

@export var slots: Array[PlayerReadySlot]

var index: int = 0

func _ready() -> void:
	PlayerManager.clear_all_player_information()
	for slot: PlayerReadySlot in slots:
		slot.start_requested.connect(_on_start_requested)
	PlayerManager.player_joined.connect(_on_player_joined)

func _on_player_joined(context: PlayerContext) -> void:
	if (index < slots.size()):
		slots[index].player_joined(context)
		index += 1
	
func _on_start_requested() -> void:
	players_confirmed.emit()
