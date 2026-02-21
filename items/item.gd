class_name Item
extends RigidBody3D

@export var power_segments: int = 3
@export var move_speed_multiplier: float = 1.0

var last_player: PlayerContext

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_setup")


func _process(_delta: float) -> void:
	if is_in_group("InHand"):
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		position = Vector3.ZERO


func _setup() -> void:
	if not is_in_group("InHand"):
		self.reparent(ItemManager)
		self.owner = ItemManager
