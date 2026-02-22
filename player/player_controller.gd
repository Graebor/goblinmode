extends RigidBody3D
class_name PlayerController

signal movement_started
signal movement_stopped
signal swing_began
signal swing_missed
signal swing_impact(power: int, highest: int)
signal swing_released
signal swing_ended
signal grabbed_item
signal dropped_item
@warning_ignore("unused_signal")
signal was_grabbed
@warning_ignore("unused_signal")
signal was_locked
@warning_ignore("unused_signal")
signal was_released
signal stun_began
signal stun_ended

const IN_HAND_GROUP: String = "InHand"
const SINKING_GROUP: String = "Sinking"
const ITEM_GROUP: String = "Item"
const TUBING_GROUP: String = "Tubing"

@export var speed: float = 1.0
@export var pickup_range: float = 1.5
@export var power_meter: PowerMeter
@export var swing_force_per_segment: float = 10.0
@export var swing_modifier_empty_handed: float = 0.5
@export var aim_ring: Node3D
@onready var swing_spot: Node3D = %SwingSpot
@export var delay_after_swing: float = 0.4
@export var power_segments_when_swung: int = 6
@export var speed_multiplier_when_held: float = 0.2
@export var stun_stars: Node3D
@export var stun_duration_per_power_segment: float = 0.25
@export var personality_tint: Array[MeshInstance3D]
@export var pickup_preview: Node3D

var player_context: PlayerContext
var inventory: Node3D
var _is_grabbed: bool = false
var _is_locked: bool = false
var _is_moving: bool = false
var _is_swinging: bool = false
var _is_counting_down: bool = true
var _is_animation_rotation_locked: bool = false
var _last_move_direction: Vector3
var _swinging_item_has_layer_3: bool
var _swinging_item_has_layer_4: bool
var _equipped_move_speed_multiplier: float = 1.0
var _remaining_stun: float = 0.0
var _original_linear_damp: float = 0.0
var _original_angular_damp: float = 0.0
var _sand_damp_mod: float = 3.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for mesh: MeshInstance3D in personality_tint:
		var mat: StandardMaterial3D = mesh.get_surface_override_material(0).duplicate()
		mat.albedo_color = player_context.personality.color
		mesh.set_surface_override_material(0, mat)
	stun_stars.visible = false
	inventory = $PlayerAnimation.held_item_parent
	power_meter.visible = false
	aim_ring.visible = false
	_original_linear_damp = linear_damp
	_original_angular_damp = angular_damp
	GameManager.level_started.connect(_on_level_started)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if inventory.get_child_count() > 0:
		if inventory.get_child(0) is Item:
			var target: Item = inventory.get_child(0)
			_equipped_move_speed_multiplier = target.move_speed_multiplier
		else:
			_equipped_move_speed_multiplier = speed_multiplier_when_held
	else:
		_equipped_move_speed_multiplier = 1.0
	
	if (_remaining_stun > 0):
		_remaining_stun -= _delta
		stun_stars.rotation_degrees.y += _delta * 260
		if (_remaining_stun <= 0):
			stun_ended.emit()
			stun_stars.visible = false
	
	var direction: Vector3 = _get_movement()
	if (direction.length() > 0.1 && !is_stunned()):
		_last_move_direction = direction.normalized()
	_refresh_is_moving()
	
	var is_blocked: bool = is_stunned() or _is_grabbed or _is_locked or _is_counting_down
	var pickup_input: bool = PlayerManager.is_action_just_pressed("pickup", player_context)
	var struggle_out: bool = false
	var current_item: RigidBody3D = get_held_body()
	var held: PlayerController = current_item as PlayerController
	if (held != null):
		struggle_out = !held.is_stunned()
	
	var nearby: Node3D = _get_closest_swing_target(current_item, true)
	if (is_blocked):
		nearby = null
	pickup_preview.visible = nearby != null
	if (nearby != null):
		pickup_preview.global_position.x = nearby.global_position.x
		pickup_preview.global_position.z = nearby.global_position.z
	
	if ((pickup_input and !is_blocked) or struggle_out):
		if (current_item != null):
			_release_item(current_item)
			dropped_item.emit()
	
	if (pickup_input and !is_blocked):
		var target: RigidBody3D = _get_closest_swing_target(current_item, true)
		if (target != null):
			if target is Item:
				var item: Item = target as Item
				item.is_locked = true
			target.reparent(inventory)
			target.add_to_group(IN_HAND_GROUP)
			target.global_position = inventory.global_position
			target.freeze = true
			if (target is PlayerController):
				target._is_grabbed = true
				target.was_grabbed.emit()
			grabbed_item.emit()
	
	if (_is_swinging):
		if (!_is_animation_rotation_locked):
			if (_last_move_direction.length() > 0.1):
				aim_ring.visible = true
				aim_ring.rotation.y = Vector2(_last_move_direction.z, _last_move_direction.x).angle()
			else:
				aim_ring.visible = false
		
		if (!PlayerManager.is_action_pressed("swing", player_context) && !_is_animation_rotation_locked):
			_finish_swing()
	else:
		if (!is_blocked && PlayerManager.is_action_just_pressed("swing", player_context)):
			_begin_swing()


