extends Node3D
class_name PlayerReadySlot

signal start_requested

@export var index: int

@export var name_label: Label3D
@export var ready_root: Node3D
@export var notready_root: Node3D
@export var pointers: Array[GoblinMaterialPointer]

var _context: PlayerContext
var _has_joined: bool = false
var _is_ready: bool = false
var _blocked_from_starting: bool = false


func _ready() -> void:
	ready_root.visible = false
	notready_root.visible = false


func player_joined(context: PlayerContext) -> void:
	_context = context
	name_label.text = context.personality.title
	name_label.modulate = context.personality.color
	context.personality.voice_selected.play3D(position)
	notready_root.visible = true
	ready_root.visible = false
	for pointer: GoblinMaterialPointer in pointers:
		pointer.set_override(context.personality.skin)
	
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	notready_root.scale = Vector3(0.9, 1.1, 0.9)
	tween.tween_property(notready_root, "scale", Vector3.ONE, 0.3)
	
	await get_tree().create_timer(0.1).timeout
	_has_joined = true


func _process(_delta: float) -> void:
	if (_has_joined):
		if (PlayerManager.is_action_just_pressed("swing", _context)):
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
		_context.personality.voice_swing.play3D(position)
		
		var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(ready_root, "scale", Vector3(0.9, 1.1, 0.9), 0.1)
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property(ready_root, "scale", Vector3.ONE, 0.1)
		
		await get_tree().create_timer(1.0).timeout
		_blocked_from_starting = false
