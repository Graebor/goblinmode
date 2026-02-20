extends RigidBody3D

const IN_HAND_GROUP: String = "InHand"
const ITEM_GROUP: String = "Item"

@export var speed: float = 1.0
@export var damping: float = 2.0
@export var pickup_range: float = 1.5
@onready var inventory: Node3D = %Inventory
@export var power_meter: PowerMeter
@export var swing_force_per_segment: float = 10.0

var _is_swinging: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	power_meter.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pickup"):
		var current_item: RigidBody3D = inventory.get_child(0)
		if current_item != null:
			_release_item(current_item)
		
		var item: Item = _get_closest_item(current_item)
		if item != null:
			print(item.name)
			item.reparent(inventory)
			item.add_to_group(IN_HAND_GROUP)
			item.global_position = inventory.global_position
	
	if (_is_swinging):
		if (!Input.is_action_pressed("swing")):
			var result: int = power_meter.lock_in() + 1
			var closest: RigidBody3D = _get_closest_item(null)
			if (closest != null):
				closest.apply_central_force(Vector3.FORWARD * result * swing_force_per_segment)
			_is_swinging = false
	else:
		if Input.is_action_just_pressed("swing"):
			var segments: int = 4
			if (inventory.get_child_count() > 0):
				var item: RigidBody3D = inventory.get_child(0)
				if (item != null):
					pass
					#TODO - change segments to whatever the item's power value is
			
			power_meter.begin(segments)
			_is_swinging = true


func _release_item(item: RigidBody3D) -> void:
	item.reparent(ItemManager)
	item.owner = ItemManager
	item.remove_from_group(IN_HAND_GROUP)
	item.global_position.y = 0


func _physics_process(_delta: float) -> void:
	if (!_is_swinging):
		var direction: Vector3 = _get_movement()
		linear_damp = damping
		apply_force(speed * direction)
	

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