func _refresh_is_moving() -> void:
	var new_is_moving: bool = (_get_movement().length() > 0.1 && !_is_swinging && !_is_locked && !_is_grabbed && !is_stunned())
	if (!_is_moving && new_is_moving):
		_is_moving = true
		movement_started.emit()
	elif (_is_moving && !new_is_moving):
		_is_moving = false
		movement_stopped.emit()

func _release_item(body: RigidBody3D) -> void:
	if (body is Item):
		body.reparent(ItemManager)
		body.owner = ItemManager
		var item: Item = body as Item
		item.last_player = player_context
	elif (body is PlayerController):
		body.reparent(PlayerManager)
		body.rotation = Vector3.ZERO
		body._is_grabbed = false
		body._is_locked = false
		body.was_released.emit()
	body.remove_from_group(IN_HAND_GROUP)
	body.global_position.y = 0
	body.freeze = false
	if body is Item:
		var item: Item = body as Item
		item.is_locked = false


func _begin_swing() -> void:
	var target: RigidBody3D = _get_closest_swing_target(null, false)
	if target != null:
		target.reparent(swing_spot)
		target.add_to_group(IN_HAND_GROUP)
		target.global_position = swing_spot.global_position
		if (target is Item):
			_swinging_item_has_layer_3 = target.get_collision_layer_value(3)
			_swinging_item_has_layer_4 = target.get_collision_layer_value(4)
			target.set_collision_layer_value(3, false)
			target.set_collision_layer_value(4, false)
		elif (target is PlayerController):
			target._is_locked = true
			target.set_collision_layer_value(2, false)
			target.was_locked.emit()
	else:
		swing_missed.emit()
		return

	var segments: int = 2
	var held: RigidBody3D = get_held_body()
	if (held != null && held is Item):
		segments = held.power_segments
	if (held != null && held is PlayerController):
		segments = power_segments_when_swung
	power_meter.begin(segments)
	_is_swinging = true
	swing_began.emit()
	if target is Item:
		var item: Item = target as Item
		item.is_locked = true


func _finish_swing() -> void:
	var result: int = power_meter.lock_in() + 1
	_is_animation_rotation_locked = true
	swing_impact.emit(result, power_meter._current_segments)
	
	await get_tree().create_timer(delay_after_swing).timeout
	
	aim_ring.visible = false
	var locked: RigidBody3D = swing_spot.get_child(0)
	if (locked != null):
		_release_item(locked)
		var power: float = swing_force_per_segment * pow(result, 1.125)
		
		if !is_holding_anything():
			power *= swing_modifier_empty_handed
		
		if (locked is PlayerController):
			power *= locked.mass

		locked.apply_force(_last_move_direction * power)
		
		if (locked is Item):
			locked.set_collision_layer_value(3, _swinging_item_has_layer_3)
			locked.set_collision_layer_value(4, _swinging_item_has_layer_4)
		elif (locked is PlayerController):
			locked.set_collision_layer_value(2, true)
			locked.stun(result * stun_duration_per_power_segment)
	swing_released.emit()
	await get_tree().create_timer(0.5).timeout
	_is_swinging = false
	_is_animation_rotation_locked = false
	swing_ended.emit()

