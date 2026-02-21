extends Node3D
class_name PlayerReadySlot

signal start_requested

@export var index: int

@export var name_label: Label3D
@export var ready_root: Node3D
@export var notready_root: Node3D

var _is_ready: bool = false
var _blocked_from_starting: bool = false


func _ready() -> void:
	name_label.text = "PLAYER "+str(index)
	notready_root.visible = true
	ready_root.visible = false


func _process(_delta: float) -> void:
	#TODO: if input(_context) -> _handle_player_input()
	if (Input.is_action_just_pressed("pickup")):
		_handle_player_input()


func _handle_player_input() -> void:
	if (_is_ready):
		if (!_blocked_from_starting):
			start_requested.emit()
	else:
		_is_ready = true
		ready_root.visible = true
		notready_root.visible = false
		_blocked_from_starting = true;
		await get_tree().create_timer(1.0).timeout
		_blocked_from_starting = false
