extends Area3D

@export var velocity_threshold: float = 10
@export var multiplier: float = 5.0

var player: PlayerController

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	player = get_parent()


func _on_body_entered(node: Node3D) -> void:
	if not node.is_in_group("Item") or node.is_in_group("Sinking") or node.is_in_group("InHand"):
		return
	
	var body: RigidBody3D = node as RigidBody3D
	#print("Angular: %s" % body.angular_velocity)
	#print("Linear: %s" % body.linear_velocity)
	#print("")
	
	if body.linear_velocity.length() > velocity_threshold or body.angular_velocity.length() > velocity_threshold:
		player.apply_force(body.linear_velocity * multiplier)
		player.stun(min(body.linear_velocity.length() / 10.0, 3.0))
		
		
