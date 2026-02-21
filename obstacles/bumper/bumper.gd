@tool
extends RigidBody3D

@export var radius: float = 2.0

@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var shape: CSGCylinder3D = $CSGCylinder3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_resize()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_resize()

func _resize() -> void:
	shape.radius = radius
	var collision_shape := collider.shape as CylinderShape3D
	collision_shape.radius = radius


func _on_body_entered(node: Node3D) -> void:
	if not node is RigidBody3D:
		return
		
	var body: RigidBody3D = node as RigidBody3D
	
	var self_pos: Vector3 = global_position
	var node_pos: Vector3 = node.global_position
	self_pos.y = 0
	node_pos.y = 0
	
	var direction: Vector3 = node_pos - self_pos
	body.apply_impulse(body.linear_velocity.length() * direction * 20.0)
	if not body is PlayerController:
		return
		
	var player: PlayerController = body as PlayerController
	player.stun(0.5)
	