func _physics_process(_delta: float) -> void:
	if (!_is_swinging && !_is_grabbed && !_is_locked && !is_stunned() && !_is_counting_down):
		var direction: Vector3 = _get_movement()
		apply_force(speed * direction * _equipped_move_speed_multiplier)
	
	if is_in_group("Sand"):
		angular_damp = _original_angular_damp * _sand_damp_mod
		linear_damp = _original_linear_damp * _sand_damp_mod
	else:
		angular_damp = _original_angular_damp
		linear_damp = _original_linear_damp

func _get_movement() -> Vector3:
	var direction = Vector3.ZERO

	if PlayerManager.is_action_pressed("right", player_context):
		direction.x += 1
	if PlayerManager.is_action_pressed("left", player_context):
		direction.x -= 1
	if PlayerManager.is_action_pressed("down", player_context):
		direction.z += 1
	if PlayerManager.is_action_pressed("up", player_context):
		direction.z -= 1
	
	direction = direction.normalized()
	
	if player_context.is_keyboard_player_1 == false and player_context.is_keyboard_player_2 == false:
		direction.x = _handle_deadzone(Input.get_joy_axis(player_context.device_id, JOY_AXIS_LEFT_X))
		direction.z = _handle_deadzone(Input.get_joy_axis(player_context.device_id, JOY_AXIS_LEFT_Y))

	return direction

func _handle_deadzone(value: float) -> float:
	var deadzone: float = 0.2
	if value > deadzone:
		return value
	if value < -deadzone:
		return value
	return 0.0

func _get_closest_swing_target(previous: Node3D, players_must_be_stunned: bool) -> Item:
	var items: Array[Node] = get_tree().get_nodes_in_group(ITEM_GROUP)
	var closest: Node3D = null
	for item: Node in items:
		if not item.is_in_group(TUBING_GROUP) and not item.is_in_group(IN_HAND_GROUP) and not item.is_in_group(SINKING_GROUP) and item is Item and item != previous:
			if global_position.distance_to(item.global_position) < pickup_range:
				if closest == null:
					closest = item
				elif global_position.distance_to(closest.global_position) > global_position.distance_to(item.global_position):
					closest = item
	for player: PlayerController in PlayerManager.get_children():
		var stun_is_valid: bool = true
		if (players_must_be_stunned):
			stun_is_valid = player.is_stunned()
		if not player.is_in_group(IN_HAND_GROUP) and stun_is_valid and player != self and player != previous:
			if global_position.distance_to(player.global_position) < pickup_range:
				if closest == null:
					closest = player
				elif global_position.distance_to(player.global_position) > global_position.distance_to(closest.global_position):
					closest = player
	return closest


func is_holding_anything() -> bool:
	return inventory.get_child_count() > 0

func get_held_item() -> Item:
	if (is_holding_anything()):
		return inventory.get_child(0) as Item
	return null

func get_held_body() -> RigidBody3D:
	if (is_holding_anything()):
		return inventory.get_child(0) as RigidBody3D
	return null

func stun(duration: float) -> void:
	stun_stars.visible = true
	_remaining_stun = max(_remaining_stun, duration)
	drop_items()
	stun_began.emit()

func is_stunned() -> bool:
	return _remaining_stun > 0


func drop_items() -> void:
	for item: RigidBody3D in inventory.get_children():
		_release_item(item)
		var direction: Vector3 = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized()
		var strength: float = randf_range(2.0, 10.0)
		item.apply_impulse(direction * strength)
		
	for item: RigidBody3D in swing_spot.get_children():
		_release_item(item)
		var direction: Vector3 = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized()
		var strength: float = randf_range(2.0, 10.0)
		item.apply_impulse(direction * strength)

func _on_level_started() -> void:
	_is_counting_down = false
