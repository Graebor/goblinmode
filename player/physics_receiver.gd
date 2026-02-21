extends Area3D

@export var velocity_threshold: float = 5.0
@export var multiplier: float = 30.0

var player: PlayerController
var locked_item: RigidBody3D
var locked_item_of_other_player: RigidBody3D 


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	player = get_parent()
	player.swing_began.connect(_on_swing_began)
	player.swing_ended.connect(_on_swing_ended)


func _on_swing_began() -> void:
	if player.swing_spot.get_child_count() > 0:
		locked_item = player.swing_spot.get_child(0)
		if locked_item is PlayerController:
			var other_player: PlayerController = locked_item as PlayerController
			if other_player.inventory.get_child_count() > 0:
				locked_item_of_other_player = other_player.inventory.get_child(0)


func _on_swing_ended() -> void:
	locked_item = null


func _on_body_entered(node: Node3D) -> void:
	if node.is_in_group("Sinking") or node.is_in_group("InHand"):
		return
	
	var body: RigidBody3D = node as RigidBody3D
	if not is_instance_valid(body):
		return
	
	if locked_item != null and body == locked_item:
		return
	
	if locked_item_of_other_player != null and body == locked_item_of_other_player:
		return
	
	if body.linear_velocity.length() > velocity_threshold or body.angular_velocity.length() > velocity_threshold:
		var player_pos: Vector3 = player.global_position
		var body_pos: Vector3 = body.global_position
		player_pos.y = 0
		body_pos.y = 0
		
		var direction: Vector3 = player_pos - body_pos
		direction = direction.normalized()
		player.apply_impulse(direction * body.linear_velocity.length() * multiplier)
		player.stun(min(body.linear_velocity.length() / 10.0, 3.0))
