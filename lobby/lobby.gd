extends Node3D
class_name Lobby

signal players_confirmed

@export var slots: Array[PlayerReadySlot]
@export var sfx_move_to_stage1: AudioCollectionData
@export var sfx_player_joined: AudioCollectionData

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
	sfx_player_joined.play3D(position)
	_refresh_all_ready()

func _on_readied_slot() -> void:
	_refresh_all_ready()

func _refresh_all_ready() -> void:
	var all_ready: bool = _all_ready()
	for slot: PlayerReadySlot in slots:
		slot.set_all_ready(all_ready)

func _on_start_requested() -> void:
	if (_all_ready()):
		sfx_move_to_stage1.play3D(position)
		players_confirmed.emit()

func _all_ready() -> bool:
	var all_ready: bool = true
	var count_ready: int = 0
	for slot: PlayerReadySlot in slots:
		if (slot._has_joined && !slot._is_ready):
			all_ready = false
		if (slot._has_joined && slot._is_ready):
			count_ready += 1
	if (count_ready < 2):
		return false
	return all_ready
