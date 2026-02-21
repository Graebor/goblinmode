extends RigidBody3D
class_name PlayerController

signal movement_started
signal movement_stopped
signal swing_began
signal swing_missed
signal swing_released
signal grabbed_item
signal dropped_item

const IN_HAND_GROUP: String = "InHand"
const ITEM_GROUP: String = "Item"

@export var speed: float = 1.0
@export var damping: float = 2.0
@export var pickup_range: float = 1.5
@onready var inventory: Node3D = %Inventory
@export var power_meter: PowerMeter
@export var swing_force_per_segment: float = 10.0
@export var swing_modifier_empty_handed: float = 0.5
@export var aim_ring: Node3D
@onready var swing_spot: Node3D = %SwingSpot

var _is_moving: bool = false
var _is_swinging: bool = false
var _last_move_direction: Vector3
var _swinging_item_has_layer_3: bool
var _swinging_item_has_layer_4: bool
var _equipped_move_speed_multiplier: float = 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	power_meter.visible = false
	aim_ring.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var input: Vector3 = _get_movement()
	if (input.length() > 0.1):
		_last_move_direction = input
		if (!_is_moving):
			_is_moving = true
			movement_started.emit()
	else:
		if (_is_moving):
			_is_moving = false
			movement_stopped.emit()
	
	if Input.is_action_just_pressed("pickup"):
		var current_item: RigidBody3D = inventory.get_child(0)
		if current_item != null:
			_release_item(current_item)
			_equipped_move_speed_multiplier = 1.0
			dropped_item.emit()
		
		var item: Item = _get_closest_item(current_item)
		if item != null:
			print(item.name)
			item.reparent(inventory)
			item.add_to_group(IN_HAND_GROUP)
			item.global_position = inventory.global_position
			_equipped_move_speed_multiplier = item.move_speed_multiplier
			grabbed_item.emit()
	
	if (_is_swinging):
		if (_last_move_direction.length() > 0.1):
			aim_ring.visible = true
			aim_ring.rotation.y = Vector2(_last_move_direction.z, _last_move_direction.x).angle()
		else:
			aim_ring.visible = false
		
		if (!Input.is_action_pressed("swing")):
			_finish_swing()
	else:
		if Input.is_action_just_pressed("swing"):
			_begin_swing()


func _release_item(item: RigidBody3D) -> void:
	item.reparent(ItemManager)
	item.owner = ItemManager
	item.remove_from_group(IN_HAND_GROUP)
	item.global_position.y = 0


func _begin_swing() -> void:
	var item: Item = _get_closest_item(null)
	if item != null:
		print(item.name)
		item.reparent(swing_spot)
		item.add_to_group(IN_HAND_GROUP)
		item.global_position = swing_spot.global_position
		_swinging_item_has_layer_3 = item.get_collision_layer_value(3)
		_swinging_item_has_layer_4 = item.get_collision_layer_value(4)
		item.set_collision_layer_value(3, false)
		item.set_collision_layer_value(4, false)
	else:
		swing_missed.emit()
		return

	var segments: int = 2
	if (inventory.get_child_count() > 0):
		var held: Item = inventory.get_child(0)
		if (held != null):
			segments = held.power_segments
	power_meter.begin(segments)
	_is_swinging = true
	swing_began.emit()


func _finish_swing() -> void:
	var result: int = power_meter.lock_in() + 1
	var locked: RigidBody3D = swing_spot.get_child(0)
	if (locked != null):
		_release_item(locked)
		var power: float = swing_force_per_segment * pow(result, 1.125)
		
		if is_holding_item():
			power *= swing_modifier_empty_handed
			
		locked.apply_central_force(_last_move_direction * power)
		locked.set_collision_layer_value(3, _swinging_item_has_layer_3)
		locked.set_collision_layer_value(4, _swinging_item_has_layer_4)
	_is_swinging = false
	aim_ring.visible = false
	swing_released.emit()


func _physics_process(_delta: float) -> void:
	if (!_is_swinging):
		var direction: Vector3 = _get_movement()
		linear_damp = damping
		apply_force(speed * direction * _equipped_move_speed_multiplier)
	

func _get_movement() -> Vector3:
	var direction = Vector3.ZERO

	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.z += 1
	if Input.is_action_pressed("up"):
		direction.z -= 1
		
	direction = direction.normalized()

	return direction


func _get_closest_item(previous: Node3D) -> Item:
	var items: Array[Node] = get_tree().get_nodes_in_group(ITEM_GROUP)
	var closest: Node3D = null
	for item: Node in items:
		print("item")
		if not item.is_in_group(IN_HAND_GROUP) and item is Item and item != previous:
			if global_position.distance_to(item.global_position) < pickup_range:
				if closest == null:
					closest = item
				elif global_position.distance_to(closest.global_position) > global_position.distance_to(item.global_position):
					closest = item
				
	return closest


func is_holding_item() -> bool:
	return inventory.get_child_count() > 0
