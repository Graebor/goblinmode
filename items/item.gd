class_name Item
extends RigidBody3D

@export var power_segments: int = 3
@export var move_speed_multiplier: float = 1.0

var last_player: PlayerContext
var is_locked: bool = false:
	set(value):
		if is_locked != value:
			is_locked = value
			if is_locked:
				set_collision_layer_value(3, false)
				set_collision_layer_value(4, false)
			else:
				set_collision_layer_value(3, _collision_layer_3)
				set_collision_layer_value(4, _collision_layer_4)
var _collision_layer_3: bool
var _collision_layer_4: bool
var _original_linear_damp: float = 0.0
var _original_angular_damp: float = 0.0
var _sand_damp_mod: float = 2.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_setup")
	_collision_layer_3 = get_collision_layer_value(3)
	_collision_layer_4 = get_collision_layer_value(4)


func _process(_delta: float) -> void:
	if is_in_group("InHand") and not is_in_group("Sinking"):
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		position = Vector3.ZERO

	if is_in_group("Sinking"):
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		
	if is_in_group("Sand"):
		angular_damp = _original_angular_damp * _sand_damp_mod
		linear_damp = _original_linear_damp * _sand_damp_mod
	else:
		angular_damp = _original_angular_damp
		linear_damp = _original_linear_damp


func _setup() -> void:
	if not is_in_group("InHand"):
		self.reparent(ItemManager)
		#self.owner = ItemManager
