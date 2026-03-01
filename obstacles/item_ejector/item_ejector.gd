extends Node3D

@export var item_scene: PackedScene
@export var is_infinite: bool = false
@export var ammo: int = 1
@export var delay: float = 5.0
@export var impulse_stength: float = 10.0

var count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	count = ammo
	_spawn()


func _spawn() -> void:
	var instance = item_scene.instantiate()
	assert(instance is Item)
	ItemManager.add_child(instance)
	var body = instance as RigidBody3D
	body.global_position = global_position
	body.global_position.y = 0
	body.apply_impulse(Vector3.BACK * impulse_stength)
		
	await get_tree().create_timer(delay).timeout
	
	if is_infinite:
		_spawn()
	elif count > 0:
		count -= 1
		_spawn()
