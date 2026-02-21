extends Node3D

@export var player_controller: PlayerController
@export var animation_player_main: AnimationPlayer
@export var root: Node3D

var _is_moving: bool = false

func _ready() -> void:
	player_controller.movement_started.connect(_on_movement_started)
	player_controller.movement_stopped.connect(_on_movement_stopped)
	player_controller.swing_began.connect(_on_swing_began)
	player_controller.swing_missed.connect(_on_swing_missed)
	player_controller.swing_released.connect(_on_swing_released)
	_play(&"idle")

func _process(_delta: float) -> void:
	if (_is_moving):
		root.rotation.y = Vector2(player_controller._last_move_direction.z, player_controller._last_move_direction.x).angle()

func _on_movement_started() -> void:
	_is_moving = true
	if (player_controller.is_holding_item()):
		_play(&"walk_full")
	else:
		_play(&"walk_empty")

func _on_movement_stopped() -> void:
	_is_moving = false
	_play(&"idle")

func _on_swing_began() -> void:
	pass

func _on_swing_missed() -> void:
	pass

func _on_swing_released() -> void:
	pass

func _on_grabbed_item() -> void:
	if (_is_moving):
		_play(&"walk_full")

func _on_dropped_item() -> void:
	if (_is_moving):
		_play(&"walk_empty")


func _play(animation: StringName) -> void:
	animation_player_main.play(&"RESET")
	animation_player_main.advance(0) #clear the existing keyframes first
	animation_player_main.play(&"player_animations_main/" + animation)
