extends RigidBody3D

const IN_HAND_GROUP: String = "InHand"
const ITEM_GROUP: String = "Item"

@export var speed: float = 1.0
@export var damping: float = 2.0
@export var pickup_range: float = 1.5
@onready var inventory: Node3D = %Inventory


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_select"):
		var current_item: RigidBody3D = inventory.get_child(0)
		if current_item != null:
			current_item.reparent(ItemManager)
			current_item.owner = ItemManager
			current_item.remove_from_group(IN_HAND_GROUP)
			current_item.global_position.y = 0
		
		var item: Item = _get_closest_item(current_item)
		if item != null:
			print(item.name)
			item.reparent(inventory)
			item.add_to_group(IN_HAND_GROUP)
			item.global_position = inventory.global_position


func _physics_process(delta: float) -> void:
	var direction: Vector3 = _get_movement()
	linear_damp = damping
	apply_force(speed * direction)
	

func _get_movement() -> Vector3:
	var direction = Vector3.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.z += 1
	if Input.is_action_pressed("ui_up"):
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
