extends Node3D
class_name Lobby

signal players_confirmed

@export var slots: Array[PlayerReadySlot]

var index: int = 0

func _ready() -> void:
	PlayerManager.clear_all_player_information()
	for slot: PlayerReadySlot in slots:
		slot.start_requested.connect(_on_start_requested)
		slot.joined.connect(_on_joined_slot)
		slot.readied.connect(_on_readied_slot)
	PlayerManager.player_joined.connect(_on_player_joined)

func _on_player_joined(context: PlayerContext) -> void:
	if (index < slots.size()):
		slots[index].player_joined(context)
		index += 1

func _on_joined_slot() -> void:
	_refresh_all_ready()

func _on_readied_slot() -> void:
	_refresh_all_ready()

func _refresh_all_ready() -> void:
	var all_ready: bool = _all_ready()
	for slot: PlayerReadySlot in slots:
		slot.set_all_ready(all_ready)

func _on_start_requested() -> void:
	if (_all_ready()):
		players_confirmed.emit()

func _all_ready() -> bool:
	var all_ready: bool = true
	for slot: PlayerReadySlot in slots:
		if (slot._has_joined && !slot._is_ready):
			all_ready = false
	return all_ready
