extends Node3D

@export var player_controller: PlayerController
@export var animation_player_main: AnimationPlayer
@export var root: Node3D
@export var root2: Node3D
@export var held_item_parent: Node3D
@export var faceplant: Node3D
@export var starfish: Node3D

@export var sfx_footstep: AudioCollectionData
@export var sfx_grab_item: AudioCollectionData
@export var sfx_start_moving: AudioCollectionData
@export var sfx_stop_moving: AudioCollectionData
@export var sfx_swing_followthrough: AudioCollectionData
@export var sfx_swing_impact_bad: AudioCollectionData
@export var sfx_swing_impact_normal: AudioCollectionData
@export var sfx_swing_impact_good: AudioCollectionData
@export var sfx_swing_miss: AudioCollectionData
@export var sfx_swing_windup: AudioCollectionData

var _is_moving: bool = false

func _ready() -> void:
	player_controller.movement_started.connect(_on_movement_started)
	player_controller.movement_stopped.connect(_on_movement_stopped)
	player_controller.swing_began.connect(_on_swing_began)
	player_controller.swing_missed.connect(_on_swing_missed)
	player_controller.swing_impact.connect(_on_swing_impact)
	player_controller.swing_released.connect(_on_swing_released)
	player_controller.swing_ended.connect(_on_swing_ended)
	player_controller.grabbed_item.connect(_on_grabbed_item)
	player_controller.dropped_item.connect(_on_dropped_item)
	player_controller.was_grabbed.connect(_on_was_grabbed)
	player_controller.was_locked.connect(_on_was_locked)
	player_controller.was_released.connect(_on_was_released)
	_play(&"idle")


func _process(_delta: float) -> void:
	if (!player_controller._is_animation_rotation_locked and
		!player_controller._is_grabbed and
		!player_controller._is_locked):
		animation_player_main.speed_scale = clamp(player_controller._equipped_move_speed_multiplier * 1.2, 0.5, 3.0)
		var rot: float = Vector2(player_controller._last_move_direction.z, player_controller._last_move_direction.x).angle()
		root.rotation.y = rot
		root2.rotation.y = rot
	else:
		animation_player_main.speed_scale = 1.0


func _on_movement_started() -> void:
	if (!player_controller._is_grabbed && !player_controller._is_locked):
		sfx_start_moving.play3D(position)
		_is_moving = true
		if (player_controller.is_holding_anything()):
			_play(&"walk_full")
		else:
			_play(&"walk_empty")

func _on_movement_stopped() -> void:
	if (_is_moving):
		sfx_stop_moving.play3D(position)
		_is_moving = false
		if (!player_controller._is_swinging):
			_play(&"idle")

func _on_swing_began() -> void:
	sfx_swing_windup.play3D(position)
	_play(&"swing_start")

func _on_swing_missed() -> void:
	sfx_swing_miss.play3D(position)
	#_play(&"swing_finish")
	pass

func _on_swing_impact(power: int, highest: int) -> void:
	_play(&"swing_impact")
	match power:
		0, 1:
			sfx_swing_impact_bad.play3D(position)
		highest:
			sfx_swing_impact_good.play3D(position)
		_:
			sfx_swing_impact_normal.play3D(position)

func _on_swing_released() -> void:
	sfx_swing_followthrough.play3D(position)
	_play(&"swing_finish")

func _on_swing_ended() -> void:
	if (!_is_moving):
		_play(&"idle")

func _on_grabbed_item() -> void:
	sfx_grab_item.play3D(position)
	_bump_tween()
	if (_is_moving):
		_play(&"walk_full")

func _on_dropped_item() -> void:
	_bump_tween()
	if (_is_moving):
		_play(&"walk_empty")

func _bump_tween() -> void:
	var tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(root, "scale", Vector3(1.25, 0.75, 1.25), 0.05)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(root, "scale", Vector3.ONE, 0.05)

func _play(animation: StringName) -> void:
	starfish.visible = false
	faceplant.visible = false
	animation_player_main.play(&"RESET")
	animation_player_main.advance(0) #clear the existing keyframes first
	animation_player_main.play(&"player_animations_main/" + animation)
	animation_player_main.advance(0)

func _do_footstep() -> void:
	sfx_footstep.play3D(position)

func _on_was_grabbed() -> void:
	_play(&"RESET")
	starfish.visible = true

func _on_was_locked() -> void:
	_play(&"RESET")
	starfish.visible = true

func _on_was_released() -> void:
	_play(&"RESET")
	faceplant.visible = true
